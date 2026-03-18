const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { sendPushToUser } = require("../helpers");

const onNotificationCreated = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const categoryMap = {
      like: "social",
      comment: "social",
      reply: "social",
      follow: "social",
      mention: "social",
      share: "social",
      marketplacePurchase: "orders",
      marketplaceInterest: "orders",
      eventInterested: "events",
      eventAttending: "events",
      message: "messages",
      task: "tasks",
    };

    const category = categoryMap[data.type] || "social";
    await sendPushToUser({
      userId: data.recipientId,
      category,
      title: data.title || "Campcon",
      body: data.body || "",
      data: {
        targetType: data.targetType || "notification",
        targetId: data.targetId || "",
        notificationId: event.params.notificationId,
      },
    });
  }
);

module.exports = {
  onNotificationCreated,
};
