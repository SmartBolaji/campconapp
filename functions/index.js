// ─── Firebase Initialization ──────────────────────────────────────
const admin = require("firebase-admin");
admin.initializeApp();

// ─── Import Modules ───────────────────────────────────────────────
const { sendOTP, verifyOTP } = require("./src/auth");
const { uploadImage } = require("./src/storage");
const { joinRandomChatQueue, onRandomMessageCreated, onDirectMessageCreated } = require("./src/chat");
const { onNotificationCreated } = require("./src/notifications");
const { onOrderUpdated } = require("./src/orders");
const { backfillPostCounts, verifyPostCounts } = require("./backfillPostCounts");
// const { sendEventAndTaskReminders } = require("./src/events-tasks"); // DISABLED

// ─── Export Functions ─────────────────────────────────────────────
// Auth functions
exports.sendOTP = sendOTP;
exports.verifyOTP = verifyOTP;

// Storage functions
exports.uploadImage = uploadImage;

// Chat functions
exports.joinRandomChatQueue = joinRandomChatQueue;
exports.onRandomMessageCreated = onRandomMessageCreated;
exports.onDirectMessageCreated = onDirectMessageCreated;

// Notification functions
exports.onNotificationCreated = onNotificationCreated;

// Order functions
exports.onOrderUpdated = onOrderUpdated;

// Events & Tasks functions (CURRENTLY DISABLED - see src/events-tasks/index.js)
// exports.sendEventAndTaskReminders = sendEventAndTaskReminders;

// Data migration functions
exports.backfillPostCounts = backfillPostCounts;
exports.verifyPostCounts = verifyPostCounts;
