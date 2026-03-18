const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const { hashOTP, generateOTP, buildEmailHTML } = require("../helpers");

const db = admin.firestore();
const RESEND_API_KEY = defineSecret("RESEND_API_KEY");

/**
 * sendOTP — Generates a 6-digit OTP, stores its SHA-256 hash + expiry in
 * Firestore, and emails the plaintext code via the Resend API.
 */
const sendOTP = onCall({ secrets: [RESEND_API_KEY] }, async (request) => {
  const email = request.data?.email?.trim().toLowerCase();
  if (!email) {
    throw new HttpsError("invalid-argument", "Email is required.");
  }

  // Rate-limit: max 5 OTP requests per email per hour
  const recentDoc = await db.collection("otps").doc(email).get();
  if (recentDoc.exists) {
    const prevData = recentDoc.data();
    const requestCount = prevData.requestCount || 0;
    const windowStart = prevData.windowStart || 0;
    const oneHourAgo = Date.now() - 60 * 60 * 1000;

    if (windowStart > oneHourAgo && requestCount >= 5) {
      throw new HttpsError(
        "resource-exhausted",
        "Too many OTP requests. Please try again later."
      );
    }
  }

  // Generate & hash
  const otp = generateOTP();
  const otpHashed = hashOTP(otp);
  const expiry = Date.now() + 10 * 60 * 1000; // 10 minutes

  // Persist to Firestore
  const windowStart =
    recentDoc.exists &&
    (recentDoc.data().windowStart || 0) > Date.now() - 60 * 60 * 1000
      ? recentDoc.data().windowStart
      : Date.now();

  await db.collection("otps").doc(email).set({
    otpHash: otpHashed,
    expiry: expiry,
    attempts: 0,
    requestCount: admin.firestore.FieldValue.increment(1),
    windowStart: windowStart,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send email via Resend
  const resendApiKey = RESEND_API_KEY.value();
  if (!resendApiKey) {
    throw new HttpsError(
      "failed-precondition",
      "Email service is not configured."
    );
  }

  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: "Bearer " + resendApiKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: "Campcon <no-reply@campcon.app>",
      to: email,
      subject: "Your Campcon Verification Code",
      html: buildEmailHTML(otp),
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    console.error("Resend API error", { status: response.status, body: body });
    throw new HttpsError("internal", "Failed to send verification email.");
  }

  console.log("OTP sent to " + email);
  return { success: true };
});

/**
 * verifyOTP — Checks the user-supplied OTP against the stored hash.
 * Enforces a maximum of 5 verification attempts before invalidating.
 */
const verifyOTP = onCall(async (request) => {
  const email = request.data?.email?.trim().toLowerCase();
  const otp = request.data?.otp;

  if (!email || !otp) {
    throw new HttpsError("invalid-argument", "Email and OTP are required.");
  }

  const docRef = db.collection("otps").doc(email);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new HttpsError(
      "not-found",
      "No verification code found. Please request a new one."
    );
  }

  const otpData = doc.data();

  // Check expiry
  if (Date.now() > otpData.expiry) {
    await docRef.delete();
    throw new HttpsError(
      "deadline-exceeded",
      "Verification code has expired. Please request a new one."
    );
  }

  // Check max attempts
  if ((otpData.attempts || 0) >= 5) {
    await docRef.delete();
    throw new HttpsError(
      "resource-exhausted",
      "Too many failed attempts. Please request a new code."
    );
  }

  // Verify hash
  const suppliedHash = hashOTP(otp);
  if (suppliedHash !== otpData.otpHash) {
    await docRef.update({
      attempts: admin.firestore.FieldValue.increment(1),
    });
    throw new HttpsError("permission-denied", "Invalid verification code.");
  }

  // Success — clean up
  await docRef.delete();
  console.log("OTP verified for " + email);
  return { success: true, verified: true };
});

module.exports = {
  sendOTP,
  verifyOTP,
};
