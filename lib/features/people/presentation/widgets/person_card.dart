import 'dart:io';

import 'package:cv_bank/features/people/presentation/controllers/person_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:cv_bank/core/common/widgets/app_text_field.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/core/utils/date_format.dart';
import 'package:cv_bank/features/categories/presentation/controllers/category_controller.dart';
import 'package:cv_bank/features/people/domain/entities/person.dart';
import 'package:cv_bank/features/people/domain/entities/person_document.dart';

// =====================================================================
// Status badge
// =====================================================================

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.isEmployed,
    this.compact = false,
  });

  final bool isEmployed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: isEmployed ? AppColors.employedTint : AppColors.neutralTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        isEmployed ? 'Employed' : 'Waiting',
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: isEmployed ? AppColors.employedInk : AppColors.neutralInk,
        ),
      ),
    );
  }
}

// =====================================================================
// Person card
// =====================================================================

class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key,
    required this.person,
    required this.onTap,
    this.onToggleEmployment,
  });

  final Person person;
  final VoidCallback onTap;
  final VoidCallback? onToggleEmployment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          child: Row(
            children: [
              _Avatar(initials: person.initials),
              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.fullName,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            person.subtitle,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (person.hasDocuments) ...[
                          const SizedBox(width: AppSpacing.xs + 2),
                          const Icon(
                            Icons.attach_file,
                            size: 13,
                            color: AppColors.inkMuted,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Tapping the badge is the fastest path to the action
              // that matters most on this screen.
              InkWell(
                onTap: onToggleEmployment,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: StatusBadge(isEmployed: person.isEmployed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials}) : size = 42;

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// =====================================================================
// Category chips
//
// Chips rather than a dropdown: one tap, no scrolling list, no
// keyboard. This is the field that has to be fastest.
// =====================================================================

class CategoryChips extends ConsumerWidget {
  const CategoryChips({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activeCategoryNamesProvider);

    return async.when(
      loading: () => const SizedBox(
        height: 34,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => Text(
        'Could not load categories',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      data: (categories) => Wrap(
        spacing: AppSpacing.sm - 2,
        runSpacing: AppSpacing.sm - 2,
        children: [
          for (final category in categories)
            ChoiceChip(
              label: Text(category.name),
              selected: selectedId == category.id,
              onSelected: (picked) => onSelected(picked ? category.id : null),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
// Employment confirmation
//
// Confirming matters because this number drives the whole dashboard
// and a mis-tap would corrupt it quietly. The role field is optional
// so someone in a hurry can tap straight through.
// =====================================================================

Future<bool> showEmploymentSheet(BuildContext context, Person person) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EmploymentSheet(person: person),
  );
  return result ?? false;
}

class _EmploymentSheet extends ConsumerStatefulWidget {
  const _EmploymentSheet({required this.person});

  final Person person;

  @override
  ConsumerState<_EmploymentSheet> createState() => _EmploymentSheetState();
}

class _EmploymentSheetState extends ConsumerState<_EmploymentSheet> {
  final _role = TextEditingController();
  final _org = TextEditingController();
  String? _error;

  bool get _isMarkingEmployed => !widget.person.isEmployed;

  @override
  void dispose() {
    _role.dispose();
    _org.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final actions = ref.read(personActionsProvider.notifier);

    final failure = _isMarkingEmployed
        ? await actions.markEmployed(
            personId: widget.person.id,
            positionTitle: _role.text,
            organisation: _org.text,
          )
        : await actions.markUnemployed(widget.person.id);

    if (!mounted) return;

    if (failure != null) {
      setState(() => _error = failure.message);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = ref.watch(personActionsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isMarkingEmployed
                ? 'Mark ${widget.person.fullName} as employed?'
                : 'Move ${widget.person.fullName} back to waiting?',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm - 2),
          Text(
            _isMarkingEmployed
                ? 'Today\'s date is recorded automatically.'
                : 'Their current placement will be closed. The history '
                      'is kept.',
            style: theme.textTheme.bodyMedium,
          ),

          if (_isMarkingEmployed) ...[
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Role (optional)',
              controller: _role,
              hint: 'e.g. Education officer',
              textCapitalization: TextCapitalization.sentences,
              enabled: !isBusy,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Organisation (optional)',
              controller: _org,
              hint: 'Where',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              enabled: !isBusy,
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.destructiveInk,
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: FilledButton(
                  onPressed: isBusy ? null : _confirm,
                  child: isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isMarkingEmployed ? 'Confirm' : 'Move back'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Filters
// =====================================================================

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final query = ref.watch(personFiltersProvider);
    final filters = ref.read(personFiltersProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: theme.textTheme.titleMedium),
                if (query.hasFilters)
                  TextButton(
                    onPressed: () {
                      filters.clearAll();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear all'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _FilterLabel('Status'),
            Wrap(
              spacing: AppSpacing.sm - 2,
              children: [
                for (final status in EmploymentStatus.values)
                  ChoiceChip(
                    label: Text(status.label),
                    selected: query.status == status,
                    onSelected: (picked) =>
                        filters.setStatus(picked ? status : null),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _FilterLabel('Category'),
            CategoryChips(
              selectedId: query.categoryId,
              onSelected: filters.setCategory,
            ),
            const SizedBox(height: AppSpacing.lg),

            _FilterLabel('Qualification'),
            Wrap(
              spacing: AppSpacing.sm - 2,
              runSpacing: AppSpacing.sm - 2,
              children: [
                for (final q in QualificationLevel.values)
                  ChoiceChip(
                    label: Text(q.label),
                    selected: query.qualification == q,
                    onSelected: (picked) =>
                        filters.setQualification(picked ? q : null),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Show results'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.inkSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// =====================================================================
// File picking
//
// Camera first in the list, because photographing a paper CV is the
// fastest capture and paper is what most people are handed.
// =====================================================================

Future<DocumentUpload?> pickDocument(BuildContext context) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            subtitle: const Text('Fastest for a paper CV'),
            onTap: () => Navigator.of(sheetContext).pop('camera'),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.of(sheetContext).pop('gallery'),
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: const Text('Pick a file'),
            subtitle: const Text('PDF or Word'),
            onTap: () => Navigator.of(sheetContext).pop('file'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );

  if (choice == null) return null;

  switch (choice) {
    case 'camera':
    case 'gallery':
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        // Compressed, because a raw phone photo can be 12MB and the
        // free storage tier is 1GB.
        imageQuality: 75,
        maxWidth: 2000,
      );
      if (image == null) return null;

      return DocumentUpload(
        filePath: image.path,
        fileName: p.basename(image.path),
        mimeType: 'image/jpeg',
      );

    case 'file':
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      final picked = result?.files.single;
      if (picked?.path == null) return null;

      return DocumentUpload(
        filePath: picked!.path!,
        fileName: picked.name,
        mimeType: _mimeFor(picked.extension),
      );
  }
  return null;
}

String? _mimeFor(String? extension) => switch (extension?.toLowerCase()) {
  'pdf' => 'application/pdf',
  'doc' => 'application/msword',
  'docx' =>
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'jpg' || 'jpeg' => 'image/jpeg',
  'png' => 'image/png',
  _ => null,
};

Future<int?> fileSize(String path) async {
  try {
    return await File(path).length();
  } catch (_) {
    return null;
  }
}

// =====================================================================
// Document row
// =====================================================================

class DocumentRow extends StatelessWidget {
  const DocumentRow({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
  });

  final PersonDocument document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          document.isImage ? Icons.image_outlined : Icons.description_outlined,
          size: 20,
          color: AppColors.primary,
        ),
      ),
      title: Text(document.kind.label, style: theme.textTheme.titleSmall),
      subtitle: Text(
        [
          AppDate.short(document.createdAt),
          if (document.readableSize.isNotEmpty) document.readableSize,
        ].join(' · '),
        style: theme.textTheme.bodyMedium,
      ),
      trailing: onDelete == null
          ? const Icon(Icons.chevron_right, color: AppColors.inkMuted)
          : IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.inkMuted,
              onPressed: onDelete,
            ),
      onTap: onTap,
    );
  }
}
