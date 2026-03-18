# CampCon Product Page Design Guide

## Overview

The CampCon product page is a high-conversion marketplace interface designed for a **dual-marketplace platform** supporting both physical items (marketplace) and services (gig economy). The design balances information density with mobile-first usability, using minimalist separators and contextual actions.

---

## Visual Structure

### Page Hierarchy

```
┌─────────────────────────────────────────┐
│  Header (Back | Title | Share)          │  ← Fixed
├─────────────────────────────────────────┤
│                                         │
│  Product Image (Carousel)               │  ← 100% width
│  with lazy image loading                │
│                                         │
├─────────────────────────────────────────┤
│ Price Info (₦X,XXX)                     │  ← Bold, primary color
│ Category Badge + Location               │  ← Location with pin icon
│ Views + Posted time + Share Button      │
├─────────────────────────────────────────┤
│ Description (Read more/less)            │  ← Max 4 lines collapsed
├─────────────────────────────────────────┤
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │  ← Divider
│ [Avatar] Seller/Provider Info           │
│         Name • Stars • Bio              │  ← → arrow to profile
├─────────────────────────────────────────┤
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │  ← Divider
│ ⭐ 4.8 (24 reviews) → See All           │
├─────────────────────────────────────────┤
│                                         │
│  ITEM-SPECIFIC OPTIONS (if item):       │
│  ┌───────────────────────────────────┐ │
│  │ Quantity: [−] 2 [+]               │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ Pickup Location *                 │ │
│  │ > Select Location                 │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ Payment Method *                  │ │
│  │ ◯ Pay Online  ◉ Pay on Pickup    │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ Order Notes (Optional)            │ │
│  │ [textarea]                        │ │
│  └───────────────────────────────────┘ │
│                                         │
├─────────────────────────────────────────┤
│ Similar Items / Services (Horizontal)   │
└─────────────────────────────────────────┘
                                         ↓
┌─────────────────────────────────────────┐
│  FAB / Bottom Action                    │
│  🛒 Buy — ₦X,XXX  (for items)          │
│  💬 Message (for services)              │
│  📝 Edit/Manage (for sellers)          │
└─────────────────────────────────────────┘
```

---

## Design Tokens

### Colors
- **Primary Action**: `AppTheme.primary` (bright blue/teal)
- **Surface**: `AppTheme.surface` (light gray/white)
- **Text Primary**: `AppTheme.textPrimary` (dark gray/black)
- **Text Secondary**: `AppTheme.textSecondary` (medium gray)
- **Text Light**: `AppTheme.textLight` (light gray)
- **Border**: `AppTheme.border` (very light gray, 1px)
- **Background**: `AppTheme.background` (slightly lighter than surface)

### Typography
- **Bold Headline**: `TextConstants.boldText` 16sp (Product name, section titles)
- **Medium Regular**: `TextConstants.mediumText` 14sp (Product price, seller name)
- **Small Regular**: `TextConstants.smallText` 12sp (Metadata, descriptions)

### Spacing
- **Section Gaps**: 24.h between major sections (description, seller, reviews)
- **Content Padding**: 20.w horizontal (main content area)
- **Line Height**: 1.6 (descriptions for readability)
- **Button Height**: 48.h minimum (touch targets)

### Borders & Dividers
- **Divider**: 1px line, `AppTheme.border` color
- **No rounded containers** on selectors (quantity, pickup, payment)
- **Minimal buttons**: 8.r border radius (tight, modern)
- **Card radius**: 12.r (for related products only)

---

## Component Library

### 1. **ProductHeader** (Fixed/Sticky)
```dart
Container(
  // Back button | Title | Share button
  // Border bottom only
  // No shadow, clean horizontal line
)
```
**Behavior**: 
- Back button resets provider and pops
- Share button uses `share_plus` with product link
- Title updates based on `isItem` (Item Details vs Service Details)

### 2. **ProductImage** (Full Width)
```dart
// Carousel (optional for single images)
// Lazy loading with CachedNetworkImage
// Error state shows placeholder icon
// Tap to enter fullscreen viewer
```

### 3. **ProductPriceInfo**
```dart
Row(
  Text('₦${price.formatted}', fontWeight: bold, 18sp),
  if (isItem && stock <= 0) Text('Out of Stock', color: error),
)
```

### 4. **Category & Location**
```dart
Row(
  // 📍 Location (with ellipsis)
  // [Category Badge] (primary color bg 0.1 alpha, rounded pill)
)
```

### 5. **Product Metadata**
```dart
Row(
  Icon(eye), '120 views',
  Spacer(),
  Icon(clock), 'Posted 2 days ago',
  Spacer(),
  Container(share_icon), // Opens share sheet
)
```

### 6. **Description Section**
```dart
Column(
  Text('Description', style: bold 16sp),
  // AnimatedCrossFade between collapsed (4 lines) and expanded
  if (shouldShowMore) GestureDetector('Read more / Show less', primary color),
)
```

### 7. **Seller Info Card** (with Divider separator)
```dart
Column(
  Divider(color: border),
  Row(
    CircleAvatar(profileImage),
    Column(
      Text('Seller / Service Provider'),
      Text(sellerName, bold 16sp),
      // Stars + rating if available
      // Bio (1 line, ellipsis)
    ),
    Container(arrow_right), // tap → profile
  ),
)
```

### 8. **Reviews Section** (with Divider separator)
```dart
GestureDetector(
  // Opens ReviewSummaryScreen
  Divider(color: border),
  Row(
    Icon(star_fill, primary),
    Text('4.8', bold 18sp),
    Text('(24 reviews)', secondary 13sp),
    Spacer(),
    Text('See All', primary 13sp bold),
    Icon(arrow_right),
  ),
)
```

### 9. **Quantity Selector** (No Container)
```dart
Column(
  Row('Quantity', 'Max: 12'), // header
  Row(
    IconButton(minus, conditional color),
    Expanded(Text('2')),
    IconButton(plus, conditional color),
  ),
)
// No outer Container / border-radius wrapper
```

### 10. **Pickup Location Selector** (No Container)
```dart
Column(
  Text('Pickup Location *'),
  // Shows list items with radio selection
  // NO border-radius Container wrapper
  // Simple Row for each location
)
```

### 11. **Payment Method Selector** (Line separators only)
```dart
Column(
  Row(Icon(credit_card), Text('Payment Method')),
  SizedBox(12h),
  Column(
    // For each method:
    Row(
      Icon(method_icon),
      Expanded(Column(title, subtitle)),
      if (selected) Icon(check_circle),
    ),
    // NO Divider under each option
  ),
)
```

### 12. **Order Notes** (Optional, conditional)
```dart
Column(
  Text('Order Notes (Optional)'),
  TextField(
    maxLines: 3,
    maxLength: 200,
    hintText: 'Add any special instructions...',
    // Container with border, no radius
  ),
)
```

### 13. **Related Products Section**
```dart
Column(
  Text('Similar Items / Similar Services'),
  ListView.horizontal(
    // ProductCard items
    height: 230h
    itemCount: related.length
  ),
)

// ProductCard:
Container(
  borderRadius: 12r,
  Column(
    Image (120h),
    Padding(
      ProductName (2 lines),
      FormattedPrice (primary),
      Location (icon + text),
    ),
  ),
)
```

### 14. **Floating Action Button (Buyer - Items)**
```dart
// When out of stock:
FloatingActionButton(
  Icon(shopping_cart),
  backgroundColor: buttonBorder,
  disabled
)

// When can't proceed:
FloatingActionButton(
  Icon(shopping_cart),
  backgroundColor: buttonBorder,
  disabled
)

// When ready to buy:
FloatingActionButton.extended(
  label: Text('Buy — ₦X,XXX'),
  icon: Icon(shopping_cart),
  backgroundColor: primary,
)
```

### 15. **Floating Action Button (Buyer - Services)**
```dart
FloatingActionButton.extended(
  label: Text('Message'),
  icon: Icon(chat_circle_dots),
  backgroundColor: primary,
  onPressed: () => openChat(provider),
)
```

### 16. **Bottom Navigation Bar (Seller)**
```dart
Container(
  Row(
    Expanded(CustomButton('Edit Listing')),
    Expanded(CustomButton('Manage Orders')),
  ),
  // Box shadow above border
)
```

---

## User Flows

### 📱 Buyer Journey (Items)

1. **Land on page** → Auto-load seller data, pickup centers, related products (parallel)
2. **Browse** → Scroll through images, description, seller info, reviews
3. **Select options** → Adjust quantity, pick location, select payment method
4. **Place order** → FAB button becomes active → Tap → Order summary sheet
5. **Confirm** → Show order placed feedback → Navigate to orders

### 📱 Buyer Journey (Services)

1. **Land on page** → Auto-load seller data, related services
2. **Browse** → Read description, check seller rating, see pricing
3. **Inquire** → Tap "Message" FAB → Open chat
4. **Negotiate** → Text exchange with service provider
5. **Book** → Agree on terms → Place order via chat or direct booking

### 🏪 Seller Journey

1. **Land on own product** → ProductHeader shows back button
2. **Manage** → Tap "Edit Listing" → Go to edit screen
3. **Orders** → Tap "Manage Orders" → See all orders for this product
4. **Analytics** → View count, reviews, engagement

---

## State Management

### ProductProvider Responsibilities
```dart
final Product? _currentProduct;           // Current viewing
final UserModel? _sellerData;             // Seller info
final int _quantity = 1;                  // Buyer selection
final String? _selectedPaymentMethod;     // Payment choice
final PickupCenterModel? _selectedPickupCenter; // Pickup
final String _orderNotes = '';            // Optional notes
final List<PickupCenterModel> _approvedPickupCenters;
final List<Product> _relatedProducts;     // Horizontal scroll
final double _sellerAverageRating;        // Denormalized from reviews
final int _sellerTotalReviews;

// Getters
double get totalPrice => price * quantity;
bool get canProceedToOrder => 
  selectedPickupCenter != null && selectedPaymentMethod != null;
```

### Loading States
- **isLoadingSeller**: Show skeleton in seller card
- **isLoadingPickupCenters**: Show spinner in pickup selector
- **isLoadingRelated**: Show 3 skeleton cards in related section
- **isPlacingOrder**: Show loading overlay when confirming

---

## Accessibility & Performance

### Mobile Considerations
- **Touch targets**: All buttons min 48x48 (12w × 12h minimum)
- **Scrolling**: SingleChildScrollView with proper SafeArea
- **Images**: CachedNetworkImage with placeholder & error handling
- **Lazy loading**: Only load seller data on demand (not in list)

### Performance
- **Parallel loading**: Use `Future.wait()` for seller, pickup centers, related products
- **Count queries only**: Use `.count()` for review aggregation (not full docs)
- **Denormalization**: Store `averageRating` and `reviewCount` on product
- **Image compression**: Use `flutter_image_compress` on upload

### iOS Safe Area
- Wrap all content in SafeArea
- Use proper padding for notch devices
- FAB location set to `endDocked` to avoid overlap

---

## Visual Mockup

```
iPad/Tablet Layout (1024w screen):
┌──────────────────────────────────────────────────────────────┐
│ ← Item Details                                          Share │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────┐    Price: ₦45,000               │
│  │                     │    Laptop Bags                     │
│  │   Image Carousel    │    📍 Lekki, Lagos                │
│  │   (swipeable)       │    
│  │                     │    👁️ 847 views                    │
│  └─────────────────────┘    🕐 Posted 3h ago              
│
│  Description (70 chars max per line)
│  Lorem ipsum dolor sit amet, consectetur adipiscing elit...
│  [Read more]
│
│  ────────────────────────────────────────────────────────
│  👤 Seller Name              [Rating] ★★★★★ (142 reviews)
│     "Quality bags at best prices"                    →
│  ────────────────────────────────────────────────────────
│
│  ⭐ 4.7 (142 reviews) → [See All]
│
│  Quantity:  [−] 2 [+]
│  Pickup:    [Select Location ▼]
│  Payment:   (•) Pay Online   ( ) Pay on Pickup
│  Notes:     [text field...]
│
│  Similar Items (Horiz scroll)
│  ┌────────┐ ┌────────┐ ┌────────┐
│  │ Bag 1  │ │ Bag 2  │ │ Bag 3  │
│  │ ₦8,500 │ │ ₦9,200 │ │ ₦7,800 │
│  └────────┘ └────────┘ └────────┘
│
└──────────────────────────────────────────────────────────────┘
                      [🛒 Buy — ₦45,000]      ✓ Fixed FAB
```

---

## Design Rationale

1. **No Container Wrappers on Selectors**
   - Quantity, pickup, payment sections are content, not "cards"
   - Users expect list-like patterns on mobile
   - Reduces visual clutter, improves scannability

2. **Dividers Instead of Cards**
   - Seller + Reviews sections use horizontal lines
   - Visually separates without visual weight
   - Modern, minimalist approach
   - Matches faculty resources filter pattern

3. **Floating Actions Over Bottom Bar**
   - FAB for items (compact, easy thumb reach)
   - Bottom bar only for sellers (needs multiple actions)
   - Services use FAB (single action: message)

4. **Share Icon Moved to Header**
   - Metadata row too crowded
   - Share is secondary action
   - Consistent with product header pattern

5. **Parallel Data Loading**
   - Seller, pickup centers, related products load simultaneously
   - Reduces perceived load time
   - Better UX than sequential loading

6. **Conditional Visibility**
   - Item options only show for items, not services
   - Service notes hidden if order can't proceed
   - Reduces cognitive load

---

## Future Enhancements

- [ ] Image zoom on double-tap
- [ ] Review filtering (by rating, date, verified purchase)
- [ ] Wishlist/save functionality
- [ ] Questions section (FAQ below reviews)
- [ ] Video preview option
- [ ] Live seller status (online/away)
- [ ] Inventory progress bar
- [ ] Promotion badge (e.g., "Limited time offer")
- [ ] Variant selection (color, size) for items
- [ ] Related items from same seller carousel

---

## Implementation Checklist

- [x] ProductHeader with back, title, share
- [x] ProductImage carousel with lazy loading
- [x] Price + category + location display
- [x] Metadata (views, time, share button)
- [x] Expandable description
- [x] Seller info card with divider
- [x] Reviews section with divider
- [x] Quantity selector (no container)
- [x] Pickup location selector (no container)
- [x] Payment method selector (no divider lines)
- [x] Order notes (conditional)
- [x] Related products horizontal scroll
- [x] Floating action buttons (items + services)
- [x] Bottom bar (sellers)
- [x] Parallel data loading
- [x] Error handling & loading states
- [ ] Share sheet customization
- [ ] Order placement flow
- [ ] Analytics tracking (view count increment)

---

**Last Updated**: March 15, 2026  
**Version**: 1.0  
**Status**: Production Ready
