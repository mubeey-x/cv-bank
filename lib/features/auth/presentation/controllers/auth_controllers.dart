import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import 'package:cv_bank/features/auth/data/providers/auth_providers.dart';
import 'package:cv_bank/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:cv_bank/features/auth/domain/usecases/reset_password.dart';
import 'package:cv_bank/features/auth/domain/usecases/sign_in.dart';
import 'package:cv_bank/features/auth/domain/usecases/sign_up.dart';
import 'package:cv_bank/features/auth/domain/usecases/verify_sign_up.dart';

part 'auth_controllers.g.dart';

/// The pattern in each: state carries loading and failure for the UI,
/// the method returns the outcome so the screen can navigate.

// =====================================================================
// Login
// =====================================================================

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<bool> submit({required String email, required String password}) async {
    state = const AsyncLoading();

    final result = await ref
        .read(signInProvider)
        .call(SignInParams(email: email, password: password));

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  void clearError() => state = const AsyncData(null);
}

// =====================================================================
// Register
// =====================================================================

@riverpod
class RegisterController extends _$RegisterController {
  @override
  FutureOr<void> build() {}

  /// Null means it failed. Otherwise the outcome tells the screen
  /// whether to go to OTP verification or straight to the dashboard.
  Future<SignUpOutcome?> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final result = await ref
        .read(signUpProvider)
        .call(SignUpParams(name: name, email: email, password: password));

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (outcome) {
        state = const AsyncData(null);
        return outcome;
      },
    );
  }

  void clearError() => state = const AsyncData(null);
}

// =====================================================================
// Verify OTP
// =====================================================================

@riverpod
class VerifyOtpController extends _$VerifyOtpController {
  @override
  FutureOr<void> build() {}

  Future<bool> verify({required String email, required String token}) async {
    state = const AsyncLoading();

    final result = await ref
        .read(verifySignUpProvider)
        .call(VerifySignUpParams(email: email, token: token));

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> resend(String email) async {
    final result = await ref.read(resendSignUpCodeProvider).call(email);
    return result.fold((failure) {
      state = AsyncError(failure, StackTrace.current);
      return false;
    }, (_) => true);
  }

  void clearError() => state = const AsyncData(null);
}

/// Counts down the resend cooldown. Supabase rate limits resends, so
/// the button has to be disabled for a while or users hit the limit
/// and get a confusing error.
@riverpod
class ResendCooldown extends _$ResendCooldown {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    return 0;
  }

  void start([int seconds = 60]) {
    _timer?.cancel();
    state = seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state <= 1) {
        t.cancel();
        state = 0;
      } else {
        state = state - 1;
      }
    });
  }
}

// =====================================================================
// Forgot / reset password
// =====================================================================

enum ResetStage { requestCode, enterNewPassword }

class ResetPasswordState {
  final ResetStage stage;
  final String email;

  const ResetPasswordState({
    this.stage = ResetStage.requestCode,
    this.email = '',
  });

  ResetPasswordState copyWith({ResetStage? stage, String? email}) {
    return ResetPasswordState(
      stage: stage ?? this.stage,
      email: email ?? this.email,
    );
  }
}

@riverpod
class ResetPasswordController extends _$ResetPasswordController {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  Failure? _failure;
  bool _loading = false;

  Failure? get failure => _failure;
  bool get isLoading => _loading;

  Future<bool> requestCode(String email) async {
    _set(loading: true, failure: null);

    final result = await ref.read(requestPasswordResetProvider).call(email);

    return result.fold(
      (f) {
        _set(loading: false, failure: f);
        return false;
      },
      (_) {
        _loading = false;
        _failure = null;
        state = state.copyWith(
          stage: ResetStage.enterNewPassword,
          email: email.trim().toLowerCase(),
        );
        return true;
      },
    );
  }

  Future<bool> confirm({
    required String token,
    required String newPassword,
  }) async {
    _set(loading: true, failure: null);

    final result = await ref
        .read(confirmPasswordResetProvider)
        .call(
          ConfirmPasswordResetParams(
            email: state.email,
            token: token,
            newPassword: newPassword,
          ),
        );

    return result.fold(
      (f) {
        _set(loading: false, failure: f);
        return false;
      },
      (_) {
        _set(loading: false, failure: null);
        return true;
      },
    );
  }

  void backToEmail() {
    _failure = null;
    state = state.copyWith(stage: ResetStage.requestCode);
  }

  void _set({required bool loading, required Failure? failure}) {
    _loading = loading;
    _failure = failure;
    // Rebuild listeners without changing the stage.
    state = state.copyWith();
  }
}

// =====================================================================
// Sign out
// =====================================================================

@riverpod
class SignOutController extends _$SignOutController {
  @override
  FutureOr<void> build() {}

  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await ref.read(signOutProvider).call(const NoParams());
    state = result.fold(
      (f) => AsyncError(f, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
