import 'package:flutter/material.dart';

import 'mobile_nav_drawer.dart';
import 'site_footer.dart';
import 'site_header.dart';

/// Frame around every storefront page: sticky header + scrollable body.
class StoreShell extends StatelessWidget {
  const StoreShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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

/// Scrollable page body that always ends with the footer.
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
          if (showFooter) const SiteFooter(),
        ],
      ),
    );
  }
}
