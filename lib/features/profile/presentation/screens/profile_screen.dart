import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/features/auth/data/providers/auth_providers.dart';
import 'package:cv_bank/features/auth/presentation/controllers/auth_controllers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(authStateProvider).value;
    final name = account?.name.trim().isNotEmpty == true
        ? account!.name
        : 'Your profile';
    final email = account?.email ?? 'No email';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryTint,
                    foregroundColor: AppColors.primary,
                    child: Text(
                      account?.initials ?? 'U',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.inkSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _ProfileActionTile(
              icon: Icons.edit_outlined,
              title: 'Edit profile',
              onTap: () => context.push(AppRoutes.profileEdit),
            ),
            _ProfileActionTile(
              icon: Icons.lock_reset_outlined,
              title: 'Change password',
              onTap: () => _openPasswordReset(context),
            ),
            _ProfileActionTile(
              icon: Icons.password_outlined,
              title: 'Reset password',
              onTap: () => context.push(AppRoutes.forgotPassword),
            ),
            _ProfileActionTile(
              icon: Icons.logout,
              title: 'Log out',
              titleStyle: AppColors.destructive,
              onTap: () => _confirmSignOut(context, ref),
            ),
            _ProfileActionTile(
              icon: Icons.delete_outline,
              title: 'Delete account',
              titleStyle: AppColors.destructive,
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPasswordReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: const Text(
          'Use the password reset flow to set a new password from a secure email link.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.push(AppRoutes.forgotPassword);
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(signOutControllerProvider.notifier).signOut();

    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This permanently deletes your account from Supabase. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final controller = ref.read(deleteAccountControllerProvider.notifier);
    await controller.deleteAccount();

    final state = ref.read(deleteAccountControllerProvider);
    if (!context.mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete your account. Please try again.'),
        ),
      );
      return;
    }

    context.go(AppRoutes.login);
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleStyle,
  });

  final IconData icon;
  final String title;
  final Color? titleStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = titleStyle ?? AppColors.ink;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: style),
            title: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: style),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.inkSecondary,
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
