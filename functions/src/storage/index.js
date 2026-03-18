const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const crypto = require("crypto");

// B2 Storage Upload Module - v2

const B2_KEY_ID = defineSecret("B2_KEY_ID");
const B2_APP_KEY = defineSecret("B2_APP_KEY");
const B2_BUCKET_ID = defineSecret("B2_BUCKET_ID");
const B2_BUCKET_NAME = defineSecret("B2_BUCKET_NAME");

// Cache for B2 auth tokens (expires after 23.5 hours)
let b2AuthCache = {
  token: null,
  apiUrl: null,
  expiresAt: null,
};

/**
 * Make HTTPS fetch request (using native fetch)
 */
async function fetchWithRetry(url, options = {}, maxRetries = 2) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      if (!response.ok && attempt < maxRetries - 1) {
        console.warn(`Fetch attempt ${attempt + 1} failed with ${response.status}, retrying...`);
        await new Promise(r => setTimeout(r, 1000 * (attempt + 1)));
        continue;
      }
      return response;
    } catch (error) {
      if (attempt < maxRetries - 1) {
        console.warn(`Fetch attempt ${attempt + 1} failed: ${error.message}, retrying...`);
        await new Promise(r => setTimeout(r, 1000 * (attempt + 1)));
        continue;
      }
      throw error;
    }
  }
}

/**
 * Authenticate with B2 and return auth token + API URL
 */
async function b2Authorize(keyId, appKey) {
  // Check if cached auth is still valid
  if (
    b2AuthCache.token &&
    b2AuthCache.expiresAt &&
    Date.now() < b2AuthCache.expiresAt
  ) {
    return {
      authToken: b2AuthCache.token,
      apiUrl: b2AuthCache.apiUrl,
      downloadUrl: b2AuthCache.downloadUrl,
    };
  }

  // Ensure secrets are strings and trimmed (removes newlines from Secret Manager)
  const trimmedKeyId = String(keyId || "").trim();
  const trimmedAppKey = String(appKey || "").trim();

  if (!trimmedKeyId || !trimmedAppKey) {
    throw new HttpsError("failed-precondition", "B2 credentials not configured");
  }

  console.log(`B2 Auth - KeyID: ${trimmedKeyId.substring(0, 10)}..., AppKey: ${trimmedAppKey.substring(0, 10)}...`);

  const credentials = Buffer.from(`${trimmedKeyId}:${trimmedAppKey}`).toString("base64");

  const response = await fetchWithRetry("https://api.backblazeb2.com/b2api/v2/b2_authorize_account", {
    method: "GET",
    headers: {
      Authorization: `Basic ${credentials}`,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error(`B2 Auth failed: ${response.status} - ${errorText}`);
    throw new HttpsError("unauthenticated", `B2 auth failed: ${response.status} - ${errorText}`);
  }

  const data = await response.json();
  console.log(`B2 Auth successful - Account: ${data.accountId}`);

  // Cache the auth token for 23 hours
  b2AuthCache = {
    token: data.authorizationToken,
    apiUrl: data.apiUrl,
    downloadUrl: data.downloadUrl,
    expiresAt: Date.now() + 23 * 60 * 60 * 1000,
  };

  return {
    authToken: data.authorizationToken,
    apiUrl: data.apiUrl,
    downloadUrl: data.downloadUrl,
  };
}

/**
 * uploadImage — Accepts compressed image data, uploads to B2, returns URL
 * Request format: { imageData: base64_string, fileName: string, contentType: string }
 */
const uploadImage = onCall(
  { secrets: [B2_KEY_ID, B2_APP_KEY, B2_BUCKET_ID, B2_BUCKET_NAME] },
  async (request) => {
    // Require authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to upload images."
      );
    }

    const { imageData, fileName, contentType } = request.data;

    if (!imageData || !fileName) {
      throw new HttpsError(
        "invalid-argument",
        "imageData and fileName are required"
      );
    }

    try {
      // Get secret values and trim whitespace from Secret Manager
      const keyId = B2_KEY_ID.value();
      const appKey = B2_APP_KEY.value();
      const bucketId = String(B2_BUCKET_ID.value() || "").trim();
      const bucketName = String(B2_BUCKET_NAME.value() || "").trim();

      if (!bucketId || !bucketName) {
        throw new HttpsError("failed-precondition", "B2 bucket configuration missing");
      }

      console.log(`Uploading ${fileName} to bucket ${bucketName}`);

      // Step 1: Get B2 authorization
      const { authToken, apiUrl } = await b2Authorize(keyId, appKey);
      console.log(`B2 auth successful. API URL: ${apiUrl}`);

      // Step 2: Get upload URL from B2
      console.log(`Getting upload URL for bucket ${bucketId}...`);
      const uploadUrlResponse = await fetchWithRetry(
        `${apiUrl}/b2api/v2/b2_get_upload_url`,
        {
          method: "POST",
          headers: {
            Authorization: authToken,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            bucketId: bucketId,
          }),
        }
      );

      if (!uploadUrlResponse.ok) {
        const errorBody = await uploadUrlResponse.text();
        throw new HttpsError("internal", `Failed to get B2 upload URL: ${uploadUrlResponse.status} - ${errorBody}`);
      }

      const uploadUrlData = await uploadUrlResponse.json();
      const uploadUrl = uploadUrlData.uploadUrl;
      const uploadAuthToken = uploadUrlData.authorizationToken;

      console.log(`Got upload URL: ${uploadUrl}`);

      // Step 3: Convert base64 to buffer
      const imageBuffer = Buffer.from(imageData, "base64");

      // Step 4: Calculate SHA1 hash for B2 verification
      const sha1Hash = crypto
        .createHash("sha1")
        .update(imageBuffer)
        .digest("hex");

      console.log(`Image size: ${imageBuffer.length} bytes, SHA1: ${sha1Hash}`);

      // Step 5: Upload to B2
      console.log(`Uploading file to B2...`);
      const uploadResponse = await fetchWithRetry(uploadUrl, {
        method: "POST",
        headers: {
          Authorization: uploadAuthToken,
          "X-Bz-File-Name": encodeURIComponent(fileName),
          "Content-Type": contentType || "application/octet-stream",
          "X-Bz-Content-Sha1": sha1Hash,
        },
        body: imageBuffer,
      });

      if (!uploadResponse.ok) {
        const errorBody = await uploadResponse.text();
        throw new HttpsError("internal", `B2 upload failed: ${uploadResponse.status} - ${errorBody}`);
      }

      const fileData = await uploadResponse.json();

      console.log(`File uploaded successfully: ${fileData.fileName} (ID: ${fileData.fileId})`);

      // Step 6: Construct and return the file URL
      const fileUrl = `${b2AuthCache.downloadUrl}/file/${bucketName}/${fileData.fileName}`;

      return {
        success: true,
        url: fileUrl,
        fileName: fileData.fileName,
        fileId: fileData.fileId,
      };
    } catch (error) {
      console.error("Error uploading image:", error);
      throw new HttpsError("internal", `Image upload failed: ${error.message}`);
    }
  }
);

module.exports = {
  uploadImage,
};
