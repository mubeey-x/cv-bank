import 'dart:async';

import 'package:cv_bank/core/routes/cv_main_app_shell.dart';
import 'package:cv_bank/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:cv_bank/features/auth/presentation/screens/registration_screen.dart';
import 'package:cv_bank/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:cv_bank/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:cv_bank/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cv_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:cv_bank/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:cv_bank/core/routes/routes.dart';

// =====================================================================
// App state driving the redirect
//
// redirect() is synchronous, so anything it needs (the onboarding flag,
// the session) must already be in memory. This notifier loads it once
// and tells the router to re-evaluate whenever it changes.
// =====================================================================

const _kOnboardingSeen = 'onboarding_seen';

class AppState extends ChangeNotifier {
  AppState(this._client);

  final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSub;

  bool _isReady = false;
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;

  bool get isReady => _isReady;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool(_kOnboardingSeen) ?? false;
    _isLoggedIn = _client.auth.currentSession != null;

    _authSub = _client.auth.onAuthStateChange.listen((event) {
      final next = event.session != null;
      if (next != _isLoggedIn) {
        _isLoggedIn = next;
        notifyListeners();
      }
    });

    // Minimum splash time so it does not flash on a fast device.
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    _isReady = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

/// Plain Provider, not ChangeNotifierProvider, so the instance is stable
/// and watching it never rebuilds the router.
final appStateProvider = Provider<AppState>((ref) {
  final state = AppState(Supabase.instance.client)..init();
  ref.onDispose(state.dispose);
  return state;
});

// =====================================================================
// Navigator keys
// =====================================================================

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _dashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _peopleKey = GlobalKey<NavigatorState>(debugLabel: 'people');
final _categoriesKey = GlobalKey<NavigatorState>(debugLabel: 'categories');
final _profileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

// =====================================================================
// Router
// =====================================================================

final routerProvider = Provider<GoRouter>((ref) {
  final appState = ref.watch(appStateProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: appState,
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final loc = state.matchedLocation;

      final onSplash = loc == AppRoutes.splash;
      final onOnboarding = loc == AppRoutes.onboarding;
      final onAuth = loc.startsWith('/auth');

      // 1. Still loading prefs and session. Hold on splash.
      if (!appState.isReady) {
        return onSplash ? null : AppRoutes.splash;
      }

      // 2. First run. Onboarding before anything else.
      if (!appState.hasSeenOnboarding) {
        return onOnboarding ? null : AppRoutes.onboarding;
      }

      // 3. Signed out. Only the auth screens are reachable.
      //    Anything else is remembered and returned to after login.
      if (!appState.isLoggedIn) {
        if (onAuth) return null;
        if (onSplash || onOnboarding) return AppRoutes.login;
        return '${AppRoutes.login}?from=${Uri.encodeComponent(loc)}';
      }

      // 4. Signed in. Bounce off splash, onboarding and auth screens.
      if (onSplash || onOnboarding || onAuth) {
        return AppRoutes.dashboard;
      }

      return null;
    },

    routes: [
      // ---------------------------------------------------------------
      // Splash and onboarding
      // ---------------------------------------------------------------
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ---------------------------------------------------------------
      // Auth
      // ---------------------------------------------------------------
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            LoginScreen(returnTo: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) =>
            VerifyOtpScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
      // ---------------------------------------------------------------
      // Full screen routes, above the bottom nav
      // ---------------------------------------------------------------
      GoRoute(
        path: AppRoutes.peopleCreate,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            //AddPersonScreen(
            //categoryId: state.uri.queryParameters['categoryId'],
            // ),
            Scaffold(
              appBar: AppBar(title: Text('Add Person')),
              body: Center(child: Text('Add Person Screen')),
            ),
      ),
      GoRoute(
        path: AppRoutes.peopleDocument,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            // DocumentViewerScreen(
            //   personId: state.pathParameters['id']!,
            //   documentId: state.pathParameters['documentId']!,
            // ),
            Scaffold(
              appBar: AppBar(title: Text('Document Viewer')),
              body: Center(child: Text('Document Viewer Screen')),
            ),
      ),
      GoRoute(
        path: AppRoutes.peopleEdit,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            // PersonEditScreen(personId: state.pathParameters['id']!),
            Scaffold(
              appBar: AppBar(title: Text('Edit Person')),
              body: Center(child: Text('Edit Person Screen')),
            ),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: Text('Edit Profile')),
          body: Center(child: Text('Edit Profile Screen')),
        ),
      ),

      // ---------------------------------------------------------------
      // Shell: four tabs, each keeping its own stack
      // ---------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navShell) =>
            CvMainAppShell(navShell: navShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _peopleKey,
            routes: [
              GoRoute(
                path: AppRoutes.people,
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: Text('People')),
                  body: Center(child: Text('People Screen')),
                ),
                routes: [
                  // Child paths are relative. This resolves to /people/:id
                  // and is safe because /people/create is registered above
                  // on the root navigator.
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        // PersonDetailScreen(
                        //   personId: state.pathParameters['id']!,
                        // ),
                        Scaffold(
                          appBar: AppBar(title: Text('Person Detail')),
                          body: Center(child: Text('Person Detail Screen')),
                        ),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _categoriesKey,
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: Text('Categories')),
                  body: Center(child: Text('Categories Screen')),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        // CategoryDetailScreen(
                        //   categoryId: state.pathParameters['id']!,
                        // ),
                        Scaffold(
                          appBar: AppBar(title: Text('Category Detail')),
                          body: Center(child: Text('Category Detail Screen')),
                        ),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _profileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: Text('Profile')),
                  body: Center(child: Text('Profile Screen')),
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Page not found'),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
