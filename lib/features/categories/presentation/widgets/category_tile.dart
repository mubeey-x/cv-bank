import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cv_bank/core/common/widgets/app_text_field.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/categories/domain/entities/category.dart';
import 'package:cv_bank/features/categories/presentation/controllers/category_controller.dart';

// =====================================================================
// Tile
// =====================================================================

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    required this.onMenu,
    this.showHandle = false,
  });

  final Category category;
  final VoidCallback onTap;
  final VoidCallback onMenu;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimmed = !category.isActive;

    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md + 2,
              AppSpacing.sm,
              AppSpacing.md + 2,
            ),
            child: Row(
              children: [
                if (showHandle) ...[
                  const Icon(
                    Icons.drag_indicator,
                    size: 20,
                    color: AppColors.inkDisabled,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              category.name,
                              style: theme.textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (dimmed) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutralTint,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                'Off',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: AppColors.neutralInk,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        category.pool == 0
                            ? 'No one yet'
                            : '${category.pool} '
                                  '${category.pool == 1 ? 'person' : 'people'}'
                                  ' · ${category.employed} placed',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                // A thin progress line reads better than a second
                // number fighting the one above it.
                if (category.pool > 0)
                  SizedBox(
                    width: 54,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 5,
                        child: LinearProgressIndicator(
                          value: category.employedRatio,
                          backgroundColor: AppColors.surfaceAlt,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.employed,
                          ),
                        ),
                      ),
                    ),
                  ),

                IconButton(
                  onPressed: onMenu,
                  icon: const Icon(Icons.more_vert, size: 20),
                  color: AppColors.inkMuted,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Create / rename sheet
//
// A sheet rather than a route: one field does not deserve a screen,
// an app bar and a navigation transition.
// =====================================================================

Future<void> showCategorySheet(BuildContext context, {Category? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CategorySheet(existing: existing),
  );
}

class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet({this.existing});

  final Category? existing;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  String? _error;

  bool get _isEdit => widget.existing != null;
  bool get _canSave =>
      _name.text.trim().isNotEmpty &&
      _name.text.trim() != widget.existing?.name;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _error = null);

    final actions = ref.read(categoryActionsProvider.notifier);
    final failure = _isEdit
        ? await actions.rename(id: widget.existing!.id, name: _name.text)
        : await actions.create(_name.text);

    if (!mounted) return;

    if (failure != null) {
      setState(() => _error = failure.message);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = ref.watch(categoryActionsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.sm,
        // Lifts the sheet above the keyboard.
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEdit ? 'Rename category' : 'New category',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            label: 'Name',
            controller: _name,
            hint: 'e.g. Education',
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 40,
            enabled: !isBusy,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _canSave ? _save() : null,
          ),

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm + 2),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.destructiveInk,
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: isBusy || !_canSave ? null : _save,
            child: isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Actions menu
// =====================================================================

Future<void> showCategoryMenu(
  BuildContext context,
  WidgetRef ref,
  Category category,
) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(category.name, style: theme.textTheme.titleMedium),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showCategorySheet(context, existing: category);
              },
            ),

            ListTile(
              leading: Icon(
                category.isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              title: Text(category.isActive ? 'Turn off' : 'Turn on'),
              subtitle: category.isActive
                  ? const Text('Hides it when adding people')
                  : null,
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(categoryActionsProvider.notifier)
                    .setActive(id: category.id, isActive: !category.isActive);
              },
            ),

            // Deleting a populated category would silently
            // uncategorise everyone in it, so the option is only
            // offered when it is empty.
            if (!category.hasPeople)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.destructive,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.destructive),
                ),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await _confirmDelete(context, category);
                  if (confirmed) {
                    await ref
                        .read(categoryActionsProvider.notifier)
                        .delete(category);
                  }
                },
              ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      );
    },
  );
}

Future<bool> _confirmDelete(BuildContext context, Category category) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete "${category.name}"?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}
