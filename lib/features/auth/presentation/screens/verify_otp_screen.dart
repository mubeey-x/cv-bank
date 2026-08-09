import 'package:cv_bank/features/auth/presentation/controllers/auth_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/common/widgets/app_text_field.dart';
import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/auth/presentation/widgets/auth_widgets.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(verifyOtpControllerProvider.notifier)
        .verify(email: widget.email, token: _code.text);

    if (ok && mounted) context.go(AppRoutes.dashboard);
  }

  Future<void> _resend() async {
    final ok = await ref
        .read(verifyOtpControllerProvider.notifier)
        .resend(widget.email);

    if (!mounted) return;

    if (ok) {
      ref.read(resendCooldownProvider.notifier).start();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('New code sent.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyOtpControllerProvider);
    final failure = state.hasError ? state.error as Failure? : null;
    final isLoading = state.isLoading;
    final cooldown = ref.watch(resendCooldownProvider);
    final theme = Theme.of(context);

    return AuthScaffold(
      title: 'Check your email',
      subtitle: 'We sent a 6-digit code to ${widget.email}.',
      children: [
        AppTextField(
          label: 'Confirmation code',
          controller: _code,
          hint: '000000',
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 6,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 12),
          enabled: !isLoading,
          onChanged: (value) {
            setState(() {});
            // Submit on the sixth digit. Nobody wants to reach for a
            // button after typing a code.
            if (value.length == 6 && !isLoading) _verify();
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        AuthErrorBanner(failure: failure),

        AuthSubmitButton(
          label: 'Verify',
          isLoading: isLoading,
          onPressed: _code.text.length == 6 ? _verify : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        Center(
          child: cooldown > 0
              ? Text(
                  'Resend code in ${cooldown}s',
                  style: theme.textTheme.bodyMedium,
                )
              : TextButton(
                  onPressed: isLoading ? null : _resend,
                  child: const Text('Resend code'),
                ),
        ),
      ],
    );
  }
}
