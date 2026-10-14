# shopivo.

A modern-classic, Gen-Z flavoured e-commerce web store built with **Flutter Web + Supabase**.

- **Storefront:** home page, shop with search/filters/sort, product pages with gallery, sizes and reviews, wishlist, bag, checkout (cash on delivery), order tracking
- **Accounts:** sign up, sign in, forgot/reset password by email, profile and saved address, change password, order history
- **Admin panel** (`/admin`): dashboard stats, products (create/edit/delete, image upload, sizes, sale price, stock, hide/feature), categories, orders (status updates, details), customers (promote/demote admins)
- **Secure by default:** Row Level Security on every table; checkout runs through a server-side function that re-checks prices and stock

---

## 1. Set up Supabase (one time, ~5 min)

1. Create a project at [supabase.com](https://supabase.com).
2. Go to **SQL Editor → New query**, paste all of [`supabase/schema.sql`](supabase/schema.sql) and click **Run**.
3. (Optional, for demo data) Run [`supabase/seed.sql`](supabase/seed.sql) the same way.
4. Go to **Authentication → URL Configuration** and set:
   - **Site URL:** `http://localhost:5000`
   - **Redirect URLs:** add `http://localhost:5000/**`

   This lets the password-reset and confirmation emails send people back to the app.
5. *(Optional, for faster testing)* **Authentication → Providers → Email** → turn off **Confirm email**, so new accounts can sign in right away.

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

> Use the fixed port 5000. The auth redirect URLs from step 1.4 point there.

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
├── main.dart                     # Entry: URL strategy + Supabase init
├── app.dart                      # Providers + MaterialApp.router
├── core/
│   ├── config/                   # env.dart (keys), app_config.dart (currency, shipping rules)
│   ├── router/app_router.dart    # All routes + auth/admin guards
│   ├── theme/                    # Colors, typography, ThemeData
│   └── utils/                    # Formatters, validators, snackbars/dialogs
├── data/
│   ├── models/                   # Product, ProductCategory, CartItem, ShopOrder, Profile, Review
│   ├── repositories/             # One class per table/feature; all Supabase calls live here
│   └── supabase_client.dart
├── state/                        # ChangeNotifiers: auth, cart (persisted locally), wishlist
├── shared/
│   ├── layout/                   # Store shell, header, footer, mobile drawer
│   └── widgets/                  # Buttons, product card/grid, marquee, pills, form fields…
└── features/
    ├── home/  shop/  product/  cart/  checkout/  wishlist/
    ├── account/                  # Profile, orders, order detail, security
    ├── auth/                     # Login, signup, forgot + reset password
    ├── admin/                    # Shell + dashboard, products, categories, orders, customers
    └── misc/                     # 404, setup-required screen
supabase/
├── schema.sql                    # Tables, RLS policies, triggers, RPCs, storage bucket
└── seed.sql                      # Optional demo categories + products
```

**Rules of thumb**
- UI never calls Supabase directly. It goes through `data/repositories/*`.
- App-wide state (auth, cart, wishlist) lives in `state/`. Page-local data uses a `FutureBuilder` in the screen.
- New page = new folder in `features/` + a route in `core/router/app_router.dart`.

## Config you may want to change

| What | Where |
|---|---|
| Currency symbol | `lib/core/config/app_config.dart` |
| Free-shipping threshold / shipping fee | `app_config.dart` **and** `place_order` in `supabase/schema.sql` (keep both in sync) |
| Brand colors / fonts | `lib/core/theme/` |

## Routes

| Path | Page |
|---|---|
| `/` | Home |
| `/shop?category=&q=&sort=&featured=1` | Shop / search |
| `/product/:id` | Product detail |
| `/cart`, `/checkout`, `/order-success/:id` | Bag & checkout |
| `/wishlist` | Wishlist |
| `/account`, `/account/orders`, `/account/orders/:id`, `/account/security` | Customer panel |
| `/login`, `/signup`, `/forgot-password`, `/reset-password` | Auth |
| `/admin`, `/admin/products`, `/admin/products/new`, `/admin/products/:id/edit`, `/admin/categories`, `/admin/orders`, `/admin/customers` | Admin panel |

## Not included yet (good next steps)

- Online card payments (e.g. Stripe via a Supabase Edge Function). Checkout is cash on delivery for now.
- Coupons / discount codes
- Transactional emails for order status changes
- Android/iOS builds. The code is cross-platform, but only web has been set up and styled.
