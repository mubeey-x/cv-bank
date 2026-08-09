import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cv_bank/core/theme/app_palette.dart';

/// Labelled field used across auth and intake. The label sits above
/// the box rather than floating inside it, so it stays readable once
/// the field has content.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.textCapitalization = TextCapitalization.none,
    this.hint,
    this.helper,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscure = false,
    this.enabled = true,
    this.autofocus = false,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
    this.onSubmitted,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscure;
  final bool enabled;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.inkSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _hidden,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          textAlign: widget.textAlign,
          style: widget.style ?? theme.textTheme.bodyLarge,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.inkMuted,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          Text(widget.helper!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}
