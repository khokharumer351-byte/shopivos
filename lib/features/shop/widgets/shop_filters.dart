import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../data/models/product.dart';
import '../../../data/models/product_category.dart';
import '../../../shared/widgets/page_container.dart';

class ShopFilters extends StatelessWidget {
  const ShopFilters({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.sort,
    required this.featuredOnly,
    required this.compact,
    required this.onCategory,
    required this.onSort,
    required this.onFeatured,
  });

  final List<ProductCategory> categories;
  final String? selectedCategoryId;
  final ProductSort sort;
  final bool featuredOnly;
  final bool compact;
  final ValueChanged<String?> onCategory;
  final ValueChanged<ProductSort> onSort;
  final ValueChanged<bool> onFeatured;

  @override
  Widget build(BuildContext context) {
    final categoryChips = [
      _FilterChip(
        label: 'All',
        selected: selectedCategoryId == null,
        onTap: () => onCategory(null),
      ),
      for (final c in categories)
        _FilterChip(
          label: c.name,
          selected: selectedCategoryId == c.id,
          onTap: () => onCategory(c.id),
        ),
    ];

    final sortMenu = PopupMenuButton<ProductSort>(
      tooltip: 'Sort',
      initialValue: sort,
      onSelected: onSort,
      itemBuilder: (context) => [
        for (final option in ProductSort.values)
          PopupMenuItem(value: option, child: Text(option.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 18),
            const SizedBox(width: 6),
            Text(sort.label, style: AppText.body(14, weight: FontWeight.w600)),
          ],
        ),
      ),
    );

    final featuredToggle = _FilterChip(
      label: '⚡ Featured only',
      selected: featuredOnly,
      onTap: () => onFeatured(!featuredOnly),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final chip in categoryChips)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: chip,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [sortMenu, featuredToggle]),
        ],
      );
    }

    return InkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SORT BY', style: AppText.label(size: 11)),
          const SizedBox(height: 12),
          sortMenu,
          const SizedBox(height: 28),
          Text('CATEGORY', style: AppText.label(size: 11)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: categoryChips),
          const SizedBox(height: 28),
          Text('EXTRAS', style: AppText.label(size: 11)),
          const SizedBox(height: 12),
          featuredToggle,
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.ink, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppText.body(
              13,
              weight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
