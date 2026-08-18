import 'package:cv_bank/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile screen shows key actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ProfileScreen())),
    );

    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Reset password'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });
}
