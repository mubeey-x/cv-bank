import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cv_bank/core/error/exceptions.dart';
import 'package:cv_bank/core/error/supabase_error_mapper.dart';
import '../models/account_model.dart';

abstract interface class AuthRemoteDataSource {
  AccountModel? get currentAccount;
  Stream<AccountModel?> get accountChanges;

  Future<AccountModel> signIn(String email, String password);

  /// Null when Supabase created the user but no session, meaning a
  /// confirmation code was emailed.
  Future<AccountModel?> signUp(String name, String email, String password);

  Future<AccountModel> verifySignUp(String email, String token);
  Future<void> resendSignUpCode(String email);
  Future<void> requestPasswordReset(String email);
  Future<AccountModel> confirmPasswordReset(
    String email,
    String token,
    String newPassword,
  );
  Future<AccountModel> updateName(String name);
  Future<void> deleteAccount();
  Future<void> signOut();
}

class AuthSupabaseDataSource implements AuthRemoteDataSource {
  final SupabaseClient client;
  const AuthSupabaseDataSource(this.client);

  GoTrueClient get _auth => client.auth;

  @override
  AccountModel? get currentAccount {
    final user = _auth.currentUser;
    return user == null ? null : AccountModel.fromUser(user);
  }

  @override
  Stream<AccountModel?> get accountChanges =>
      _auth.onAuthStateChange.map((state) {
        final user = state.session?.user;
        return user == null ? null : AccountModel.fromUser(user);
      });

  @override
  Future<AccountModel> signIn(String email, String password) =>
      mapSupabaseErrors(() async {
        final res = await _auth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = res.user;
        if (user == null) {
          throw const ServerException('Sign in failed. Please try again.');
        }
        return AccountModel.fromUser(user);
      });

  @override
  Future<AccountModel?> signUp(String name, String email, String password) =>
      mapSupabaseErrors(() async {
        final res = await _auth.signUp(
          email: email,
          password: password,
          data: {'account_name': name},
        );
        // Session present means confirmation is switched off.
        return res.session == null || res.user == null
            ? null
            : AccountModel.fromUser(res.user!);
      });

  @override
  Future<AccountModel> verifySignUp(String email, String token) =>
      mapSupabaseErrors(() async {
        final res = await _auth.verifyOTP(
          email: email,
          token: token,
          type: OtpType.signup,
        );
        final user = res.user;
        if (user == null) {
          throw const ServerException('That code did not work.');
        }
        return AccountModel.fromUser(user);
      });

  @override
  Future<void> resendSignUpCode(String email) =>
      mapSupabaseErrors(() => _auth.resend(type: OtpType.signup, email: email));

  @override
  Future<void> requestPasswordReset(String email) =>
      mapSupabaseErrors(() => _auth.resetPasswordForEmail(email));

  @override
  Future<AccountModel> confirmPasswordReset(
    String email,
    String token,
    String newPassword,
  ) => mapSupabaseErrors(() async {
    // The recovery OTP signs the user in, which is what gives
    // updateUser permission to change the password.
    await _auth.verifyOTP(email: email, token: token, type: OtpType.recovery);
    final res = await _auth.updateUser(UserAttributes(password: newPassword));
    return AccountModel.fromUser(res.user!);
  });

  @override
  Future<AccountModel> updateName(String name) => mapSupabaseErrors(() async {
    final res = await _auth.updateUser(
      UserAttributes(data: {'account_name': name}),
    );
    return AccountModel.fromUser(res.user!);
  });

  @override
  Future<void> deleteAccount() => mapSupabaseErrors(() async {
    final userId = _auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const UnauthorizedException('No active account to delete.');
    }

    await _auth.admin.deleteUser(userId);
    await _auth.signOut();
  });

  @override
  Future<void> signOut() => mapSupabaseErrors(() => _auth.signOut());
}
