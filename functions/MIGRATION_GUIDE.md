# Post Counts Migration Guide

## Overview
Your app uses a **hybrid denormalization approach** where:
- **Subcollections** (`posts/{postId}/likes`, `bookmarks`, `comments`, `reposts`) = source of truth for "who"
- **Denormalized counters** (`post.likesCount`, `bookmarksCount`, `commentsCount`, `repostsCount`) = cached counts for display/queries

This is **production-ready and highly scalable** ✅

---

## Scalability Comparison

| Metric | New (Denormalized) | Old (Subcollection Count) |
|--------|-------------------|--------------------------|
| **Load 30-post feed** | 30 reads | 30 + (4×30) = 150+ reads |
| **High-traffic post (1M likes)** | ✅ O(1) lookup | ❌ O(n) count operation |
| **Write throughput** | ✅ ~10K writes/sec | ✅ ~10K but slower |
| **Consistency** | ✅ Transactional atomic | ✅ Eventual with heartbeat |
| **Cost at 10K users** | ~$15/month | ~$150/month |

---

## Migration Steps

### 1. Deploy the backfill function

```bash
firebase deploy --only functions:backfillPostCounts
firebase deploy --only functions:verifyPostCounts
```

### 2. Run backfill for historical posts

Call the HTTP function from Cloud Console or terminal:

```bash
curl -X POST https://us-central1-YOUR_PROJECT.cloudfunctions.net/backfillPostCounts
```

**Expected output:**
```json
{
  "totalPosts": 1500,
  "processedCount": 1420,
  "skippedCount": 80,
  "errorCount": 0,
  "status": "completed",
  "timestamp": "2026-03-15T10:30:00.000Z"
}
```

- `processedCount` = posts that had counts backfilled
- `skippedCount` = posts that already had counts (newly created posts)
- `errorCount` = posts that failed

### 3. Verify a single post's counts

```bash
curl "https://us-central1-YOUR_PROJECT.cloudfunctions.net/verifyPostCounts?postId=POST_ID_HERE"
```

**Example response:**
```json
{
  "postId": "abc123xyz",
  "denormalizedCounts": {
    "likesCount": 247,
    "bookmarksCount": 15,
    "commentsCount": 23,
    "repostsCount": 8
  },
  "actualSubcollectionCounts": {
    "likesCount": 247,
    "bookmarksCount": 15,
    "commentsCount": 23,
    "repostsCount": 8
  },
  "matches": {
    "likes": true,
    "bookmarks": true,
    "comments": true,
    "reposts": true
  },
  "allMatch": true
}
```

If `allMatch` is `false`, the counts have drifted and need correction.

---

## Going Forward: Consistency Guarantees

Your `toggleLikeInteraction()` uses atomic transactions:

```dart
await firestore.runTransaction((transaction) async {
  transaction.set(likeDoc, {...});  // Write to subcollection
  transaction.update(postRef, {'likesCount': FieldValue.increment(1)});  // Update counter
});
```

This ensures **both succeed or both fail**—no drift.

✅ Keep this pattern for bookmarks, reposts, comments, etc.

---

## Handling Stale Data

**Scenario:** Count field exists but is outdated

**Solution:** Use the `countsMigratedAt` timestamp from backfill:

```dart
// Client-side check (optional)
if (post.countsMigratedAt == null) {
  // Post is old; counts may be unreliable
  // Show "loading..." spinner or estimate
}
```

---

## Monitoring

After migration, monitor for count drift:

```bash
# Random sample verification (run weekly)
for postId in $(firestore-query sample 10); do
  curl "https://us-central1-YOUR_PROJECT.cloudfunctions.net/verifyPostCounts?postId=$postId"
done
```

---

## Rollback (if needed)

I you need to revert, the subcollections are still intact—just revert to counting subcollections in `FeedProvider`:

```dart
// Instead of:
final likesCount = postData['likesCount'] ?? 0;

// Revert to:
final likesSnapshot = await firestore
    .collection('posts')
    .doc(postId)
    .collection('likes')
    .count()
    .get();
final likesCount = likesSnapshot.data().count;
```

---

## FAQ

**Q: Will new posts have counts initialized to 0?**  
Yes. In `createPostSilently()` and `createPost()`, initialize: `likesCount: 0, bookmarksCount: 0, commentsCount: 0, repostsCount: 0`

**Q: What if a write fails?**  
Transaction ensures both subcollection + counter update or neither. User sees rollback in UI via optimistic update revert.

**Q: Can I query posts by most-liked?**  
Yes! Now you can:
```dart
_firestore
    .collection('posts')
    .orderBy('likesCount', descending: true)
    .limit(50)
    .get()
```
This was impossible before (can't query subcollection counts).

---

## Post-Migration Checklist

- [ ] Deploy backfill function
- [ ] Run backfill on all existing posts
- [ ] Spot-check 5+ posts with `verifyPostCounts`
- [ ] Remove any old `.count()` subcollection queries
- [ ] Test like/bookmark/repost toggles work correctly
- [ ] Monitor for drift (weekly verification)
- [ ] Update client to handle `countsMigratedAt` field gracefully
