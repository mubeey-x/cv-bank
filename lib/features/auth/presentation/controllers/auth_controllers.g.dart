// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loginControllerHash() => r'707936f677e4a4fe16b11675c4ac975526942e44';

/// The pattern in each: state carries loading and failure for the UI,
/// the method returns the outcome so the screen can navigate.
///
/// Copied from [LoginController].
@ProviderFor(LoginController)
final loginControllerProvider =
    AutoDisposeAsyncNotifierProvider<LoginController, void>.internal(
      LoginController.new,
      name: r'loginControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loginControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LoginController = AutoDisposeAsyncNotifier<void>;
String _$registerControllerHash() =>
    r'e9af499ff4ccc4e552f332c720491373a693f39f';

/// See also [RegisterController].
@ProviderFor(RegisterController)
final registerControllerProvider =
    AutoDisposeAsyncNotifierProvider<RegisterController, void>.internal(
      RegisterController.new,
      name: r'registerControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$registerControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RegisterController = AutoDisposeAsyncNotifier<void>;
String _$verifyOtpControllerHash() =>
    r'e849e6f1a71081b6c105c5e0806e1d74597e6663';

/// See also [VerifyOtpController].
@ProviderFor(VerifyOtpController)
final verifyOtpControllerProvider =
    AutoDisposeAsyncNotifierProvider<VerifyOtpController, void>.internal(
      VerifyOtpController.new,
      name: r'verifyOtpControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$verifyOtpControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VerifyOtpController = AutoDisposeAsyncNotifier<void>;
String _$resendCooldownHash() => r'629c4631f4f6af5149515ca162e2a4a9d35aac8e';

/// Counts down the resend cooldown. Supabase rate limits resends, so
/// the button has to be disabled for a while or users hit the limit
/// and get a confusing error.
///
/// Copied from [ResendCooldown].
@ProviderFor(ResendCooldown)
final resendCooldownProvider =
    AutoDisposeNotifierProvider<ResendCooldown, int>.internal(
      ResendCooldown.new,
      name: r'resendCooldownProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$resendCooldownHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ResendCooldown = AutoDisposeNotifier<int>;
String _$resetPasswordControllerHash() =>
    r'714d647f0f56dfc2238a30b95039588a6bf62f5e';

/// See also [ResetPasswordController].
@ProviderFor(ResetPasswordController)
final resetPasswordControllerProvider =
    AutoDisposeNotifierProvider<
      ResetPasswordController,
      ResetPasswordState
    >.internal(
      ResetPasswordController.new,
      name: r'resetPasswordControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$resetPasswordControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ResetPasswordController = AutoDisposeNotifier<ResetPasswordState>;
String _$signOutControllerHash() => r'9ea15362ac1e0cf81e1c0a6a1bb3640d340643f5';

/// See also [SignOutController].
@ProviderFor(SignOutController)
final signOutControllerProvider =
    AutoDisposeAsyncNotifierProvider<SignOutController, void>.internal(
      SignOutController.new,
      name: r'signOutControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signOutControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignOutController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
