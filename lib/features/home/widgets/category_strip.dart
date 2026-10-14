import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../data/models/product_category.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/page_container.dart';

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({super.key, required this.categories});

  final List<ProductCategory> categories;

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1100 ? 5 : (width >= 700 ? 3 : 2);
          const gap = 16.0;
          final itemWidth = (width - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < categories.length; i++)
                SizedBox(
                  width: itemWidth,
                  child: _CategoryTile(
                    category: categories[i],
                    color: AppColors.playful[i % AppColors.playful.length],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({required this.category, required this.color});

  final ProductCategory category;
  final Color color;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final onDark = widget.color == AppColors.violet;
    final fg = onDark ? Colors.white : AppColors.ink;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/shop?category=${widget.category.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 150,
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.ink, width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.ink, offset: _hovered ? const Offset(6, 6) : const Offset(3, 3)),
            ],
          ),
          child: Stack(
            children: [
              if (widget.category.imageUrl != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: ClipOval(child: NetImage(widget.category.imageUrl)),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        widget.category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display(24, color: fg),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _hovered ? 0.125 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(Icons.arrow_upward_rounded, color: fg),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
