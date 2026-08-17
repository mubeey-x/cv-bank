import 'package:cv_bank/features/dashboard/presentation/widgets/category_breakdown_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/auth/data/providers/auth_providers.dart';
import 'package:cv_bank/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:cv_bank/features/dashboard/presentation/controllers/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.peopleCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add person'),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
          child: async.when(
            loading: () => const _Loading(),
            error: (error, _) => _Error(
              message: failureFrom(error).message,
              onRetry: () => ref.invalidate(dashboardControllerProvider),
            ),
            data: (stats) => stats.totals.isEmpty
                ? const _FirstRun()
                : _Loaded(stats: stats),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Loaded
// =====================================================================

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      // Always scrollable, otherwise pull to refresh does nothing on
      // a short screen.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg + 2,
        0,
        AppSpacing.lg + 2,
        96, // clears the FAB
      ),
      children: [
        const _Header(),
        const SizedBox(height: AppSpacing.md + 2),

        TotalsCard(
          totals: stats.totals,
          onTapSegment: (employed) => context.go(
            '${AppRoutes.people}?status=${employed ? 'employed' : 'unemployed'}',
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        MonthlyTiles(
          added: stats.totals.newThisMonth,
          placed: stats.placedThisMonth,
        ),
        const SizedBox(height: AppSpacing.md),

        RecentPlacementsCard(
          placements: stats.recentPlacements,
          onSeeAll: () => context.go('${AppRoutes.people}?status=employed'),
          onTapPerson: (id) => context.push(AppRoutes.peopleDetailPath(id)),
        ),
        const SizedBox(height: AppSpacing.md),

        CategoryBreakdownCard(
          categories: stats.populatedCategories,
          onTapCategory: (id) => context.push(AppRoutes.categoryDetailPath(id)),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final account = ref.watch(authStateProvider).value;
    final name = account?.name.trim();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(), style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  name == null || name.isEmpty ? 'Welcome' : name,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.go(AppRoutes.people),
            borderRadius: BorderRadius.circular(19),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.search,
                size: 19,
                color: AppColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// =====================================================================
// First run
//
// A dashboard of zeros teaches a new account nothing. Replace the
// whole body with one instruction.
// =====================================================================

class _FirstRun extends StatelessWidget {
  const _FirstRun();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      children: [
        const _Header(),
        const SizedBox(height: AppSpacing.xxl * 2),
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Icon(
            Icons.folder_outlined,
            size: 30,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Your CV bank is empty',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Add the first person and your numbers will start here.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: () => context.push(AppRoutes.peopleCreate),
          child: const Text('Add your first person'),
        ),
      ],
    );
  }
}

// =====================================================================
// Loading and error
// =====================================================================

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    // Skeleton rather than a spinner: the shape appears immediately,
    // so the screen does not jump when data lands.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg + 2,
        AppSpacing.xl,
        AppSpacing.lg + 2,
        AppSpacing.xl,
      ),
      children: const [
        _Skeleton(height: 20, width: 120),
        SizedBox(height: AppSpacing.sm),
        _Skeleton(height: 26, width: 180),
        SizedBox(height: AppSpacing.xl),
        _Skeleton(height: 132),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _Skeleton(height: 74)),
            SizedBox(width: AppSpacing.sm + 2),
            Expanded(child: _Skeleton(height: 74)),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        _Skeleton(height: 190),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(minimumSize: const Size(140, 44)),
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}
