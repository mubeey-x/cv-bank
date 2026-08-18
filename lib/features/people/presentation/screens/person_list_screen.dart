import 'package:cv_bank/features/people/presentation/widgets/person_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:cv_bank/features/people/domain/entities/person.dart';
import 'package:cv_bank/features/people/presentation/controllers/person_controller.dart';

class PersonListScreen extends ConsumerStatefulWidget {
  const PersonListScreen({super.key, this.initialStatus});

  /// From the dashboard, e.g. tapping "86 employed".
  final EmploymentStatus? initialStatus;

  @override
  ConsumerState<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends ConsumerState<PersonListScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.initialStatus != null) {
      // After the first frame: setting state during build throws.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(personFiltersProvider.notifier)
            .setStatus(widget.initialStatus);
      });
    }

    _scroll.addListener(() {
      // Loads the next page a little before the bottom, so scrolling
      // does not visibly stall.
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
        ref.read(personListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(personListControllerProvider);
    final query = ref.watch(personFiltersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('People')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.peopleCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add person'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (value) => ref
                        .read(personFiltersProvider.notifier)
                        .setSearch(value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search name or phone',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _search.clear();
                                ref
                                    .read(personFiltersProvider.notifier)
                                    .setSearch('');
                                setState(() {});
                              },
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterButton(count: query.activeFilterCount),
              ],
            ),
          ),

          Expanded(
            child: async.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) => _Message(
                icon: Icons.cloud_off_outlined,
                text: failureFrom(error).message,
                actionLabel: 'Try again',
                onAction: () => ref.invalidate(personListControllerProvider),
              ),
              data: (listState) {
                if (listState.people.isEmpty) {
                  return _Message(
                    icon: Icons.person_search_outlined,
                    text:
                        query.hasFilters || (query.search?.isNotEmpty ?? false)
                        ? 'Nobody matches that.'
                        : 'No one here yet. Add your first person.',
                    actionLabel: query.hasFilters ? 'Clear filters' : null,
                    onAction: query.hasFilters
                        ? () => ref
                              .read(personFiltersProvider.notifier)
                              .clearAll()
                        : null,
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      ref.read(personListControllerProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      96,
                    ),
                    itemCount:
                        listState.people.length +
                        (listState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= listState.people.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final person = listState.people[i];
                      return PersonCard(
                        person: person,
                        onTap: () =>
                            context.push(AppRoutes.peopleDetailPath(person.id)),
                        onToggleEmployment: () =>
                            showEmploymentSheet(context, person),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showFilterSheet(context),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: count > 0 ? AppColors.primaryTint : AppColors.surface,
          border: Border.all(
            color: count > 0 ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune,
              size: 20,
              color: count > 0 ? AppColors.primary : AppColors.inkSecondary,
            ),
            if (count > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 15,
                  height: 15,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: AppColors.inkMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(150, 44),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
