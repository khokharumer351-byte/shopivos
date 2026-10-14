import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Network image with soft loading / error placeholders.
class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover, this.width, this.height, this.placeholder});

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final src = url;
    if (src == null || src.isEmpty) return _fallback();
    return Image.network(
      src,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, progress) => progress == null ? child : _fallback(loading: true),
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback({bool loading = false}) {
    if (!loading && placeholder != null) return placeholder!;
    return Container(
      width: width,
      height: height,
      color: AppColors.paperDark,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.muted),
            )
          : const Icon(Icons.image_outlined, color: AppColors.muted),
    );
  }
}
