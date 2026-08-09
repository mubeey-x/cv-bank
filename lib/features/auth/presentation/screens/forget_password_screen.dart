import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/common/widgets/app_text_field.dart';
import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/auth/presentation/controllers/auth_controllers.dart';
import 'package:cv_bank/features/auth/presentation/widgets/auth_widgets.dart';

/// Both steps live on one screen. A separate route for the code would
/// lose the user's place when they leave the app to read the email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(resetPasswordControllerProvider.notifier)
        .requestCode(_email.text);
    if (mounted) setState(() {});
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(resetPasswordControllerProvider.notifier)
        .confirm(token: _code.text, newPassword: _password.text);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated.')));
      context.go(AppRoutes.dashboard);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordControllerProvider);
    final controller = ref.read(resetPasswordControllerProvider.notifier);
    final theme = Theme.of(context);

    final isCodeStage = state.stage == ResetStage.enterNewPassword;

    return AuthScaffold(
      title: isCodeStage ? 'Set a new password' : 'Reset your password',
      subtitle: isCodeStage
          ? 'Enter the code sent to ${state.email} and choose a new password.'
          : 'Enter your email and we will send you a code.',
      children: isCodeStage
          ? [
              AppTextField(
                label: 'Code',
                controller: _code,
                hint: '000000',
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 10),
                enabled: !controller.isLoading,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'New password',
                controller: _password,
                obscure: true,
                textInputAction: TextInputAction.done,
                helper: 'At least 8 characters',
                autofillHints: const [AutofillHints.newPassword],
                enabled: !controller.isLoading,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xl),

              AuthErrorBanner(failure: controller.failure),

              AuthSubmitButton(
                label: 'Update password',
                isLoading: controller.isLoading,
                onPressed: _code.text.length == 6 && _password.text.length >= 8
                    ? _confirm
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Center(
                child: TextButton(
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          controller.backToEmail();
                          setState(() {});
                        },
                  child: const Text('Use a different email'),
                ),
              ),
            ]
          : [
              AppTextField(
                label: 'Email',
                controller: _email,
                hint: 'you@example.com',
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                enabled: !controller.isLoading,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _requestCode(),
              ),
              const SizedBox(height: AppSpacing.xl),

              AuthErrorBanner(failure: controller.failure),

              AuthSubmitButton(
                label: 'Send code',
                isLoading: controller.isLoading,
                onPressed: _email.text.trim().isNotEmpty ? _requestCode : null,
              ),
            ],
    );
  }
}
