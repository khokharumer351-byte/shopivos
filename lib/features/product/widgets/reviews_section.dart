import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../../data/models/review.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/bits.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../state/auth_provider.dart';

class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key, required this.product, this.onChanged});

  final Product product;

  final VoidCallback? onChanged;

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final _repo = ReviewRepository();
  final _commentController = TextEditingController();
  late Future<List<Review>> _future = _repo.fetchForProduct(widget.product.id);
  int _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      await _repo.submit(
        productId: widget.product.id,
        userId: user.id,
        rating: _rating,
        comment: _commentController.text,
        authorName: auth.profile?.displayName ?? 'Shopper',
      );
      _commentController.clear();
      if (!mounted) return;
      showSnack(context, 'Thanks for the review ✦');
      setState(() => _future = _repo.fetchForProduct(widget.product.id));
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(Review review) async {
    try {
      await _repo.delete(review.id);
      if (!mounted) return;
      setState(() => _future = _repo.fetchForProduct(widget.product.id));
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    final summary = InkCard(
      color: AppColors.lime,
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.ratingAvg.toStringAsFixed(1),
            style: AppText.display(64),
          ),
          StarRating(rating: widget.product.ratingAvg, size: 22),
          const SizedBox(height: 6),
          Text(
            'Based on ${widget.product.ratingCount} review${widget.product.ratingCount == 1 ? '' : 's'}',
            style: AppText.body(14),
          ),
          const SizedBox(height: 24),
          if (auth.isLoggedIn) ...[
            Text('RATE IT', style: AppText.label(size: 11)),
            StarPicker(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'How was the fit, quality, vibe?',
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Post review',
              expand: true,
              loading: _submitting,
              onPressed: _submit,
            ),
          ] else
            AppButton(
              label: 'Sign in to review',
              expand: true,
              onPressed: () => context.go(
                '/login?from=${Uri.encodeComponent('/product/${widget.product.id}')}',
              ),
            ),
        ],
      ),
    );

    final list = FutureBuilder<List<Review>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final reviews = snapshot.data ?? const <Review>[];
        if (reviews.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No reviews yet — be the first to spill the tea. ☕',
              style: AppText.body(15, color: AppColors.muted),
            ),
          );
        }
        return Column(
          children: [
            for (final review in reviews)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ReviewTile(
                  review: review,
                  canDelete: review.userId == auth.user?.id || auth.isAdmin,
                  onDelete: () => _delete(review),
                ),
              ),
          ],
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(
          kicker: 'Reviews',
          title: 'Real talk',
          accent: 'only.',
        ),
        const SizedBox(height: 28),
        if (compact) ...[
          summary,
          const SizedBox(height: 24),
          list,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 340, child: summary),
              const SizedBox(width: 40),
              Expanded(child: list),
            ],
          ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.canDelete,
    required this.onDelete,
  });

  final Review review;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = (review.authorName ?? '').trim().isEmpty
        ? 'Shopper'
        : review.authorName!.trim();
    return InkCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.sky,
                child: Text(
                  name[0].toUpperCase(),
                  style: AppText.label(size: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppText.body(14, weight: FontWeight.w700),
                    ),
                    Text(
                      formatDate(review.createdAt),
                      style: AppText.body(12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              StarRating(rating: review.rating.toDouble(), size: 16),
              if (canDelete)
                IconButton(
                  tooltip: 'Delete review',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment, style: AppText.body(15)),
          ],
        ],
      ),
    );
  }
}
