import 'package:flutter/material.dart';

import '../../core/utils/platform.dart';
import 'app_shell.dart';
import 'mobile_nav_drawer.dart';
import 'site_footer.dart';
import 'site_header.dart';

/// Frame around every storefront page: sticky header + scrollable body.
/// In the Android/iOS app it becomes [AppShell] (top bar + bottom tabs).
class StoreShell extends StatelessWidget {
  const StoreShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isMobileApp) return AppShell(location: location, child: child);

    return Scaffold(
      drawer: const MobileNavDrawer(),
      body: Column(
        children: [
          SiteHeader(location: location),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Scrollable page body that ends with the footer on the website.
/// The app has a tab bar instead, so it only gets some breathing room.
class StorePage extends StatelessWidget {
  const StorePage({super.key, required this.children, this.showFooter = true});

  final List<Widget> children;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          if (showFooter && !isMobileApp) const SiteFooter(),
          if (isMobileApp) const SizedBox(height: 32),
        ],
      ),
    );
  }
}
