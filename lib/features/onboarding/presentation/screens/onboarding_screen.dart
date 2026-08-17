import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cv_bank/core/constants/app_assets.dart';
import 'package:cv_bank/core/routes/router.dart';
import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';

class _Page {
  final String image;
  final String title;
  final String body;

  const _Page({required this.image, required this.title, required this.body});
}

const _pages = [
  _Page(
    image: AppAssets.ONBOARDING_ONE,
    title: 'Every CV in one place',
    body:
        'Photograph a CV or pick a file. We read the name and number '
        'off it, so all you do is confirm.',
  ),
  _Page(
    image: AppAssets.ONBOARDING_TWO,
    title: 'Find anyone in seconds',
    body:
        'Search by name or phone number, or browse by the categories '
        'you set up yourself.',
  ),
  _Page(
    image: AppAssets.ONBOARDING_THREE,
    title: 'Know who you have placed',
    body:
        'Mark someone employed and your numbers update. See at a '
        'glance who is still waiting.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appStateProvider).completeOnboarding();
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              child: Image.asset(page.image, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.inkSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: active ? 20 : 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xl),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: FilledButton(
                onPressed: _next,
                child: Text(_isLast ? 'Get started' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
