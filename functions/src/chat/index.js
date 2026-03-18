const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { sendPushToUser } = require("../helpers");

const db = admin.firestore();

const joinRandomChatQueue = onCall(async (request) => {
  const userId = request.data?.userId || request.auth?.uid;
  if (!userId) {
    throw new HttpsError("invalid-argument", "userId is required.");
  }

  await db.collection("random_chat_queue").doc(userId).set(
    {
      userId,
      status: "waiting",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  const waiting = await db
    .collection("random_chat_queue")
    .where("status", "==", "waiting")
    .orderBy("createdAt", "asc")
    .limit(20)
    .get();

  const partnerDoc = waiting.docs.find((doc) => doc.id !== userId);
  if (!partnerDoc) {
    return { matched: false };
  }

  const partnerId = partnerDoc.id;
  const sorted = [userId, partnerId].sort();
  const chatId = `${sorted[0]}_${sorted[1]}_${Date.now()}`;

  const batch = db.batch();
  batch.set(db.collection("random_chats").doc(chatId), {
    user1: sorted[0],
    user2: sorted[1],
    participants: sorted,
    isRevealed: false,
    revealRequests: {},
    status: "active",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    lastMessage: "",
  });

  batch.set(
    db.collection("random_chat_queue").doc(userId),
    {
      status: "matched",
      chatId,
      matchedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  batch.set(
    db.collection("random_chat_queue").doc(partnerId),
    {
      status: "matched",
      chatId,
      matchedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  await batch.commit();

  await Promise.all([
    sendPushToUser({
      userId,
      category: "messages",
      title: "Random Shot Match Found",
      body: "You have been paired in anonymous chat.",
      data: { targetType: "random_chat", chatId },
    }),
    sendPushToUser({
      userId: partnerId,
      category: "messages",
      title: "Random Shot Match Found",
      body: "You have been paired in anonymous chat.",
      data: { targetType: "random_chat", chatId },
    }),
  ]);

  return { matched: true, chatId, partnerId };
});

const onRandomMessageCreated = onDocumentCreated(
  "random_chats/{chatId}/messages/{messageId}",
  async (event) => {
    const messageData = event.data?.data();
    if (!messageData) return;

    const chatId = event.params.chatId;
    const senderId = messageData.senderId;
    const text = messageData.text || "New message";

    const chatDoc = await db.collection("random_chats").doc(chatId).get();
    if (!chatDoc.exists) return;

    const chat = chatDoc.data() || {};
    const recipientId = senderId === chat.user1 ? chat.user2 : chat.user1;
    if (!recipientId) return;

    await sendPushToUser({
      userId: recipientId,
      category: "messages",
      title: "New Random Shot Message",
      body: String(text).slice(0, 120),
      data: {
        targetType: "random_chat",
        targetId: chatId,
        senderId: senderId || "",
      },
    });
  }
);

const onDirectMessageCreated = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const chatId = event.params.chatId;
    const senderId = data.senderId;
    if (!senderId) return;

    const chatDoc = await db.collection("chats").doc(chatId).get();
    if (!chatDoc.exists) return;

    const chat = chatDoc.data() || {};
    const participants = Array.isArray(chat.participants) ? chat.participants : [];
    const recipientId = participants.find((id) => id !== senderId);
    if (!recipientId) return;

    const senderDoc = await db.collection("users").doc(senderId).get();
    const senderName = senderDoc.exists
      ? (senderDoc.data().name || senderDoc.data().username || "Someone")
      : "Someone";

    await sendPushToUser({
      userId: recipientId,
      category: "messages",
      title: senderName,
      body: String(data.text || data.message || "New message").slice(0, 120),
      data: {
        targetType: "message",
        targetId: chatId,
        senderId,
      },
    });
  }
);

module.exports = {
  joinRandomChatQueue,
  onRandomMessageCreated,
  onDirectMessageCreated,
};
