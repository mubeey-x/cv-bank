import 'package:cv_bank/core/provider/supabase_provider.dart';
import 'package:cv_bank/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cv_bank/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cv_bank/features/auth/domain/entities/account.dart';
import 'package:cv_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:cv_bank/features/auth/domain/usecases/reset_password.dart';
import 'package:cv_bank/features/auth/domain/usecases/sign_in.dart';
import 'package:cv_bank/features/auth/domain/usecases/sign_out.dart';
import 'package:cv_bank/features/auth/domain/usecases/sign_up.dart';
import 'package:cv_bank/features/auth/domain/usecases/verify_sign_up.dart';

part 'auth_providers.g.dart';

// ============================================================================
// DATA LAYER
// ============================================================================

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthSupabaseDataSource(ref.watch(supabaseProvider));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(remote: ref.watch(authRemoteDataSourceProvider));
}

// ============================================================================
// DOMAIN LAYER (Use Cases)
// ============================================================================

@riverpod
SignIn signIn(Ref ref) => SignIn(ref.watch(authRepositoryProvider));

@riverpod
SignUp signUp(Ref ref) => SignUp(ref.watch(authRepositoryProvider));

@riverpod
VerifySignUp verifySignUp(Ref ref) =>
    VerifySignUp(ref.watch(authRepositoryProvider));

@riverpod
ResendSignUpCode resendSignUpCode(Ref ref) =>
    ResendSignUpCode(ref.watch(authRepositoryProvider));

@riverpod
RequestPasswordReset requestPasswordReset(Ref ref) =>
    RequestPasswordReset(ref.watch(authRepositoryProvider));

@riverpod
ConfirmPasswordReset confirmPasswordReset(Ref ref) =>
    ConfirmPasswordReset(ref.watch(authRepositoryProvider));

@riverpod
UpdateAccountName updateAccountName(Ref ref) =>
    UpdateAccountName(ref.watch(authRepositoryProvider));

@riverpod
SignOut signOut(Ref ref) => SignOut(ref.watch(authRepositoryProvider));

@riverpod
GetCurrentAccount getCurrentAccount(Ref ref) =>
    GetCurrentAccount(ref.watch(authRepositoryProvider));

// ============================================================================
// STATE
// ============================================================================

@Riverpod(keepAlive: true)
Stream<Account?> authState(Ref ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.currentAccount;
  yield* repo.accountChanges;
}
