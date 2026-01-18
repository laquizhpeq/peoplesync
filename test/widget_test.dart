import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/features/auth/auth_page.dart';
import 'package:peoplesync/features/auth/auth_service.dart';

// 1. Create a mock class that implements the AuthService.
// This allows us to control its behavior in the test.
class MockAuthService extends Mock implements AuthService {}

void main() {
  testWidgets('Login screen smoke test without Firebase', (WidgetTester tester) async {
    // 2. Create an instance of our mock service.
    final mockAuthService = MockAuthService();

    // 3. Pump the AuthPage widget, injecting the mock service.
    // We wrap it in a MaterialApp to provide the necessary context (like themes).
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPage(authService: mockAuthService),
      ),
    );

    // 4. Verify that the UI is rendered correctly.
    // These checks are the same as before, but now they run in a 
    // completely isolated environment, free from Firebase errors.
    expect(find.text(AppStrings.login), findsOneWidget);
    expect(find.text(AppStrings.email), findsOneWidget);
    expect(find.text(AppStrings.password), findsOneWidget);
    expect(find.text(AppStrings.signIn), findsOneWidget);
  });
}
