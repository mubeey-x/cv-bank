
import 'dart:io';

import 'package:cv_bank/features/people/presentation/widgets/person_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';

import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/core/utils/date_format.dart';
import 'package:cv_bank/core/utils/phone_normalizer.dart';
import 'package:cv_bank/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:cv_bank/features/people/domain/entities/person.dart';
import 'package:cv_bank/features/people/domain/entities/person_document.dart';
import 'package:cv_bank/features/people/presentation/controllers/person_controller.dart';

// =====================================================================
// Detail
// =====================================================================

class PersonDetailScreen extends ConsumerWidget {
  const PersonDetailScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(personDetailProvider(personId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Person'),
        actions: [
          if (async.hasValue)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(AppRoutes.peopleEditPath(personId)),
            ),
        ],
      ),

      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              failureFrom(error).message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        data: (person) => _DetailBody(person: person),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final documents = ref.watch(personDocumentsProvider(person.id));
    final placements = ref.watch(personPlacementsProvider(person.id));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Text(
                      person.initials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.fullName,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs + 2),
                        StatusBadge(isEmployed: person.isEmployed),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Contact actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _launch(PhoneNormalizer.telUri(person.phone)),
                      icon: const Icon(Icons.call_outlined, size: 18),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _launch(PhoneNormalizer.whatsAppUri(person.phone)),
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Details
              _Section(
                title: 'Details',
                child: Column(
                  children: [
                    _Field(label: 'Phone', value: person.displayPhone),
                    _Field(label: 'Category', value: person.categoryName),
                    _Field(label: 'Email', value: person.email),
                    _Field(
                      label: 'Qualification',
                      value: person.qualification?.label,
                    ),
                    _Field(label: 'Course', value: person.courseOfStudy),
                    _Field(label: 'Institution', value: person.institution),
                    _Field(
                      label: 'Experience',
                      value: person.yearsExperience == null
                          ? null
                          : '${person.yearsExperience} years',
                    ),
                    _Field(
                      label: 'Occupation',
                      value: person.currentOccupation,
                    ),
                    _Field(label: 'Referred by', value: person.referrerName),
                    _Field(
                      label: 'Added',
                      value: AppDate.full(person.receivedOn),
                    ),
                  ],
                ),
              ),

              if (!person.hasDetail) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () =>
                      context.push(AppRoutes.peopleEditPath(person.id)),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add more details'),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Documents
              _Section(
                title: 'Documents',
                action: TextButton(
                  onPressed: () => _attach(context, ref, person.id),
                  child: const Text('Add'),
                ),
                child: documents.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, _) => Text(
                    'Could not load documents.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  data: (docs) => docs.isEmpty
                      ? Text(
                          'No files attached.',
                          style: theme.textTheme.bodyMedium,
                        )
                      : Column(
                          children: [
                            for (final doc in docs)
                              DocumentRow(
                                document: doc,
                                onTap: () => context.push(
                                  AppRoutes.peopleDocumentPath(
                                    person.id,
                                    doc.id,
                                  ),
                                  extra: doc,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Placement history
              _Section(
                title: 'Placement history',
                child: placements.when(
                  loading: () => const SizedBox(height: 20),
                  error: (_, _) => Text(
                    'Could not load history.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  data: (list) => list.isEmpty
                      ? Text(
                          'No placements yet.',
                          style: theme.textTheme.bodyMedium,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final placement in list)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: BoxDecoration(
                                        color: placement.isCurrent
                                            ? AppColors.employed
                                            : AppColors.borderStrong,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            placement.description ??
                                                'Placement',
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          Text(
                                            placement.endedOn == null
                                                ? 'Since ${AppDate.full(placement.startedOn)}'
                                                : '${AppDate.short(placement.startedOn)} – '
                                                      '${AppDate.short(placement.endedOn!)}',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),

        // Primary action, outside the scroll view.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: FilledButton(
            onPressed: () => showEmploymentSheet(context, person),
            style: person.isEmployed
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.borderStrong),
                  )
                : null,
            child: Text(
              person.isEmployed ? 'Move back to waiting' : 'Mark as employed',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _attach(
    BuildContext context,
    WidgetRef ref,
    String personId,
  ) async {
    final upload = await pickDocument(context);
    if (upload == null) return;

    final size = await fileSize(upload.filePath);
    final failure = await ref
        .read(personActionsProvider.notifier)
        .attachDocument(personId: personId, upload: upload, sizeBytes: size);

    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  static Future<void> _launch(Uri? uri) async {
    if (uri == null) return;
    await OpenFilex.open(uri.toString());
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              ?action,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// Renders nothing when the value is null, so a record captured in
/// thirty seconds does not show ten empty rows.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(child: Text(value!, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

// =====================================================================
// Document viewer
// =====================================================================

class DocumentViewerScreen extends ConsumerWidget {
  const DocumentViewerScreen({super.key, required this.document});

  final PersonDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(documentFileProvider(document));

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        title: Text(
          document.fileName,
          style: const TextStyle(fontSize: 15, color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (async.hasValue)
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () => SharePlus.instance.share(
                ShareParams(files: [XFile(async.value!)]),
              ),
            ),
        ],
      ),

      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              failureFrom(error).message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
        data: (path) {
          if (document.isPdf) {
            return PdfViewer.file(path);
          }
          if (document.isImage) {
            return InteractiveViewer(
              maxScale: 5,
              child: Center(child: Image.file(File(path))),
            );
          }

          // Word documents cannot render in Flutter, so they are
          // handed to whatever the phone has installed.
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 40,
                  color: Colors.white54,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'This file opens in another app.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => OpenFilex.open(path),
                  child: const Text('Open'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
