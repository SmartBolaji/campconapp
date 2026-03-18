const {
  HttpsError,
  onRequest,
} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

const firestore = admin.firestore();

/**
 * Cloud Function to backfill likesCount on existing posts from their likes subcollections.
 * Run once to populate historical data.
 */
exports.backfillPostCounts = onRequest(
  {
    timeoutSeconds: 540,
    memory: "512MB",
  },
  async (req, res) => {
    try {
      console.log("Starting backfill of post counts...");

      const postsSnapshot = await firestore.collection("posts").get();
      const totalPosts = postsSnapshot.size;

      console.log(`Found ${totalPosts} posts to process`);

      let processedCount = 0;
      let skippedCount = 0;
      let errorCount = 0;

      // Process posts in batches
      const batch = firestore.batch();
      let batchSize = 0;
      const BATCH_SIZE = 100; // Firestore batch limit

      for (const postDoc of postsSnapshot.docs) {
        try {
          const postId = postDoc.id;
          const postData = postDoc.data();

          // Skip if already has counts populated (from new posts)
          if (
            postData.likesCount > 0 ||
            postData.bookmarksCount > 0 ||
            postData.commentsCount > 0 ||
            postData.repostsCount > 0
          ) {
            console.log(`Skipping ${postId} - already has counts`);
            skippedCount++;
            continue;
          }

          // Count likes
          const likesSnapshot = await firestore
            .collection("posts")
            .doc(postId)
            .collection("likes")
            .count()
            .get();
          const likesCount = likesSnapshot.data().count;

          // Count bookmarks
          const bookmarksSnapshot = await firestore
            .collection("posts")
            .doc(postId)
            .collection("bookmarks")
            .count()
            .get();
          const bookmarksCount = bookmarksSnapshot.data().count;

          // Count comments
          const commentsSnapshot = await firestore
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .count()
            .get();
          const commentsCount = commentsSnapshot.data().count;

          // Count reposts
          const repostsSnapshot = await firestore
            .collection("posts")
            .doc(postId)
            .collection("reposts")
            .count()
            .get();
          const repostsCount = repostsSnapshot.data().count;

          // Add to batch
          batch.update(postDoc.ref, {
            likesCount: likesCount,
            bookmarksCount: bookmarksCount,
            commentsCount: commentsCount,
            repostsCount: repostsCount,
            countsMigratedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          batchSize++;
          processedCount++;

          // Commit batch when it reaches limit
          if (batchSize >= BATCH_SIZE) {
            await batch.commit();
            console.log(
              `Committed batch. Progress: ${processedCount}/${totalPosts}`
            );
            batchSize = 0;
          }
        } catch (error) {
          console.error(`Error processing post ${postDoc.id}:`, error);
          errorCount++;
        }
      }

      // Commit remaining batched updates
      if (batchSize > 0) {
        await batch.commit();
        console.log(`Committed final batch. Processed: ${processedCount}`);
      }

      const summary = {
        totalPosts,
        processedCount,
        skippedCount,
        errorCount,
        status: "completed",
        timestamp: new Date().toISOString(),
      };

      console.log("Backfill completed:", summary);
      res.status(200).json(summary);
    } catch (error) {
      console.error("Backfill function error:", error);
      res.status(500).json({
        error: error.message,
        status: "failed",
      });
    }
  });

/**
 * Verify that one post's counts are correct
 * Usage: /verifyPostCounts?postId=YOUR_POST_ID
 */
exports.verifyPostCounts = onRequest(async (req, res) => {
  try {
    const { postId } = req.query;

    if (!postId) {
      return res.status(400).json({ error: "postId query parameter required" });
    }

    const postDoc = await firestore.collection("posts").doc(postId).get();

    if (!postDoc.exists) {
      return res.status(404).json({ error: `Post ${postId} not found` });
    }

    const postData = postDoc.data();

    // Count from subcollections
    const likesCount = (
      await firestore
        .collection("posts")
        .doc(postId)
        .collection("likes")
        .count()
        .get()
    ).data().count;

    const bookmarksCount = (
      await firestore
        .collection("posts")
        .doc(postId)
        .collection("bookmarks")
        .count()
        .get()
    ).data().count;

    const commentsCount = (
      await firestore
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .count()
        .get()
    ).data().count;

    const repostsCount = (
      await firestore
        .collection("posts")
        .doc(postId)
        .collection("reposts")
        .count()
        .get()
    ).data().count;

    // Compare with denormalized fields
    const verification = {
      postId,
      denormalizedCounts: {
        likesCount: postData.likesCount || 0,
        bookmarksCount: postData.bookmarksCount || 0,
        commentsCount: postData.commentsCount || 0,
        repostsCount: postData.repostsCount || 0,
      },
      actualSubcollectionCounts: {
        likesCount,
        bookmarksCount,
        commentsCount,
        repostsCount,
      },
      matches: {
        likes:
          (postData.likesCount || 0) === likesCount,
        bookmarks:
          (postData.bookmarksCount || 0) === bookmarksCount,
        comments:
          (postData.commentsCount || 0) === commentsCount,
        reposts:
          (postData.repostsCount || 0) === repostsCount,
      },
      allMatch:
        (postData.likesCount || 0) === likesCount &&
        (postData.bookmarksCount || 0) === bookmarksCount &&
        (postData.commentsCount || 0) === commentsCount &&
        (postData.repostsCount || 0) === repostsCount,
    };

    res.status(200).json(verification);
  } catch (error) {
    console.error("Verification error:", error);
    res.status(500).json({
      error: error.message,
      status: "failed",
    });
  }
});
