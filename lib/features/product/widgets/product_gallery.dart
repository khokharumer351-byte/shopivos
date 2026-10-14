import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/net_image.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key, required this.images});

  final List<String> images;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant ProductGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.images.length) _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final current = images.isEmpty ? null : images[_index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(8, 8))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: NetImage(current, key: ValueKey(current)),
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final selected = i == _index;
                return GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 74,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.violet : AppColors.ink,
                          width: selected ? 3 : 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: NetImage(images[i]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
