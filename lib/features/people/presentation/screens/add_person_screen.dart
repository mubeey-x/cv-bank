import 'package:cv_bank/features/people/presentation/widgets/person_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/common/widgets/app_text_field.dart';
import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/people/domain/entities/new_person.dart';
import 'package:cv_bank/features/people/presentation/controllers/person_controller.dart';

/// Three fields and a file. Everything else is on the edit screen,
/// because the whole point is that adding someone takes seconds.
class AddPersonScreen extends ConsumerStatefulWidget {
  const AddPersonScreen({super.key, this.categoryId});

  /// Pre-selected when arriving from a category screen.
  final String? categoryId;

  @override
  ConsumerState<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends ConsumerState<AddPersonScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  String? _categoryId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _name.text.trim().isNotEmpty && _phone.text.trim().isNotEmpty;

  Future<void> _pickFile() async {
    final upload = await pickDocument(context);
    if (upload == null || !mounted) return;

    final size = await fileSize(upload.filePath);
    ref.read(intakeControllerProvider.notifier).attachFile(upload, size);
    setState(() {});

    // Pre-fill whatever came back, but never overwrite something the
    // user has already typed.
    final extracted = ref.read(intakeControllerProvider).extracted;
    if (extracted != null) {
      if (_name.text.isEmpty && extracted.fullName != null) {
        _name.text = extracted.fullName!;
      }
      if (_phone.text.isEmpty && extracted.phone != null) {
        _phone.text = extracted.phone!;
        ref.read(intakeControllerProvider.notifier).checkPhone(_phone.text);
      }
      setState(() {});
    }
  }

  Future<void> _save({required bool addAnother}) async {
    setState(() => _error = null);
    FocusScope.of(context).unfocus();

    // Captured before the save, since reset() clears it afterwards.
    final intake = ref.read(intakeControllerProvider.notifier);
    final pending = intake.pendingUpload;
    final pendingSize = intake.pendingSize;

    final (person, failure) = await ref
        .read(personActionsProvider.notifier)
        .add(
          NewPerson(
            fullName: _name.text,
            phone: _phone.text,
            categoryId: _categoryId,
          ),
        );

    if (!mounted) return;

    if (failure != null || person == null) {
      setState(() => _error = failure?.message ?? 'Could not save.');
      return;
    }

    // Now that the row exists, the file has a real person_id to hang
    // off. A failure here does not lose the person.
    if (pending != null) {
      final uploadFailure = await ref
          .read(personActionsProvider.notifier)
          .attachDocument(
            personId: person.id,
            upload: pending,
            sizeBytes: pendingSize,
          );

      if (uploadFailure != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved, but the file did not upload.')),
        );
      }
    }

    if (!mounted) return;
    intake.reset();

    if (addAnother) {
      // Category is kept: a stack of CVs usually comes from one place
      // at one time.
      _name.clear();
      _phone.clear();
      setState(() {});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${person.fullName} saved.')));
    } else {
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${person.fullName} saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intake = ref.watch(intakeControllerProvider);
    final isBusy = ref.watch(personActionsProvider) || intake.isBusy;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add person')),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                children: [
                  _FileTile(
                    fileName: intake.fileName,
                    isUploading: intake.isUploading,
                    isExtracting: intake.isExtracting,
                    hasExtracted:
                        intake.extracted != null && !intake.extracted!.isEmpty,
                    onTap: isBusy ? null : _pickFile,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    label: 'Name',
                    controller: _name,
                    hint: 'Full name',
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    enabled: !isBusy,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    label: 'Phone',
                    controller: _phone,
                    hint: '0803 000 0000',
                    keyboardType: TextInputType.phone,
                    enabled: !isBusy,
                    onChanged: (value) {
                      setState(() {});
                      ref
                          .read(intakeControllerProvider.notifier)
                          .checkPhone(value);
                    },
                  ),

                  // Caught while typing, so a duplicate never reaches
                  // the save button.
                  if (intake.duplicate != null) ...[
                    const SizedBox(height: AppSpacing.sm + 2),
                    _DuplicateBanner(
                      name: intake.duplicate!.fullName,
                      onOpen: () => context.pushReplacement(
                        AppRoutes.peopleDetailPath(intake.duplicate!.id),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Category',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CategoryChips(
                    selectedId: _categoryId,
                    onSelected: (id) => setState(() => _categoryId = id),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.destructiveInk,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Qualification, referrer and notes can be added later.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Outside the scroll view: Expanded or Spacer inside one
            // has no bounded height to work with.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: isBusy || !_canSave
                          ? null
                          : () => _save(addAnother: false),
                      child: isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isBusy || !_canSave
                          ? null
                          : () => _save(addAnother: true),
                      child: const Text('Save & add'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.fileName,
    required this.isUploading,
    required this.isExtracting,
    required this.hasExtracted,
    required this.onTap,
  });

  final String? fileName;
  final bool isUploading;
  final bool isExtracting;
  final bool hasExtracted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = fileName != null;
    final busy = isUploading || isExtracting;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        decoration: BoxDecoration(
          color: hasExtracted ? AppColors.employedTint : AppColors.surface,
          border: Border.all(
            color: hasExtracted ? AppColors.employedTint : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          children: [
            if (busy)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                hasFile
                    ? Icons.description_outlined
                    : Icons.add_photo_alternate_outlined,
                size: 22,
                color: hasExtracted ? AppColors.employedInk : AppColors.primary,
              ),
            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? fileName! : 'Attach the CV',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: hasExtracted ? AppColors.employedInk : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isUploading
                        ? 'Uploading…'
                        : isExtracting
                        ? 'Reading the details…'
                        : hasExtracted
                        ? 'Details found, please check them'
                        : hasFile
                        ? 'Tap to change'
                        : 'Photo or file. Optional.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasExtracted ? AppColors.employedInk : null,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuplicateBanner extends StatelessWidget {
  const _DuplicateBanner({required this.name, required this.onOpen});

  final String name;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.attentionTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.attentionInk,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$name already has this number.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.attentionInk,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onOpen,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.attentionInk,
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}
