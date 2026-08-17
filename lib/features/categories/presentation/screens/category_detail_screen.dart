import 'package:cv_bank/features/categories/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/categories/presentation/controllers/category_controller.dart';

/// The people inside one category.

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoryListControllerProvider);

    final category = async.valueOrNull
        ?.where((c) => c.id == categoryId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(category?.name ?? 'Category'),
        actions: [
          if (category != null)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => showCategoryMenu(context, ref, category),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        // Carries the category through, so the intake form arrives
        // with the chip already selected.
        onPressed: () =>
            context.push(AppRoutes.peopleCreateInCategory(categoryId)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add person'),
      ),

      body: Column(
        children: [
          if (category != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  _Stat(label: 'In this category', value: category.pool),
                  const SizedBox(width: AppSpacing.xl),
                  _Stat(
                    label: 'Placed',
                    value: category.employed,
                    colour: AppColors.employed,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _Stat(label: 'Waiting', value: category.waiting),
                ],
              ),
            ),

          const Expanded(child: Center(child: Text('People list goes here'))),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.colour});

  final String label;
  final int value;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: colour,
          ),
        ),
      ],
    );
  }
}
