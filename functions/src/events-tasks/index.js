// ⚠️  Event and Task reminder functions are currently disabled pending review
// These functions can be re-enabled when ready

// const { onSchedule } = require("firebase-functions/v2/scheduler");
// const admin = require("firebase-admin");
// const { toDateSafe, sendPushToUser } = require("../helpers");
//
// const db = admin.firestore();
//
// const sendEventAndTaskReminders = onSchedule(
//   {
//     schedule: "every 15 minutes",
//     timeZone: "Africa/Lagos",
//   },
//   async () => {
//     const now = new Date();
//     const reminderWindowMs = 8 * 60 * 1000;
//     const oneHourTarget = new Date(now.getTime() + 60 * 60 * 1000);
//     const oneDayTarget = new Date(now.getTime() + 24 * 60 * 60 * 1000);
//
//     const dispatchCollection = db.collection("reminder_dispatches");
//
//     const eventsSnap = await db.collection("events").limit(500).get();
//     for (const doc of eventsSnap.docs) {
//       const eventData = doc.data();
//       if (eventData.cancelled === true) continue;
//
//       const eventDate = toDateSafe(eventData.eventDate || eventData.date || eventData.startDate);
//       if (!eventDate) continue;
//
//       const diff1h = Math.abs(eventDate.getTime() - oneHourTarget.getTime());
//       const diff1d = Math.abs(eventDate.getTime() - oneDayTarget.getTime());
//
//       let windowTag = null;
//       if (diff1h <= reminderWindowMs) windowTag = "1h";
//       if (diff1d <= reminderWindowMs) windowTag = "1d";
//       if (!windowTag) continue;
//
//       const dispatchId = `event_${doc.id}_${windowTag}`;
//       const dispatchDoc = await dispatchCollection.doc(dispatchId).get();
//       if (dispatchDoc.exists) continue;
//
//       await dispatchCollection.doc(dispatchId).set({
//         type: "event",
//         eventId: doc.id,
//         windowTag,
//         createdAt: admin.firestore.FieldValue.serverTimestamp(),
//       });
//
//       const attendeesSnap = await db
//         .collection("events")
//         .doc(doc.id)
//         .collection("attendees")
//         .get();
//
//       const sends = attendeesSnap.docs.map((attendeeDoc) => {
//         const attendee = attendeeDoc.data() || {};
//         const userId = attendee.userId || attendee.uid || attendeeDoc.id;
//         return sendPushToUser({
//           userId,
//           category: "events",
//           title: "Event Reminder",
//           body: `${eventData.title || "Your event"} starts ${windowTag === "1h" ? "in 1 hour" : "in 1 day"}.`,
//           data: { targetType: "event", targetId: doc.id },
//         });
//       });
//
//       await Promise.all(sends);
//     }
//
//     const taskSnap = await db
//       .collection("tasks")
//       .where("isCompleted", "==", false)
//       .limit(1000)
//       .get();
//
//     for (const taskDoc of taskSnap.docs) {
//       const task = taskDoc.data() || {};
//       const dueDate = toDateSafe(task.dueDate);
//       if (!dueDate) continue;
//
//       const dueDiff = Math.abs(dueDate.getTime() - now.getTime());
//       if (dueDiff > reminderWindowMs) continue;
//
//       const dispatchId = `task_${taskDoc.id}_due`;
//       const dispatchDoc = await dispatchCollection.doc(dispatchId).get();
//       if (dispatchDoc.exists) continue;
//
//       await dispatchCollection.doc(dispatchId).set({
//         type: "task",
//         taskId: taskDoc.id,
//         createdAt: admin.firestore.FieldValue.serverTimestamp(),
//       });
//
//       if (task.isPersonal === false) {
//         const subscribersSnap = await db
//           .collection("taskReminders")
//           .doc(taskDoc.id)
//           .collection("subscribers")
//           .get();
//
//         await Promise.all(
//           subscribersSnap.docs.map((subscriberDoc) => {
//             const subscriber = subscriberDoc.data() || {};
//             const userId = subscriber.userId || subscriberDoc.id;
//             return sendPushToUser({
//               userId,
//               category: "tasks",
//               title: "Public Task Reminder",
//               body: `${task.title || "A public task"} is due now.`,
//               data: { targetType: "task", targetId: taskDoc.id },
//             });
//           })
//         );
//       } else if (task.hasReminder === true && task.userId) {
//         await sendPushToUser({
//           userId: task.userId,
//           category: "tasks",
//           title: "Task Reminder",
//           body: `${task.title || "Your task"} is due now.`,
//           data: { targetType: "task", targetId: taskDoc.id },
//         });
//       }
//     }
//   }
// );
//
// module.exports = {
//   sendEventAndTaskReminders,
// };

module.exports = {
  // sendEventAndTaskReminders - DISABLED
};
