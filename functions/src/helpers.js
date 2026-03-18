const crypto = require("crypto");
const admin = require("firebase-admin");

const db = admin.firestore();

/** Hash an OTP with SHA-256 */
function hashOTP(otp) {
  return crypto.createHash("sha256").update(otp).digest("hex");
}

/** Generate a cryptographically secure 6-digit OTP */
function generateOTP() {
  const buffer = crypto.randomBytes(4);
  const num = (buffer.readUInt32BE(0) % 900000) + 100000;
  return num.toString();
}

/** Build the branded HTML email template */
function buildEmailHTML(otp) {
  return `
    <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
      <div style="text-align: center; padding: 20px 0;">
        <h1 style="color: #EFA101; margin: 0;">Campcon</h1>
        <p style="color: #666; margin-top: 5px;">Connect with students</p>
      </div>
      <div style="background: #f9f9f9; border-radius: 12px; padding: 30px; text-align: center;">
        <h2 style="color: #333; margin-bottom: 10px;">Verify Your Email</h2>
        <p style="color: #666; margin-bottom: 25px;">
          Use the code below to verify your email address and complete your registration.
        </p>
        <div style="background: #fff; border: 2px dashed #EFA101; border-radius: 8px; padding: 20px; margin: 20px 0;">
          <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #EFA101;">
            ${otp}
          </span>
        </div>
        <p style="color: #999; font-size: 13px; margin-top: 20px;">
          This code expires in <strong>10 minutes</strong>.
        </p>
      </div>
      <div style="text-align: center; padding: 20px 0; color: #999; font-size: 12px;">
        <p>If you didn't request this code, you can safely ignore this email.</p>
        <p>&copy; ${new Date().getFullYear()} Campcon. All rights reserved.</p>
      </div>
    </div>
  `;
}

function toDateSafe(value) {
  if (!value) return null;
  if (value.toDate && typeof value.toDate === "function") return value.toDate();
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

async function sendPushToUser({ userId, title, body, data = {}, category = "messages" }) {
  if (!userId) return;

  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) return;

  const userData = userDoc.data() || {};
  const prefs = userData.notificationPreferences || {};
  if (Object.prototype.hasOwnProperty.call(prefs, category) && prefs[category] === false) {
    return;
  }

  const tokens = [];
  if (userData.fcmToken) tokens.push(userData.fcmToken);
  if (Array.isArray(userData.fcmTokens)) {
    userData.fcmTokens.forEach((token) => {
      if (typeof token === "string" && token.trim()) tokens.push(token);
    });
  }

  const dedupedTokens = [...new Set(tokens)];
  if (!dedupedTokens.length) return;

  const message = {
    tokens: dedupedTokens,
    notification: {
      title: title || "Campcon",
      body: body || "",
    },
    data: {
      category,
      ...Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, v == null ? "" : String(v)])
      ),
    },
  };

  const response = await admin.messaging().sendEachForMulticast(message);

  const invalidTokens = [];
  response.responses.forEach((res, index) => {
    if (!res.success) {
      const code = res.error?.code || "";
      if (
        code.includes("registration-token-not-registered") ||
        code.includes("invalid-registration-token")
      ) {
        invalidTokens.push(dedupedTokens[index]);
      }
    }
  });

  if (invalidTokens.length) {
    await db.collection("users").doc(userId).set(
      {
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
      },
      { merge: true }
    );
  }
}

module.exports = {
  hashOTP,
  generateOTP,
  buildEmailHTML,
  toDateSafe,
  sendPushToUser,
};
