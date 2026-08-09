import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/common/widgets/app_text_field.dart';
import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:cv_bank/features/auth/presentation/controllers/auth_controllers.dart';
import 'package:cv_bank/features/auth/presentation/widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool get _canSubmit =>
      _name.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _password.text.length >= 8;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final outcome = await ref
        .read(registerControllerProvider.notifier)
        .submit(name: _name.text, email: _email.text, password: _password.text);

    if (outcome == null || !mounted) return;

    switch (outcome) {
      case SignUpOutcome.verificationRequired:
        context.push(
          '${AppRoutes.verifyOtp}'
          '?email=${Uri.encodeComponent(_email.text.trim().toLowerCase())}',
        );
      case SignUpOutcome.signedIn:
        context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final failure = state.hasError ? state.error as Failure? : null;
    final isLoading = state.isLoading;
    final theme = Theme.of(context);

    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Your list stays private to you.',
      footer: AuthFooterLink(
        prompt: 'Have an account?',
        action: 'Sign in',
        onTap: () => context.pop(),
      ),
      children: [
        AppTextField(
          label: 'Name',
          controller: _name,
          hint: 'Your full name',
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          autofillHints: const [AutofillHints.name],
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: 'Email',
          controller: _email,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: 'Password',
          controller: _password,
          obscure: true,
          textInputAction: TextInputAction.done,
          helper: 'At least 8 characters',
          autofillHints: const [AutofillHints.newPassword],
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _canSubmit ? _submit() : null,
        ),
        const SizedBox(height: AppSpacing.xl),

        AuthErrorBanner(
          failure: failure,
          action: failure is AccountExistsFailure
              ? TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.destructiveInk,
                  ),
                  child: const Text('Sign in instead'),
                )
              : null,
        ),

        AuthSubmitButton(
          label: 'Create account',
          isLoading: isLoading,
          onPressed: _canSubmit ? _submit : null,
        ),
        const SizedBox(height: AppSpacing.md + 2),

        Text(
          'By continuing you agree to the Terms and Privacy Policy.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
