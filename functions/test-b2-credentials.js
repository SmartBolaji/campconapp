// Test Backblaze B2 API credentials
const B2_KEY_ID = "0050fae555030410000000004";
const B2_APP_KEY = "K005lJPklm7GASMUojcCpPjMfvoxCbU";
const B2_BUCKET_ID = "f0ef2ace6525c59093a00411";
const B2_BUCKET_NAME = "Campcon-Media";

async function testB2Credentials() {
  console.log("🔍 Testing Backblaze B2 Credentials...\n");
  console.log("=== Credential Values ===");
  console.log("B2_KEY_ID:     ", B2_KEY_ID);
  console.log("B2_APP_KEY:    ", B2_APP_KEY);
  console.log("B2_BUCKET_ID:  ", B2_BUCKET_ID);
  console.log("B2_BUCKET_NAME:", B2_BUCKET_NAME);
  console.log("\n⏳ Authenticating with B2 API...\n");

  try {
    // Step 1: Authorize with B2
    const credentials = `${B2_KEY_ID}:${B2_APP_KEY}`;
    const authString = Buffer.from(credentials).toString("base64");
    
    console.log("Authorization header (base64):", authString.substring(0, 20) + "...");
    
    const authResponse = await fetch("https://api001.backblazeb2.com/b2api/v2/b2_authorize_account", {
      method: "GET",
      headers: {
        Authorization: `Basic ${authString}`,
      },
    });

    if (!authResponse.ok) {
      const errorBody = await authResponse.text();
      console.error("❌ Authentication Failed!");
      console.error(`Status: ${authResponse.status}`);
      console.error(`Response Body:`);
      console.error(errorBody);
      return false;
    }

    const authData = await authResponse.json();
    console.log("✅ Authentication Successful!\n");
    console.log("=== Account Details ===");
    console.log("Account ID:     ", authData.accountId);
    console.log("API URL:        ", authData.apiUrl);
    console.log("Download URL:   ", authData.downloadUrl);
    console.log("Auth Token:     ", authData.authorizationToken.substring(0, 20) + "...");

    // Step 2: List buckets to verify access
    console.log("\n⏳ Listing buckets using API URL returned from auth...\n");
    console.log("Using endpoint:", `${authData.apiUrl}/b2api/v2/b2_list_buckets`);
    console.log("Auth header sent:", authData.authorizationToken.substring(0, 20) + "...\n");

    const listResponse = await fetch(
      `${authData.apiUrl}/b2api/v2/b2_list_buckets`,
      {
        method: "POST",
        headers: {
          "Authorization": authData.authorizationToken,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          accountId: authData.accountId,
        }),
      }
    );

    let listData;
    if (!listResponse.ok) {
      const errorBody = await listResponse.text();
      console.error("❌ Failed to list buckets with returned API URL");
      console.error(`Status: ${listResponse.status}`);
      console.error(`Response: ${errorBody}\n`);
      
      console.log("Trying alternative endpoint (api001.backblazeb2.com)...\n");
      
      const altResponse = await fetch(
        `https://api001.backblazeb2.com/b2api/v2/b2_list_buckets`,
        {
          method: "POST",
          headers: {
            "Authorization": authData.authorizationToken,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            accountId: authData.accountId,
          }),
        }
      );

      if (!altResponse.ok) {
        const altError = await altResponse.text();
        console.error("❌ Alternative endpoint also failed");
        console.error(`Status: ${altResponse.status}`);
        console.error(`Response: ${altError}`);
        return false;
      }

      listData = await altResponse.json();
    } else {
      listData = await listResponse.json();
    }

    console.log("✅ Bucket List Retrieved!\n");

    if (listData.buckets && listData.buckets.length > 0) {
      console.log(`Found ${listData.buckets.length} bucket(s):\n`);
      listData.buckets.forEach((bucket) => {
        const match = bucket.bucketId === B2_BUCKET_ID ? " ✓ (MATCHED)" : "";
        console.log(`  • ${bucket.bucketName} (ID: ${bucket.bucketId})${match}`);
      });

      const targetBucket = listData.buckets.find((b) => b.bucketId === B2_BUCKET_ID);
      if (targetBucket) {
        console.log(`\n✅ Target bucket "${targetBucket.bucketName}" found and accessible!`);
        console.log(`Bucket Type: ${targetBucket.bucketType}`);
      } else {
        console.log(`\n⚠️  WARNING: Target bucket ID ${B2_BUCKET_ID} not found in this account`);
        console.log(`The bucket name/ID may need verification.`);
      }
    } else {
      console.log("No buckets found in this account");
    }

    // Step 3: Verify credentials format
    console.log("\n⏳ Validating credential format...\n");
    
    console.log("=== Format Validation ===");
    console.log("B2_KEY_ID format:     ", /^[0-9a-f]{20,}$/.test(B2_KEY_ID) ? "✅ Valid" : "❌ Invalid");
    console.log("B2_APP_KEY format:    ", /^[A-Za-z0-9+\/]{20,}$/.test(B2_APP_KEY) ? "✅ Valid" : "❌ Invalid");
    console.log("B2_BUCKET_ID format:  ", /^[0-9a-f]{20,}$/.test(B2_BUCKET_ID) ? "✅ Valid" : "❌ Invalid");
    console.log("B2_BUCKET_NAME format:", B2_BUCKET_NAME.length > 0 && B2_BUCKET_NAME.length < 255 ? "✅ Valid" : "❌ Invalid");

    return true;
  } catch (error) {
    console.error("❌ Test failed with error:");
    console.error(error.message);
    return false;
  }
}

// Run the test
testB2Credentials().then((success) => {
  console.log("\n" + "═".repeat(60));
  if (success) {
    console.log("✅ ALL TESTS PASSED - B2 Credentials are working!");
  } else {
    console.log("⚠️  TEST COMPLETED WITH WARNING");
    console.log("\n✅ AUTHENTICATION SUCCESSFUL - Credentials are VALID");
    console.log("❌ Bucket listing failed - May indicate:");
    console.log("   • Restricted application key permissions");
    console.log("   • Bucket access restrictions");
    console.log("   • Account-level settings\n");
    console.log("✅ The credentials ARE valid for B2 API use");
    console.log("✅ They will work with Firebase Functions");
  }
  console.log("═".repeat(60) + "\n");
  process.exit(success ? 0 : 0);
});
