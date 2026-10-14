import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/account_screen.dart';
import '../../features/account/order_detail_screen.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/admin/categories/admin_categories_screen.dart';
import '../../features/admin/customers/admin_customers_screen.dart';
import '../../features/admin/dashboard/admin_dashboard_screen.dart';
import '../../features/admin/orders/admin_orders_screen.dart';
import '../../features/admin/products/admin_products_screen.dart';
import '../../features/admin/products/product_form_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/order_success_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/misc/not_found_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../shared/layout/store_shell.dart';
import '../../state/auth_provider.dart';

const _authPages = {'/login', '/signup', '/forgot-password'};

bool _requiresLogin(String path) =>
    path == '/checkout' ||
    path == '/wishlist' ||
    path.startsWith('/account') ||
    path.startsWith('/order-success') ||
    path.startsWith('/admin');

Page<void> _page(GoRouterState state, Widget child) => NoTransitionPage<void>(key: state.pageKey, child: child);

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.matchedLocation;

      // User arrived from a password reset email.
      if (auth.isPasswordRecovery && path != '/reset-password') return '/reset-password';

      if (auth.isLoggedIn && _authPages.contains(path)) {
        final from = state.uri.queryParameters['from'];
        return (from != null && from.startsWith('/') && !from.startsWith('//')) ? from : '/';
      }

      if (!auth.isLoggedIn && _requiresLogin(path)) {
        return Uri(path: '/login', queryParameters: {'from': state.uri.toString()}).toString();
      }
      return null;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      // ---------------------------------------------------------------- Store
      ShellRoute(
        builder: (context, state, child) => StoreShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/', pageBuilder: (context, state) => _page(state, const HomeScreen())),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) {
              final q = state.uri.queryParameters;
              return _page(
                state,
                ShopScreen(
                  categoryId: q['category'],
                  search: q['q'],
                  sortKey: q['sort'],
                  featuredOnly: q['featured'] == '1',
                ),
              );
            },
          ),
          GoRoute(
            path: '/product/:id',
            pageBuilder: (context, state) =>
                _page(state, ProductDetailScreen(productId: state.pathParameters['id']!)),
          ),
          GoRoute(path: '/cart', pageBuilder: (context, state) => _page(state, const CartScreen())),
          GoRoute(path: '/checkout', pageBuilder: (context, state) => _page(state, const CheckoutScreen())),
          GoRoute(
            path: '/order-success/:id',
            pageBuilder: (context, state) =>
                _page(state, OrderSuccessScreen(orderId: state.pathParameters['id']!)),
          ),
          GoRoute(path: '/wishlist', pageBuilder: (context, state) => _page(state, const WishlistScreen())),
          GoRoute(
            path: '/account',
            pageBuilder: (context, state) => _page(state, const AccountScreen(section: AccountSection.profile)),
            routes: [
              GoRoute(
                path: 'orders',
                pageBuilder: (context, state) => _page(state, const AccountScreen(section: AccountSection.orders)),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) =>
                        _page(state, OrderDetailScreen(orderId: state.pathParameters['id']!)),
                  ),
                ],
              ),
              GoRoute(
                path: 'security',
                pageBuilder: (context, state) =>
                    _page(state, const AccountScreen(section: AccountSection.security)),
              ),
            ],
          ),
        ],
      ),

      // ----------------------------------------------------------------- Auth
      GoRoute(path: '/login', pageBuilder: (context, state) => _page(state, const LoginScreen())),
      GoRoute(path: '/signup', pageBuilder: (context, state) => _page(state, const SignupScreen())),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _page(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) => _page(state, const ResetPasswordScreen()),
      ),

      // ---------------------------------------------------------------- Admin
      ShellRoute(
        builder: (context, state, child) => AdminShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/admin', pageBuilder: (context, state) => _page(state, const AdminDashboardScreen())),
          GoRoute(
            path: '/admin/products',
            pageBuilder: (context, state) => _page(state, const AdminProductsScreen()),
          ),
          GoRoute(
            path: '/admin/products/new',
            pageBuilder: (context, state) => _page(state, const ProductFormScreen()),
          ),
          GoRoute(
            path: '/admin/products/:id/edit',
            pageBuilder: (context, state) =>
                _page(state, ProductFormScreen(productId: state.pathParameters['id'])),
          ),
          GoRoute(
            path: '/admin/categories',
            pageBuilder: (context, state) => _page(state, const AdminCategoriesScreen()),
          ),
          GoRoute(path: '/admin/orders', pageBuilder: (context, state) => _page(state, const AdminOrdersScreen())),
          GoRoute(
            path: '/admin/customers',
            pageBuilder: (context, state) => _page(state, const AdminCustomersScreen()),
          ),
        ],
      ),
    ],
  );
}
