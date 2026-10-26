import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/product_category.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/state_views.dart';
import '../widgets/admin_page.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final _repo = CategoryRepository();
  late Future<List<ProductCategory>> _future = _repo.fetchAll();

  void _reload() => setState(() => _future = _repo.fetchAll());

  Future<void> _openEditor([ProductCategory? category]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _CategoryDialog(category: category, repo: _repo),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(ProductCategory category) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete “${category.name}”?',
      message:
          'Products in this category become uncategorized. They won’t be deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    try {
      await _repo.delete(category.id);
      if (!mounted) return;
      showSnack(context, 'Category deleted');
      _reload();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Categories',
      subtitle: 'Organise products so shoppers can find their lane.',
      actions: [
        AppButton(
          label: 'New category',
          icon: Icons.add_rounded,
          variant: AppButtonVariant.accent,
          size: AppButtonSize.small,
          onPressed: () => _openEditor(),
        ),
      ],
      child: FutureBuilder<List<ProductCategory>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(
              message: friendlyError(snapshot.error!),
              onRetry: _reload,
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final categories = snapshot.data ?? const <ProductCategory>[];
          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories',
              message: 'Create categories like Tops, Sneakers or Accessories.',
              actionLabel: 'New category',
              onAction: () => _openEditor(),
            );
          }
          return ResponsiveGrid(
            minItemWidth: 300,
            children: [
              for (var i = 0; i < categories.length; i++)
                _CategoryCard(
                  category: categories[i],
                  color: AppColors.playful[i % AppColors.playful.length],
                  onEdit: () => _openEditor(categories[i]),
                  onDelete: () => _delete(categories[i]),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductCategory category;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final fg = color == AppColors.violet ? Colors.white : AppColors.ink;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: ClipOval(child: NetImage(category.imageUrl)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(category.name, style: AppText.display(20, color: fg)),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, color: fg),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: fg),
          ),
        ],
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({required this.repo, this.category});

  final CategoryRepository repo;
  final ProductCategory? category;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.category?.name ?? '');
  late final _image = TextEditingController(
    text: widget.category?.imageUrl ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _image.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final category = widget.category;
      if (category == null) {
        await widget.repo.create(name: _name.text, imageUrl: _image.text);
      } else {
        await widget.repo.update(
          category.id,
          name: _name.text,
          imageUrl: _image.text,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        showSnack(context, friendlyError(e), error: true);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      title: Text(
        widget.category == null ? 'New category' : 'Edit category',
        style: AppText.display(24),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledField(
                label: 'Name',
                child: TextFormField(
                  controller: _name,
                  autofocus: true,
                  validator: (v) => Validators.notEmpty(v, 'Name'),
                  decoration: const InputDecoration(hintText: 'e.g. Sneakers'),
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Image URL (optional)',
                child: TextFormField(
                  controller: _image,
                  decoration: const InputDecoration(hintText: 'https://…'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: 'Save',
          size: AppButtonSize.small,
          loading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }
}
