import 'package:flutter/material.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/theme/app_palette.dart';

/// Shell for every auth screen: optional wordmark or back arrow,
/// left-aligned heading, then the form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showWordmark = false,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showWordmark;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Keeps the footer pinned low on tall screens but lets
              // it scroll once the keyboard is up.
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showWordmark)
                      const _Wordmark()
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back, size: 22),
                          color: AppColors.ink,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
                    Text(title, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.sm - 2),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xl + AppSpacing.xs),
                    ...children,
                    if (footer != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      const Spacer(),
                      footer!,
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: const Icon(
            Icons.groups_outlined,
            size: 17,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 1),
        Text(
          'CV Bank',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Shows a Failure above the submit button. [action] is for the two
/// cases where the user needs a way out: unconfirmed email, and an
/// email that is already registered.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.failure, this.action});

  final Failure? failure;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final f = failure;
    if (f == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.destructiveTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                size: 18,
                color: AppColors.destructiveInk,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  f.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.destructiveInk,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(alignment: Alignment.centerLeft, child: action!),
          ],
        ],
      ),
    );
  }
}

/// Primary submit button with a loading state, so double taps cannot
/// fire two sign-up requests.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}

/// "New here? Create an account" style line.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
