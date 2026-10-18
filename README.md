# shopivo.

A modern-classic, Gen-Z flavoured e-commerce store built with **Flutter + Supabase**: one codebase for the **website** and the **Android/iOS app**, sharing the same database and backend.

- **Storefront:** home page, shop with search/filters/sort, product pages with gallery, sizes and reviews, wishlist, bag, checkout (cash on delivery), order tracking
- **Accounts:** sign up, sign in, forgot/reset password by email, profile and saved address, change password, order history
- **Admin panel** (`/admin`): dashboard stats, products (create/edit/delete, image upload, sizes, sale price, stock, hide/feature), categories, orders (status updates, details), customers (promote/demote admins)
- **Notifications:** order confirmations and status updates for customers, new-order and low-stock alerts for admins, and admin broadcasts to all customers. They appear in an inbox (bell icon) on the web and app, and as phone notifications in the app
- **Mobile app:** the same screens with a bottom tab bar, a back arrow and Android back-button support
- **Secure by default:** Row Level Security on every table; checkout runs through a server-side function that re-checks prices and stock

---

## 1. Set up Supabase (one time, ~5 min)

1. Create a project at [supabase.com](https://supabase.com).
2. Go to **SQL Editor → New query**, paste all of [`supabase/schema.sql`](supabase/schema.sql) and click **Run**.
3. Run [`supabase/notifications.sql`](supabase/notifications.sql) the same way (after `schema.sql`). It adds the notifications table, triggers and realtime.
4. (Optional, for demo data) Run [`supabase/seed.sql`](supabase/seed.sql) the same way.
5. Go to **Authentication → URL Configuration** and set:
   - **Site URL:** `http://localhost:5000`
   - **Redirect URLs:** add both `http://localhost:5000/**` (website) and `io.shopivo.app://login-callback` (mobile app)

   This lets the password-reset and confirmation emails send people back to the website or open the app.
6. *(Optional, for faster testing)* **Authentication → Providers → Email** → turn off **Confirm email**, so new accounts can sign in right away.

## 2. Add your keys

Open **Project Settings → API** in Supabase and copy the **Project URL** and the **anon public** key.

Paste them into [`lib/core/config/env.dart`](lib/core/config/env.dart) (replace the `YOUR-...` defaults),
**or** pass them when you run the app:

```bash
--dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

The anon key is meant to be public. Row Level Security protects the data. **Never** put the `service_role` key in the app.

## 3. Run it

```bash
flutter pub get
flutter run -d chrome --web-port 5000
```

**Android Studio:** pick **Chrome (web)** as the device. Then go to **Run → Edit Configurations → main.dart**
and put `--web-port 5000` in **Additional run args** (add the `--dart-define`s there too if you're using them).

> Use the fixed port 5000. The auth redirect URLs from step 1.5 point there.

### Run the mobile app (Android)

Same project, same keys in `env.dart`. Nothing else to configure.

1. In Android Studio open **Device Manager** and start an emulator, or plug in a phone with USB debugging on.
2. Pick that device in the device dropdown (instead of Chrome) and press **Run**. Or from a terminal:

   ```bash
   flutter devices          # find the device id
   flutter run -d <device-id>
   ```

3. On first sign-in, Android 13+ asks to allow notifications. Tap **Allow**.

To build an installable APK: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
(it's signed with the debug key, which is fine for sharing with testers but not for the Play Store).

**iOS** needs a Mac with Xcode: `flutter run -d <iphone>` or open `ios/Runner.xcworkspace`.

### How notifications work

- Database triggers in `supabase/notifications.sql` write a row to `notifications` when an order is placed or its status changes, and when stock runs low. **Admin → Notify** sends a message to every customer.
- The app and website listen to that table through **Supabase Realtime**, so new rows show up instantly in the bell inbox. In the app they also pop up as phone notifications, and tapping one opens the right page.
- They arrive while the app is open or in the background. If the app has been fully closed (swiped away), nothing pops up, but the notifications wait in the inbox for next time. Push to a fully closed app needs Firebase Cloud Messaging (see *Not included yet*).

**Quick test:** sign in on the phone as a customer and place an order. Then, on the website as admin, change that order's status to *Shipped*. The phone gets "Your order is on the way 🚚".

## 4. Make yourself admin

1. Sign up in the app.
2. In Supabase **SQL Editor**, run:

   ```sql
   update public.profiles set role = 'admin' where email = 'you@example.com';
   ```

3. Refresh the app. **Admin panel** now shows up in the account menu (or go to `/admin`).

After that, you can promote other users from **Admin → Customers**.

---

## Project structure

```
lib/
├── main.dart                     # Entry: URL strategy, Supabase + notifications init
├── app.dart                      # Providers + MaterialApp.router + app back button
├── core/
│   ├── config/                   # env.dart (keys), app_config.dart (currency, shipping rules)
│   ├── notifications/            # Phone notifications (no-op on web)
│   ├── router/                   # app_router.dart (routes + guards), back_navigation.dart (Android back)
│   ├── theme/                    # Colors, typography, ThemeData
│   └── utils/                    # Formatters, validators, snackbars/dialogs, platform check
├── data/
│   ├── models/                   # Product, ProductCategory, CartItem, ShopOrder, Profile, Review, AppNotification
│   ├── repositories/             # One class per table/feature; all Supabase calls live here
│   └── supabase_client.dart
├── state/                        # ChangeNotifiers: auth, cart (persisted locally), wishlist, notifications
├── shared/
│   ├── layout/                   # Store shell; website header/footer/drawer; app_shell.dart (app top bar + tabs)
│   └── widgets/                  # Buttons, product card/grid, marquee, pills, form fields…
└── features/
    ├── home/  shop/  product/  cart/  checkout/  wishlist/
    ├── account/                  # Profile, orders, order detail, security
    ├── notifications/            # Notification inbox
    ├── auth/                     # Login, signup, forgot + reset password
    ├── admin/                    # Shell + dashboard, products, categories, orders, customers, notify
    └── misc/                     # 404, setup-required screen
supabase/
├── schema.sql                    # Tables, RLS policies, triggers, RPCs, storage bucket
├── notifications.sql             # Notifications table, triggers, broadcast RPC, realtime
└── seed.sql                      # Optional demo categories + products
```

**Rules of thumb**
- UI never calls Supabase directly. It goes through `data/repositories/*`.
- App-wide state (auth, cart, wishlist) lives in `state/`. Page-local data uses a `FutureBuilder` in the screen.
- New page = new folder in `features/` + a route in `core/router/app_router.dart`. It works on web and in the app automatically.
- Web-vs-app differences live in the shell (`StoreShell` → `AppShell`) and are checked with `isMobileApp` (`core/utils/platform.dart`).

## Config you may want to change

| What | Where |
|---|---|
| Currency symbol | `lib/core/config/app_config.dart` |
| Free-shipping threshold / shipping fee | `app_config.dart` **and** `place_order` in `supabase/schema.sql` (keep both in sync) |
| Brand colors / fonts | `lib/core/theme/` |
| App name / package id | `android/app/src/main/AndroidManifest.xml` (label), `android/app/build.gradle.kts` (`applicationId`) |
| App deep-link scheme | `AppConfig.appAuthCallback`, `AndroidManifest.xml`, `ios/Runner/Info.plist` (keep all three in sync) |

## Routes

| Path | Page |
|---|---|
| `/` | Home |
| `/shop?category=&q=&sort=&featured=1` | Shop / search |
| `/product/:id` | Product detail |
| `/cart`, `/checkout`, `/order-success/:id` | Bag & checkout |
| `/wishlist` | Wishlist |
| `/notifications` | Notification inbox |
| `/account`, `/account/orders`, `/account/orders/:id`, `/account/security` | Customer panel |
| `/login`, `/signup`, `/forgot-password`, `/reset-password` | Auth |
| `/admin`, `/admin/products`, `/admin/products/new`, `/admin/products/:id/edit`, `/admin/categories`, `/admin/orders`, `/admin/customers`, `/admin/notify` | Admin panel |

## Not included yet (good next steps)

- Online card payments (e.g. Stripe via a Supabase Edge Function). Checkout is cash on delivery for now.
- Coupons / discount codes
- Transactional emails for order status changes
- Push notifications when the app is fully closed: add Firebase Cloud Messaging (`firebase_messaging`) plus a Supabase Edge Function that forwards new `notifications` rows to FCM
- A custom app icon and splash screen (e.g. with `flutter_launcher_icons`)
