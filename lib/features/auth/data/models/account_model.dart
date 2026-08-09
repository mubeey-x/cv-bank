import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.email,
    required super.name,
    required super.isEmailConfirmed,
    required super.createdAt,
  });

  factory AccountModel.fromUser(User user) {
    return AccountModel(
      id: user.id,
      email: user.email ?? '',
      name: (user.userMetadata?['account_name'] as String?)?.trim() ?? '',
      isEmailConfirmed: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt).toLocal(),
    );
  }
}
