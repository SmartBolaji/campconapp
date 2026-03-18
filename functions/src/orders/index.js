const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { sendPushToUser } = require("../helpers");

const onOrderUpdated = onDocumentUpdated("orders/{orderId}", async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;
  if (before.status === after.status) return;

  const title = "Order Update";
  const body = `Order status changed to ${after.status || "updated"}.`;

  await Promise.all([
    sendPushToUser({
      userId: after.buyerId,
      category: "orders",
      title,
      body,
      data: { targetType: "order", targetId: event.params.orderId },
    }),
    sendPushToUser({
      userId: after.sellerId,
      category: "orders",
      title,
      body,
      data: { targetType: "order", targetId: event.params.orderId },
    }),
  ]);
});

module.exports = {
  onOrderUpdated,
};
