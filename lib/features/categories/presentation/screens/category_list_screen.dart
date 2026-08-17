
import 'package:cv_bank/features/categories/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/categories/domain/entities/category.dart';
import 'package:cv_bank/features/categories/presentation/controllers/category_controller.dart';
import 'package:cv_bank/features/dashboard/presentation/controllers/dashboard_controller.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  bool _reordering = false;

  /// Local copy while dragging. ReorderableListView needs the list to
  /// change immediately, before the server round trip finishes.
  List<Category>? _draft;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(categoryListControllerProvider);
    final showInactive = ref.watch(showInactiveProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          if (!_reordering)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'reorder':
                    setState(() {
                      _reordering = true;
                      _draft = async.valueOrNull?.toList();
                    });
                  case 'inactive':
                    ref.read(showInactiveProvider.notifier).toggle();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'reorder', child: Text('Reorder')),
                PopupMenuItem(
                  value: 'inactive',
                  child: Text(
                    showInactive ? 'Hide turned off' : 'Show turned off',
                  ),
                ),
              ],
            )
          else
            TextButton(onPressed: _saveOrder, child: const Text('Done')),
        ],
      ),

      floatingActionButton: _reordering
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showCategorySheet(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New category'),
            ),

      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _ErrorView(
          message: failureFrom(error).message,
          onRetry: () => ref.invalidate(categoryListControllerProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) return const _EmptyView();

          return _reordering
              ? _buildReorderable(_draft ?? categories)
              : _buildList(categories);
        },
      ),
    );
  }

  Widget _buildList(List<Category> categories) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(categoryListControllerProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          96,
        ),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final category = categories[i];
          return CategoryTile(
            category: category,
            onTap: () =>
                context.push(AppRoutes.categoryDetailPath(category.id)),
            onMenu: () => showCategoryMenu(context, ref, category),
          );
        },
      ),
    );
  }

  Widget _buildReorderable(List<Category> categories) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          // ReorderableListView reports the target index before the
          // item is removed, so anything moving down is off by one.
          if (newIndex > oldIndex) newIndex -= 1;
          final list = [...categories];
          final item = list.removeAt(oldIndex);
          list.insert(newIndex, item);
          _draft = list;
        });
      },
      itemBuilder: (context, i) {
        final category = categories[i];
        return Padding(
          key: ValueKey(category.id),
          padding: EdgeInsets.zero,
          child: CategoryTile(
            category: category,
            showHandle: true,
            onTap: () {},
            onMenu: () {},
          ),
        );
      },
    );
  }

  Future<void> _saveOrder() async {
    final draft = _draft;
    setState(() => _reordering = false);

    if (draft == null) return;

    final failure = await ref
        .read(categoryActionsProvider.notifier)
        .reorder(draft.map((c) => c.id).toList());

    if (!mounted) return;

    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
    setState(() => _draft = null);
  }
}

// =====================================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl * 2,
      ),
      children: [
        const Icon(Icons.label_outline, size: 34, color: AppColors.inkMuted),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'No categories yet',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Categories are how you group people. Create the ones that '
          'match your work.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 34,
              color: AppColors.inkMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(minimumSize: const Size(140, 44)),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
