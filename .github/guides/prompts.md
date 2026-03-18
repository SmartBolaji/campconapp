# Campcon - App Completion Prompts

## App Summary

**Campcon** is a campus social platform for university students (currently scoped to University of Ibadan) with five core modules:

| Module | Status |
|--------|--------|
| **Home Feed** (For You / Friends / Campus / Events) | ~90% complete |
| **Marketplace** (Items, Services, Orders, Reviews) | ~60% complete |
| **Events** (Create, Browse, Tickets, Manage) | ~65% complete |
| **Messaging** (1-on-1 DMs, Anonymous Chat) | ~80% complete |
| **Resources** (Academic files, Camplist tasks) | ~95% complete |
| **Notifications** | ~85% complete |
| **Profile & Settings** | ~60% complete |
| **Auth & Onboarding** | ~90% complete |

---

## What Works

- Auth flow (email OTP + Google sign-in + account setup wizard)
- Home feed with 3 algorithmic tabs (For You, Friends, Campus)
- Post creation with background upload + progress bar
- Marketplace browsing with masonry grid, sort/filter, category chips
- Product/service listing with multi-image upload
- Order placement with pickup center selection
- Buyer order tracking with status progress (market_cart.dart)
- Seller order management — accept/decline/process/ready/complete (sales_screen.dart)
- 1-on-1 DM messaging with real-time Firestore + Hive cache
- Image messages with upload progress overlay
- Message edit/delete with reply-to
- Resource browsing by faculty/department/level
- Task/camplist system (public + personal)
- Resource file + URL upload
- Event creation (single + multi-image, ticket tiers)
- Event browsing + attend/unattend
- Follow/unfollow with optimistic updates
- Profile screen with 4 tabs (Posts, Reposts, Media, Saved)
- Profile editing (name, username availability check, bio, avatar)
- In-app notification creation (likes, comments, follows, etc.)
- Search across all 5 contexts with recent + trending
- Pickup center application form
- Bottom navigation with animated indicators

---

## What's Broken / Incomplete

### Critical Bugs
1. `BuyerOrdersProvider._updateProductRating` writes to `'products'` collection but marketplace uses `'marketplace'`
2. `Product.fromJson` crashes on Firestore `Timestamp` for `createdAt`
3. `TaskModel.toJson()` omits `category` field
4. `OrderModel` missing 6+ fields written during order placement
5. `SearchProvider._searchNotifications` queries `'userId'` but notifications store `'recipientId'`
6. `NotificationHelper.createLikeNotification` uses unset static field → null assertion crash
7. `MessageBubble` edit/delete create orphan `ChatManager(currentUserId: '')` instances
8. `timeago.dart` uses "m" for both minutes and months
9. `TicketTierSelector` widget exists but is never rendered — multi-tier ticket buying is broken
10. `ticket_order_summary.dart` hardcodes "General Admission" ignoring tiers

### Missing Screens (files don't exist)
11. **Edit Event screen** — no file, no `updateEvent()` / `deleteEvent()` in provider
12. **Manage Event screen** — no organizer dashboard, analytics, attendance, earnings
13. **Edit Product/Service screen** — no file, no `updateProduct()` / `deleteProduct()` in provider
14. **Manage Orders screen** — seller has basic sales_screen but no per-product order management
15. **My Listings screen** — sellers can't view/manage their own listings
16. **Order Detail screen** — orders are inline cards only, no tap-to-expand detail
17. **My Tickets screen** — buyers can't view purchased event tickets
18. **Ticket Purchase Confirmation** — only a SnackBar after purchase, no confirmation/QR
19. **Account Information screen** — linked from menu but doesn't exist
20. **Password & Security screen** — linked from menu but doesn't exist
21. **Professional Account screen** — linked from menu but doesn't exist
22. **Payment/Payout screen** — `payment_screen.dart` is 0 bytes

### Empty / Commented-Out Files
23. **Post comments** — `post_comments_screen.dart` is 100% commented out (356 lines)
24. **Review screens** — `review_screen.dart` + `review_summary.dart` are 0-byte files
25. **Market chat** — `market_chat.dart` is 100% commented out (217 lines)
26. **Anonymous chat backend** — `ChatProvider` has 4 Firebase TODOs, nothing persists

### Stub / Empty Callbacks
27. Product description: "Edit Listing", "Manage Orders", "Message Provider" — all TODOs
28. Event description: "Edit Event", "Manage Event", "Message Organizer" — all TODOs
29. Seller info card: navigate to seller profile — TODO
30. Market cart: chat with seller — TODO
31. Sales screen: chat with buyer — TODO
32. Profile: share, copy link, report, block, message other user — all TODOs
33. Menu: Account Info, Password, Professional — empty onTap callbacks
34. Notification tap navigation — TODO, taps do nothing
35. Friends feed `onRepost` is a stub (debugPrint only)

### Missing UI Sections
36. **Related products** — not shown on product description page
37. **Related events** — not shown on event description page
38. **Product reviews display** — no rating/reviews section on product page
39. **Seller rating** — not shown on seller info card
40. **Product views count / posted date** — fields exist in model but not displayed
41. **"You have a ticket!" indicator** — commented out in attendee_stats_card.dart
42. **Organizer message button** — commented out in organizer_info_card.dart

### Security Issues
43. OTP generated & verified client-side (bypassable)
44. Resend API key hardcoded in client code
45. Backblaze credentials hardcoded in 6 providers
46. Insecure deterministic password generation in `auth_service.dart`

### Dead Code
47. `friends_draft.dart` — entirely commented out
48. `update_provider.dart` — entirely commented out
49. `message_chat_provider.dart` — entirely commented out
50. `dialog_widget.dart` — entirely commented out
51. `story_model.dart` — placeholder models conflicting with real ones

---

## Prompts (Copy & Use Sequentially)

### Phase 1 — Fix Critical Bugs (Prompts 1–4)

**Prompt 1: Fix Order & Rating Bugs**
> Fix `BuyerOrdersProvider._updateProductRating` — it writes to the `'products'` collection but marketplace products are stored in the `'marketplace'` collection. Also fix `OrderModel` to include all fields written during order placement: `pickupLocationId`, `pickupAddress`, `pickupPhone`, `pickupCenterOwnerId`, `hasReview`, `reviewId`. Update both `toJson` and `fromJson`.

**Prompt 2: Fix Model Bugs**
> Fix these model bugs: (1) `Product.fromJson` crashes when Firestore returns a `Timestamp` for `createdAt` — handle both `Timestamp` and `String` like `PostModel` does. (2) `TaskModel.toJson()` omits the `category` field — add it. (3) Add `copyWith` methods to `EventModel`, `Product`, `ResourceModel`, and `TaskModel`.

**Prompt 3: Fix Search, Notifications & Timeago**
> Fix `SearchProvider._searchNotifications` — it queries by field `'userId'` but notifications are stored with `'recipientId'`. Also fix `NotificationHelper.createLikeNotification` which uses the unset static `notifyProvider` field instead of the passed parameter — refactor all `NotificationHelper` methods to consistently use the passed `notifyProvider` parameter and remove the unused static field. Fix `timeago.dart` to use "mo" for months instead of "m" to avoid collision with minutes.

**Prompt 4: Fix MessageBubble & Repost Stub**
> Fix `MessageBubble._editMessage` and `_deleteMessage` — they create new `ChatManager` instances with `currentUserId: ''` instead of using the existing chat manager. Refactor to accept the parent's `ChatManager` instance as a parameter or access it through the provider. Also fix `friends_screen.dart` `onRepost` callback which is currently just a `debugPrint` stub — implement it like the identical logic in `for_you_screen.dart` and `campus_screen.dart`.

---

### Phase 2 — Security Fixes (Prompts 5–6)

**Prompt 5: Server-Side OTP**
> Move the OTP verification to a Firebase Cloud Function. Create a Cloud Function that: (1) generates a 6-digit OTP, (2) sends it via the Resend API (move the API key to Cloud Function secret key), (3) stores the OTP hash + expiry server-side, (4) has a verify endpoint that checks the OTP. Update `email_otp_service.dart` to call these Cloud Functions instead of generating/verifying OTPs client-side. Remove the hardcoded Resend API key from client code.

**Prompt 6: Centralize Backblaze Credentials**
> Create a centralized `BackblazeService` singleton that loads credentials from `secret key` instead of hardcoding them. Replace the hardcoded `keyId`, `applicationKey`, and `bucketId` in `AuthProvider`, `PostProvider`, `MarketPostProvider`, `EventProvider`, `EventCreateProvider`, and `ResourcePostProvider` with calls to this singleton. Also add B2 auth token caching (tokens last 24h) and switch `readAsBytesSync()` to `readAsBytes()` in `backblaze.dart`.

---

### Phase 3 — Core Missing Features (Prompts 7–12)

**Prompt 7: Post Comments System**
> Implement the post comments system. The file `post_comments_screen.dart` exists but is 100% commented out — delete all commented code and rewrite from scratch. Create it with: (1) a real-time Firestore stream from `posts/{postId}/comments` subcollection, (2) a sticky bottom comment input bar with user avatar and send button, (3) comment cards showing user avatar, name, verified badge, text, timestamp, like button with count, (4) reply-to-comment support (nested one level with indentation), (5) long-press to delete own comments with confirmation, (6) optimistic UI updates. Create a `CommentModel` with fields: `commentId`, `postId`, `userId`, `text`, `createdAt`, `likes`, `replyTo`, `replyToUsername`. Wire it into the existing `onComment` callbacks in `for_you_screen.dart`, `campus_screen.dart`, and `friends_screen.dart`. Use `AppTheme` colors and Cabin font throughout.

**Prompt 8: Notification Tap Navigation**
> Implement notification tap navigation. In `notification_screen.dart`, add navigation logic based on `notification.targetType`: (1) 'post' → navigate to post comments screen with the post, (2) 'follow' → navigate to user profile, (3) 'comment' → navigate to post comments, (4) 'order' → navigate to market cart / order detail, (5) 'event' → navigate to event description, (6) 'message' → navigate to chat with the sender, (7) 'share' → navigate to post. Create a `NavigationHelper` utility class to centralize all navigation logic, use it here and across the app wherever navigation is stubbed.

**Prompt 9: Chat Navigation Everywhere**
> Implement the chat navigation that's stubbed across the app. Using `NavigationHelper`, create an `openChat(context, currentUserId, otherUserId)` method that checks for existing chat in Firestore, creates one if needed, then navigates to the `Message` screen. Wire it into all 6 broken callbacks: (1) `product_decription.dart` — "Message Provider" button, (2) `market_cart.dart` — chat icon on order cards, (3) `sales_screen.dart` — chat icon on order cards, (4) `event_description.dart` — uncomment the organizer message button in `organizer_info_card.dart` and wire it, (5) `profile_screen.dart` — "Message" button for other users, (6) `seller_info_card.dart` — navigate to seller profile on arrow tap.

**Prompt 10: Review System**
> Implement the marketplace review system: (1) Create `review_screen.dart` — a full-page form to submit a review with interactive star rating (1-5, using tappable star icons), text review input, and optional photo upload. It should be navigated to from market_cart.dart after buyer confirms order receipt (replace the inline review dialog). (2) Create `review_summary.dart` — displays all reviews for a product: average rating with star display, rating distribution bar chart (5 bars showing count per star), individual review cards (user avatar, name, star rating, review text, date), sort options (newest, highest, lowest). (3) Add a "Reviews" section to `product_decription.dart` showing average rating + review count with a "See All Reviews" link to `review_summary.dart`. (4) Add `averageRating` and `reviewCount` fields to `Product` model. (5) Fix `BuyerOrdersProvider._updateProductRating` to write to the `'marketplace'` collection.

**Prompt 11: Edit Product/Service**
> Implement edit functionality for marketplace listings. (1) Create `edit_product_screen.dart` — a pre-populated form that mirrors `post_product_screen.dart` layout, loaded with the existing product's data (images, name, description, price, category, location, stock, discount). Allow the seller to update any field, add/remove images, and save. (2) Add `updateProduct(productId, data)` and `deleteProduct(productId)` methods to `MarketPostProvider`. On save, update the Firestore `'marketplace'` document and uploaded images. (3) Wire the "Edit Listing" button in `product_decription.dart` to navigate to `EditProductScreen` with the current product. (4) Add a "Delete Listing" option with confirmation dialog. (5) After saving, refresh the marketplace list and navigate back. Support both items and services (detect via `product.isItem`).

**Prompt 12: Edit Event**
> Implement edit functionality for events. (1) Create `edit_event_screen.dart` — a pre-populated form that mirrors `create_event_screen.dart`, loaded with the existing event's data (images, title, description, location, category, date/time, pricing, tiers). Allow the organizer to update any field and save. (2) Add `updateEvent(eventId, data)` and `deleteEvent(eventId)` methods to `EventProvider`. On save, update the Firestore `'events'` document. (3) Wire the "Edit Event" button in `event_bottom_action.dart` to navigate to `EditEventScreen`. (4) Add a "Cancel Event" option that sets a `cancelled` status, notifies all attendees, and prevents new ticket purchases. (5) Add `EventModel.copyWith()` method if not already present. (6) After saving, refresh the events list and return to the updated description page.

---

### Phase 4 — Manage Event & Manage Orders (Prompts 13–16)

**Prompt 13: Manage Event — Organizer Dashboard**
> Create `manage_event_screen.dart` — a comprehensive organizer dashboard. Wire the "Manage Event" button in `event_bottom_action.dart` to navigate here. The screen should have tabs or sections for: (1) **Overview** — event summary card (title, date, status), total attendees count, total tickets sold, total revenue, quick stats. (2) **Attendees** — scrollable list from `events/{eventId}/attendees` subcollection, showing name, avatar, ticket type, check-in status with a toggle to mark present/absent; search/filter bar; total count header. (3) **Check-In** — a QR code scanner (use `mobile_scanner` package) that reads a ticket ID and marks the attendee as checked in; show success/already-checked-in/invalid feedback. (4) **Earnings** — total revenue card, breakdown by ticket tier (if multi-tier), list of individual purchases (buyer name, amount, date, payment method). Add needed methods to `EventProvider`: `getAttendees(eventId)`, `toggleCheckIn(eventId, attendeeId)`, `getTicketPurchases(eventId)`.

**Prompt 14: Ticket Purchase Confirmation & My Tickets**
> (1) Create `ticket_confirmation_screen.dart` — shown after successful ticket purchase instead of just a SnackBar. Should display: success animation/icon, event title and date, ticket type and quantity, a generated ticket ID/reference, a QR code containing the ticket reference (use `qr_flutter` package), "Add to Calendar" button, "Share Ticket" button, "Done" button to return. (2) Create `my_tickets_screen.dart` — lists all the current user's purchased event tickets. Each ticket card shows: event image, title, date, ticket type, ticket reference, QR code mini-preview, status (upcoming/used/expired based on event date and check-in). Tap opens ticket detail with full QR code. (3) Connect `ticket_order_summary.dart` confirmation to navigate to the new confirmation screen. (4) Add a "My Tickets" item to `menu_screen.dart` under a new "Events" section. (5) Fix `ticket_quantity_selector.dart` to use `TicketTierSelector` when event has `hasMultipleTiers`, and fix `ticket_order_summary.dart` to show the actual selected tier name instead of hardcoded "General Admission".

**Prompt 15: Manage Orders — Seller Dashboard Enhancement**
> Enhance `sales_screen.dart` with a full seller management experience: (1) Add a **per-product order filter** — when navigated from product_decription.dart "Manage Orders", show only orders for that product (pass `productId` parameter); add a top chip showing the product name with an "×" to clear filter. (2) Add a **My Listings** tab (or section) showing all the seller's active marketplace listings as a grid, each card with edit/delete/toggle-active actions. Tapping a listing filters orders for that product. (3) Enhance the **revenue stats card** — add a "View Earnings" button that opens an earnings breakdown: revenue by product, revenue chart by week/month (use `fl_chart` package), top-selling products list. (4) Uncomment the refresh button in the header. (5) Wire the chat buttons on order cards to use `NavigationHelper.openChat`.

**Prompt 16: Order Detail Screen**
> Create `order_detail_screen.dart` — a full-page order view accessible by tapping an order card in `market_cart.dart` (buyer) or `sales_screen.dart` (seller). Should display: (1) **Order header** — order ID, date, status badge (with color). (2) **Product section** — product image, name, quantity, unit price, total price. (3) **Order timeline** — visual timeline showing all status changes with timestamps (placed → confirmed → processing → ready → completed, or cancelled at any point with reason). (4) **Pickup details** — pickup center name, address, phone, with a "Get Directions" button launching Google Maps. (5) **Payment info** — payment method, payment status. (6) **Seller/Buyer info** — avatar, name, with "Message" and "View Profile" buttons. (7) **Order notes** — if provided. (8) **Actions** — contextual: buyer can cancel (if pending), confirm received (if ready), leave review (if completed); seller can advance status, cancel with reason. Wire navigation to this screen from order cards in both `market_cart.dart` and `sales_screen.dart`.

---

### Phase 5 — Product & Event Description Enhancements (Prompts 17–18)

**Prompt 17: Product Description — Related Products, Floating Checkout, Polish**
> Enhance `product_decription.dart` with: (1) **Related Products section** — at the bottom, show a horizontal scrollable list of products from the same category (query `'marketplace'` collection where `category == product.category` and `id != product.id`, limit 10). Use compact ProductCard-style widgets. Title: "Similar Items" or "Similar Services". (2) **Floating checkout button** — for buyer viewing items: replace the inline bottom action with a floating action button / persistent bottom bar that stays visible as user scrolls through description and related products. Show "Buy Now — ₦price" with cart icon. Only show when all required selections (quantity, pickup, payment) are made; otherwise show "Select options". (3) **Product metadata** — show views count (from `product.views`), posted date (from `product.createdAt` using timeago), and share button in the header. (4) **Seller rating** — show average seller rating (stars + count) on `seller_info_card.dart` below the seller name. (5) Uncomment and wire the school row in event_details_card.dart if applicable context exists.

**Prompt 18: Event Description — Related Events, Floating Ticket, Polish**
> Enhance `event_description.dart` with: (1) **Related Events section** — at the bottom, show a horizontal scrollable list of events in the same category or by the same organizer (query `'events'` collection, limit 10). Use compact EventCard widgets. (2) **Floating ticket button** — for buyer viewing paid events with `sellOnCampcon`: replace the bottom action bar with a persistent floating bottom bar showing "Get Tickets — ₦price" that stays visible as user scrolls. For free events, show "Attend Event" / "Cancel Attendance". (3) **Uncomment hidden features** — uncomment the "You have a ticket!" indicator in `attendee_stats_card.dart`, uncomment the organizer message button in `organizer_info_card.dart`, uncomment the verified badge on organizer card. (4) **Fix multi-tier purchase** — in `event_description.dart`, when `event.hasMultipleTiers` is true, render `TicketTierSelector` instead of `TicketQuantitySelector`, and update `ticket_order_summary.dart` to show the selected tier name/price instead of hardcoded "General Admission". (5) Wire organizer card's profile tap and message tap to `NavigationHelper`.

---

### Phase 6 — Profile & Settings (Prompts 19–22)

**Prompt 19: Profile Actions**
> Implement the profile action features. In `profile_screen.dart`: (1) **Share Profile** — generate a deep link to the user's profile and open the system share sheet via `share_plus`. (2) **Copy Link** — copy the deep link to clipboard with a custom toast confirmation. (3) **Block User** — add the blocked user's ID to a `blockedUsers` subcollection under the current user, show confirmation dialog, and filter blocked users from feeds/search/messaging. (4) **Report User** — show a report reason picker dialog (harassment, spam, inappropriate content, impersonation, other) and create a report document in a `reports` collection with `reporterId`, `reportedUserId`, `reason`, `timestamp`.

**Prompt 20: Account Information & Password Screens**
> Implement the missing menu/settings screens: (1) Create `account_information_screen.dart` — display email, username, phone (if set), account creation date, account type (student/non-student), campus. Allow editing phone number with verification. Show connected sign-in methods (email, Google) as chips. Use the same card styling as `menu_screen.dart` items. (2) Create `password_security_screen.dart` — allow password change (requires current password, new password with confirmation, strength indicator), show connected sign-in methods (email/Google), option to link/unlink Google account using Firebase Auth `linkWithCredential`/`unlink`. (3) Account Deletion — implement the full flow in `menu_screen.dart`'s existing delete dialog: re-authenticate user, delete all user documents (posts, products, events, resources) from Firestore, delete profile image from storage, delete Firebase Auth account, clear local Hive storage, and navigate to onboarding. Wire Account Information and Password items in `menu_screen.dart` to navigate to these new screens.

**Prompt 21: Payment/Payout Screen**
> Implement `payment_screen.dart` (currently 0 bytes). This is the seller's payout management screen, accessible from `sales_screen.dart` or `menu_screen.dart`. (1) **Earnings overview** — total lifetime earnings, available balance (orders completed), pending balance (orders in progress). (2) **Bank account setup** — form to add bank name, account number, account holder name; save to Firestore `users/{uid}/paymentDetails`. (3) **Payout history** — list of past payouts with amount, date, status (pending/completed/failed), reference ID. (4) **Request Payout** — button to request withdrawal of available balance; creates a `payouts` collection document for admin processing. (5) Add a "Payments" item to the Marketplace section in `menu_screen.dart`.

**Prompt 22: Professional Account**
> Implement the "Professional Account" feature from `menu_screen.dart`. (1) Create `professional_account_screen.dart` with a multi-step setup flow: Step 1 — select business category (Food, Fashion, Tech, Services, etc.), Step 2 — enter business name, description, contact info (phone, email, website), Step 3 — set business hours (day-by-day toggle with open/close times), Step 4 — confirmation and activation. (2) Update `UserModel` with `isProfessional`, `businessCategory`, `businessDescription`, `businessHours`, `contactInfo` fields. (3) Professional accounts get: a distinct gold verified badge, a "Business" label on their profile, business info section on their profile page, priority placement in marketplace (sort professional listings first). (4) Add a "Business Analytics" section on their profile showing views, reach, engagement. (5) Wire the Professional Account item in `menu_screen.dart` to navigate to this screen.

---

### Phase 7 — Anonymous Chat & Push Notifications (Prompts 23–24)

**Prompt 23: Anonymous Chat (Random Shot)**
> Implement the anonymous chat (Random Shot) backend. (1) Update `ChatProvider` to: create a `random_chat_queue` Firestore collection where users join a matchmaking queue; use a Cloud Function that pairs two users and creates a `random_chats/{chatId}` document with `user1`, `user2`, `isRevealed`, `revealRequests`, `messages` subcollection. (2) Implement `sendMessage` to write to `random_chats/{chatId}/messages`. (3) Implement `sendRevealRequest`, `acceptReveal`, `declineReveal` with proper Firestore updates and in-app notifications. (4) Update `chat_screen.dart` to use `AppTheme` instead of old `Constants` colors. (5) Add the anonymous chat entry point on the messaging screen — a prominent "Random Shot" card/button at the top. (6) Create a `random_chat_screen.dart` for the matched conversation with reveal UI.

**Prompt 24: Push Notifications (FCM)**
> Implement Firebase Cloud Messaging (FCM) push notifications. (1) Create `services/push_notification_service.dart` that initializes FCM, requests permission, saves device token to the user's Firestore document, handles foreground/background/terminated message handling, and shows local notifications via `flutter_local_notifications`. (2) Create Cloud Functions that trigger on Firestore document creation for: new messages (send push to recipient), new likes/comments/follows (send push to post owner), order updates (send push to buyer/seller), event reminders (send push 1 day and 1 hour before event), **task reminders (send push at the task's due date/time for any user who has enabled a reminder on that task)**. (3) Initialize the service in `main.dart` after Firebase init. (4) Add a "Notification Preferences" screen where users can toggle push notification categories (messages, social, orders, events, tasks) on/off. (5) **Public task reminders**: Public tasks are informational and can't be completed, but any user should be able to "subscribe" to a reminder on a public task. On `task_detail_screen.dart`, add a "Set Reminder" toggle for public tasks that writes the current user's ID to a `taskReminders/{taskId}/subscribers` subcollection. The Cloud Function should send a push notification to all subscribers when the task's due date/time arrives.

---

### Phase 8 — Code Quality & Architecture (Prompts 25–27)

**Prompt 25: Extract Duplicated Code**
> Refactor the duplicated code across the app: (1) Extract a shared `UploadStatusMixin` with the upload bar state management (start/update/success/fail/cancel/hide/reset) and apply it to `PostProvider`, `MarketPostProvider`, `EventProvider`, `EventCreateProvider`, `ResourcePostProvider` — remove the 5 duplicate enum + method copies. (2) Extract post interaction methods (`toggleLike`, `toggleBookmark`, `toggleRepost` and their check methods) from `FeedProvider` and `ProfileProvider` into a shared `PostInteractionMixin`. (3) Extract `_SocialAuthButton` from `sign_in.dart` and `create_account.dart` into `widgets/social_auth_button.dart`.

**Prompt 26: Fix Theme System**
> Fix the theme system. (1) Remove the static `_isDarkMode` bool from `AppTheme` and all static color getters. (2) Define all colors in `ThemeData.colorScheme` and `ThemeData.extensions` for custom colors (create `AppColorsExtension` for non-standard colors like `primaryBackground`, `textLight`, etc.). (3) Replace all `AppTheme.primary`, `AppTheme.surface`, etc. calls throughout the app with `Theme.of(context).colorScheme.primary`, `Theme.of(context).colorScheme.surface`, etc. (4) Migrate remaining `Constants.*` color references. (5) Fix `TextConstants` to accept `BuildContext` or use `Theme.of(context)` instead of caching colors at class-load time.

**Prompt 27: Clean Up Dead Code**
> Clean up dead code and fix naming: (1) Delete these entirely commented-out/empty files: `friends_draft.dart`, `update_provider.dart`, `message_chat_provider.dart`, `dialog_widget.dart`. (2) Remove `story_model.dart` placeholder models and update `ChatProvider`/`FriendsTabProvider` to use real models. (3) Rename `product_decription.dart` → `product_description.dart` and update all imports across the codebase. (4) Remove all unused `import 'dart:io'`. (5) Replace deprecated `WillPopScope` with `PopScope` in `edit_profile_screen.dart` and `profile_screen.dart`. (6) Replace all `print()` calls with `debugPrint()`. (7) Remove the duplicate `createEventSilently()` from `EventProvider` (keep the one in `EventCreateProvider`).

---

### Phase 9 — Performance & Polish (Prompts 28–31)

**Prompt 28: Optimize Firestore Reads**
> Optimize Firestore reads in the feed. Currently each post triggers 4 `.count()` subcollection queries (likes, bookmarks, comments, reposts), meaning loading 30 posts = 120+ reads. (1) Add denormalized counters (`likesCount`, `commentsCount`, `repostsCount`, `bookmarksCount`) directly on post documents. (2) Update `toggleLike`, `toggleBookmark`, `toggleRepost` to use `FieldValue.increment()` on the post document. (3) Update `FeedProvider` and `ProfileProvider` to read counts from the post document instead of separate queries. (4) Prune `_userCache` in `FeedProvider` — add a max size of 100 entries with LRU eviction.

**Prompt 29: Pagination / Infinite Scroll**
> Add pagination/infinite scroll to all feed screens. Currently `for_you_screen.dart`, `campus_screen.dart`, and `friends_screen.dart` load all posts at once. (1) Implement cursor-based pagination in `FeedProvider` using Firestore `startAfterDocument`. (2) Load 15 posts initially, then load 10 more when the user scrolls near the bottom. (3) Add a loading indicator at the bottom while fetching. (4) Prevent duplicate fetch calls during scroll. (5) Apply the same pagination to `ProfileProvider` for the profile posts tabs. (6) Apply pagination to marketplace product listing and event listing.

**Prompt 30: Onboarding Polish**
> Polish the onboarding flow: (1) Make "Don't have an account? Create account" in `sign_in.dart` and "Already have an account? Sign In" in `create_account.dart` tappable — wrap in `GestureDetector` that closes the current bottom sheet and opens the other one. (2) Add a loading overlay or button loading state when sign-in/sign-up is in progress. (4) Add proper error messages for common auth failures (wrong password, user not found, email already in use, network error).

**Prompt 31: Shimmer Loading & Empty States**
> Add pull-to-refresh and proper empty states across all list screens. Ensure consistent empty state illustrations (use Iconify Ph icons) and "Retry" buttons for error states. Add shimmer/skeleton loading placeholders instead of plain `CircularProgressIndicator` on: (1) feed screens, (2) marketplace grid, (3) message list, (4) notification list, (5) resource list, (6) profile posts tabs. Create a shared `ShimmerCard` widget that can adapt to card shapes (post card, product card, message tile, notification tile).

---

### Phase 10 — Final Features (Prompts 32–34)

**Prompt 32: Post Editing**
> Add post editing capability. Currently posts can only be created and deleted. (1) Add an "Edit" option to `PostOptionsWidget` for the post owner. (2) Create `EditPostScreen` pre-filled with the current post text and images. (3) Allow editing text and adding/removing images. (4) Add `isEdited: true` and `editedAt: DateTime` fields to `PostModel`. (5) Show a small "edited" label on edited posts in the feed. (6) Update the Firestore document on save.

**Prompt 33: Marketplace Wishlist / Favorites**
> Add a favorites/wishlist system for marketplace products: (1) Add a heart icon button on `ProductCard` and `product_decription.dart`. (2) Store favorites in `users/{uid}/favorites` subcollection with `productId`, `addedAt`. (3) Add a "Saved Items" tab/screen accessible from `menu_screen.dart` showing all favorited products in a grid. (4) Create `WishlistProvider` with `toggleFavorite`, `isFavorited`, `getFavorites` methods. (5) Show favorite count on product cards and description page.

**Prompt 34: Scale Beyond Single University**
> Scale the app beyond University of Ibadan. (1) Make `vars_constants.dart` data-driven — load universities, campuses, faculties, and departments from a Firestore `universities` collection instead of hardcoding. (2) Add a university selection step during onboarding. (3) Filter campus feed by the user's university. (4) Update marketplace and events to scope by university. (5) Allow users to change their university in settings.
