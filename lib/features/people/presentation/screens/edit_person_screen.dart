import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/features/people/presentation/widgets/person_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/common/widgets/app_text_field.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:cv_bank/features/people/domain/entities/new_person.dart';
import 'package:cv_bank/features/people/domain/entities/person.dart';
import 'package:cv_bank/features/people/presentation/controllers/person_controller.dart';

/// Everything intake deliberately skipped. Reached from the detail
/// screen, at whatever pace the account holder cares to fill it in.
class PersonEditScreen extends ConsumerWidget {
  const PersonEditScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(personDetailProvider(personId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit details')),
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
        // Keyed on the id so the form state resets if the screen is
        // ever reused for a different person.
        data: (person) => _EditForm(key: ValueKey(person.id), person: person),
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({super.key, required this.person});

  final Person person;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  late final _name = TextEditingController(text: widget.person.fullName);
  late final _phone = TextEditingController(text: widget.person.phone);
  late final _email = TextEditingController(text: widget.person.email ?? '');
  late final _course = TextEditingController(
    text: widget.person.courseOfStudy ?? '',
  );
  late final _institution = TextEditingController(
    text: widget.person.institution ?? '',
  );
  late final _experience = TextEditingController(
    text: widget.person.yearsExperience?.toString() ?? '',
  );
  late final _occupation = TextEditingController(
    text: widget.person.currentOccupation ?? '',
  );
  late final _referrer = TextEditingController(
    text: widget.person.referrerName ?? '',
  );
  late final _notes = TextEditingController(text: widget.person.notes ?? '');

  late String? _categoryId = widget.person.categoryId;
  late QualificationLevel? _qualification = widget.person.qualification;
  late IntakeChannel? _channel = widget.person.channel;
  late final RelationshipTier _relationship = widget.person.relationship;

  String? _error;
  bool _dirty = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _email,
      _course,
      _institution,
      _experience,
      _occupation,
      _referrer,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _touch() {
    if (!_dirty) setState(() => _dirty = true);
  }

  /// Only changed fields are sent. Everything else stays null, and
  /// the repository leaves those columns alone.
  PersonUpdate _buildUpdate() {
    final p = widget.person;

    String? changed(TextEditingController c, String? original) {
      final value = c.text.trim();
      if (value == (original?.trim() ?? '')) return null;
      return value;
    }

    final years = _experience.text.trim();
    final parsedYears = years.isEmpty ? null : int.tryParse(years);

    return PersonUpdate(
      fullName: changed(_name, p.fullName),
      phone: changed(_phone, p.phone),
      categoryId: _categoryId == p.categoryId ? null : _categoryId,
      email: changed(_email, p.email),
      qualification: _qualification == p.qualification ? null : _qualification,
      courseOfStudy: changed(_course, p.courseOfStudy),
      institution: changed(_institution, p.institution),
      yearsExperience: parsedYears == p.yearsExperience ? null : parsedYears,
      currentOccupation: changed(_occupation, p.currentOccupation),
      referrerName: changed(_referrer, p.referrerName),
      channel: _channel == p.channel ? null : _channel,
      relationship: _relationship == p.relationship ? null : _relationship,
      notes: changed(_notes, p.notes),
    );
  }

  Future<void> _save() async {
    setState(() => _error = null);
    FocusScope.of(context).unfocus();

    final failure = await ref
        .read(personActionsProvider.notifier)
        .update(widget.person.id, _buildUpdate());

    if (!mounted) return;

    if (failure != null) {
      setState(() => _error = failure.message);
      return;
    }
    context.pop();
  }

  Future<void> _confirmArchive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${widget.person.fullName}?'),
        content: const Text(
          'They will no longer appear in your lists or counts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final failure = await ref
        .read(personActionsProvider.notifier)
        .archive(widget.person.id);

    if (!mounted) return;

    if (failure != null) {
      setState(() => _error = failure.message);
      return;
    }
    // Past the detail screen too, since the person it shows is gone.
    context.go(AppRoutes.people);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = ref.watch(personActionsProvider);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmDiscard(context);
        if (leave == true && context.mounted) context.pop();
      },
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
                _Label('Basics'),
                AppTextField(
                  label: 'Name',
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Phone',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
                ),
                const SizedBox(height: AppSpacing.lg),

                _Label('Category'),
                CategoryChips(
                  selectedId: _categoryId,
                  onSelected: (id) {
                    setState(() => _categoryId = id);
                    _touch();
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                _Label('Education'),
                _EnumChips<QualificationLevel>(
                  values: QualificationLevel.values,
                  selected: _qualification,
                  labelOf: (q) => q.label,
                  onSelected: (q) {
                    setState(() => _qualification = q);
                    _touch();
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Course of study',
                  controller: _course,
                  textCapitalization: TextCapitalization.words,
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Institution',
                  controller: _institution,
                  textCapitalization: TextCapitalization.words,
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
                ),
                const SizedBox(height: AppSpacing.lg),

                _Label('Work'),
                AppTextField(
                  label: 'Current occupation',
                  controller: _occupation,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Years of experience',
                  controller: _experience,
                  keyboardType: TextInputType.number,
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
                ),
                const SizedBox(height: AppSpacing.lg),

                _Label('Where they came from'),
                AppTextField(
                  label: 'Referred by',
                  controller: _referrer,
                  hint: 'Who put them forward',
                  textCapitalization: TextCapitalization.words,
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
                ),
                const SizedBox(height: AppSpacing.md),
                _EnumChips<IntakeChannel>(
                  values: IntakeChannel.values,
                  selected: _channel,
                  labelOf: (c) => c.label,
                  onSelected: (c) {
                    setState(() => _channel = c);
                    _touch();
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                _Label('Notes'),
                AppTextField(
                  label: 'Anything worth remembering',
                  controller: _notes,
                  hint: 'Private to you',
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  
                  enabled: !isBusy,
                  onChanged: (_) => _touch(),
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

                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: TextButton.icon(
                    onPressed: isBusy ? null : _confirmArchive,
                    icon: const Icon(Icons.person_remove_outlined, size: 18),
                    label: const Text('Remove this person'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: FilledButton(
              onPressed: isBusy || !_dirty ? null : _save,
              child: isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _confirmDiscard(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Discard changes?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep editing'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
}

// =====================================================================

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Chips rather than a dropdown, for the same reason as the category
/// field: one tap and no keyboard. Tapping the selected one clears it.
class _EnumChips<T> extends StatelessWidget {
  const _EnumChips({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm - 2,
      runSpacing: AppSpacing.sm - 2,
      children: [
        for (final value in values)
          ChoiceChip(
            label: Text(labelOf(value)),
            selected: selected == value,
            onSelected: (picked) => onSelected(picked ? value : null),
          ),
      ],
    );
  }
}
