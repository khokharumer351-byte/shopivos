import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/product.dart';
import '../../../data/models/product_category.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/state_views.dart';
import '../widgets/admin_page.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _products = ProductRepository();
  final _storage = StorageRepository();

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _compareAt = TextEditingController();
  final _stock = TextEditingController(text: '0');
  final _sizes = TextEditingController();
  final _imageUrl = TextEditingController();

  List<ProductCategory> _categories = const [];
  List<String> _images = [];
  String? _categoryId;
  bool _featured = false;
  bool _active = true;

  bool _loading = true;
  String? _loadError;
  bool _saving = false;
  bool _uploading = false;

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _description,
      _price,
      _compareAt,
      _stock,
      _sizes,
      _imageUrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final categories = await CategoryRepository().fetchAll();
      Product? product;
      if (_isEdit) {
        product = await _products.fetchProduct(widget.productId!);
        if (product == null) throw StateError('Product not found');
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        if (product != null) {
          _name.text = product.name;
          _description.text = product.description;
          _price.text = product.price.toStringAsFixed(2);
          _compareAt.text = product.compareAtPrice?.toStringAsFixed(2) ?? '';
          _stock.text = '${product.stock}';
          _sizes.text = product.sizes.join(', ');
          _images = [...product.images];
          _categoryId = product.categoryId;
          _featured = product.isFeatured;
          _active = product.isActive;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e is StateError ? e.message : friendlyError(e);
        _loading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final files = await ImagePicker().pickMultiImage(
      maxWidth: 1800,
      imageQuality: 85,
    );
    if (files.isEmpty) return;
    setState(() => _uploading = true);
    try {
      for (final file in files) {
        final bytes = await file.readAsBytes();
        final url = await _storage.uploadProductImage(bytes, file.name);
        if (!mounted) return;
        setState(() => _images.add(url));
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Upload failed: ${friendlyError(e)}', error: true);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _addImageUrl() {
    final url = _imageUrl.text.trim();
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
      showSnack(context, 'Enter a valid image URL (https://…)', error: true);
      return;
    }
    setState(() {
      _images.add(url);
      _imageUrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final compareText = _compareAt.text.trim();
    final product = Product(
      id: widget.productId ?? '',
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text.trim()),
      compareAtPrice: compareText.isEmpty ? null : double.parse(compareText),
      stock: int.parse(_stock.text.trim()),
      categoryId: _categoryId,
      images: _images,
      sizes: _sizes.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      isFeatured: _featured,
      isActive: _active,
    );

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _products.update(product);
      } else {
        await _products.create(product);
      }
      if (!mounted) return;
      showSnack(context, _isEdit ? 'Product updated ✦' : 'Product created ✦');
      context.go('/admin/products');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: _isEdit ? 'Edit product' : 'New product',
      subtitle: _isEdit
          ? 'Update details, pricing and stock.'
          : 'Fill in the details and hit save.',
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          size: AppButtonSize.small,
          onPressed: () => context.go('/admin/products'),
        ),
        AppButton(
          label: 'Save',
          icon: Icons.check_rounded,
          variant: AppButtonVariant.accent,
          size: AppButtonSize.small,
          loading: _saving,
          onPressed: _loading || _loadError != null ? null : _save,
        ),
      ],
      child: _loading
          ? const LoadingView()
          : _loadError != null
          ? ErrorView(message: _loadError!, onRetry: _load)
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    final wide = MediaQuery.sizeOf(context).width >= 1100;

    final details = InkCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Details', style: AppText.display(22)),
          const SizedBox(height: 20),
          LabeledField(
            label: 'Name',
            child: TextFormField(
              controller: _name,
              validator: (v) => Validators.notEmpty(v, 'Name'),
              decoration: const InputDecoration(
                hintText: 'e.g. Vintage Wash Tee',
              ),
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Description',
            child: TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Materials, fit, care, the vibe…',
              ),
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Category',
            child: DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              isExpanded: true,
              decoration: const InputDecoration(),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Uncategorized'),
                ),
                for (final c in _categories)
                  DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Sizes (comma separated, optional)',
            child: TextFormField(
              controller: _sizes,
              decoration: const InputDecoration(hintText: 'XS, S, M, L, XL'),
            ),
          ),
        ],
      ),
    );

    final pricing = InkCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pricing & stock', style: AppText.display(22)),
          const SizedBox(height: 20),
          FieldRow(
            children: [
              LabeledField(
                label: 'Price',
                child: TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: Validators.price,
                  decoration: const InputDecoration(hintText: '29.00'),
                ),
              ),
              LabeledField(
                label: 'Compare-at price',
                child: TextFormField(
                  controller: _compareAt,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) => Validators.price(v, optional: true),
                  decoration: const InputDecoration(
                    hintText: 'Shown struck-through',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Stock',
            child: TextFormField(
              controller: _stock,
              keyboardType: TextInputType.number,
              validator: Validators.wholeNumber,
              decoration: const InputDecoration(hintText: '0'),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _active,
            onChanged: (v) => setState(() => _active = v),
            title: Text(
              'Visible in store',
              style: AppText.body(15, weight: FontWeight.w600),
            ),
            subtitle: const Text('Hidden products are only visible to admins.'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _featured,
            onChanged: (v) => setState(() => _featured = v),
            title: Text(
              'Featured',
              style: AppText.body(15, weight: FontWeight.w600),
            ),
            subtitle: const Text('Shows on the homepage “hot list”.'),
          ),
        ],
      ),
    );

    final media = InkCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Images', style: AppText.display(22))),
              AppButton(
                label: 'Upload',
                icon: Icons.upload_rounded,
                size: AppButtonSize.small,
                loading: _uploading,
                onPressed: _pickImages,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'The first image is the cover. Drag to reorder.',
            style: AppText.body(13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          if (_images.isEmpty)
            Container(
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line, width: 1.5),
              ),
              child: Text(
                'No images yet',
                style: AppText.body(14, color: AppColors.muted),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: true,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _images.removeAt(oldIndex);
                    _images.insert(newIndex, item);
                  });
                },
                children: [
                  for (var i = 0; i < _images.length; i++)
                    Padding(
                      key: ValueKey('${_images[i]}#$i'),
                      padding: const EdgeInsets.only(right: 12),
                      child: _ImageThumb(
                        url: _images[i],
                        isCover: i == 0,
                        onRemove: () => setState(() => _images.removeAt(i)),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _imageUrl,
                  onSubmitted: (_) => _addImageUrl(),
                  decoration: const InputDecoration(
                    hintText: '…or paste an image URL',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AppButton(
                label: 'Add',
                variant: AppButtonVariant.outline,
                size: AppButtonSize.small,
                onPressed: _addImageUrl,
              ),
            ],
          ),
        ],
      ),
    );

    return Form(
      key: _formKey,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [details, const SizedBox(height: 20), media],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: pricing),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                details,
                const SizedBox(height: 20),
                pricing,
                const SizedBox(height: 20),
                media,
              ],
            ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({
    required this.url,
    required this.isCover,
    required this.onRemove,
  });

  final String url;
  final bool isCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCover ? AppColors.violet : AppColors.ink,
                  width: isCover ? 3 : 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: NetImage(url),
              ),
            ),
          ),
          if (isCover)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('COVER', style: AppText.label(size: 9)),
              ),
            ),
          Positioned(
            right: 6,
            top: 6,
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.ink, width: 1.5),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
