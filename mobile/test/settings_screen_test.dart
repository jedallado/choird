import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/config/app_version.dart';
import 'package:choird/database/app_database.dart';
import 'package:choird/database/database_provider.dart';
import 'package:choird/main.dart';
import 'package:choird/models/auth_session.dart';
import 'package:choird/services/auth_api.dart';
import 'package:choird/services/auth_controller.dart';
import 'package:choird/services/auth_token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DatabaseProvider.instance = AppDatabase.memory();
  });

  tearDown(() async {
    AuthController.instance = null;
    await DatabaseProvider.reset();
  });

  testWidgets('shows the signed-in user and app version', (
    WidgetTester tester,
  ) async {
    final store = MemoryAuthTokenStore();
    await store.write(
      AuthSession(
        token: 'token-1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        user: const AuthUser(
          id: 1,
          name: 'Ada',
          email: 'ada@example.com',
          role: 'member',
        ),
      ),
    );

    await tester.pumpWidget(
      ChoirdApp(
        authController: AuthController(
          store: store,
          api: AuthApi(
            client: MockClient((request) async => http.Response('', 204)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.textContaining('ada@example.com'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(
      find.text('${AppVersion.version} (${AppVersion.buildNumber})'),
      findsOneWidget,
    );
  });

  testWidgets('change password checks the same rules as the API', (
    WidgetTester tester,
  ) async {
    Map<String, dynamic>? sentBody;
    var statusCode = 422;
    final store = MemoryAuthTokenStore();
    await store.write(
      AuthSession(
        token: 'token-1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        user: const AuthUser(
          id: 1,
          name: 'Ada',
          email: 'ada@example.com',
          role: 'member',
        ),
      ),
    );

    await tester.pumpWidget(
      ChoirdApp(
        authController: AuthController(
          store: store,
          api: AuthApi(
            client: MockClient((request) async {
              sentBody = jsonDecode(request.body) as Map<String, dynamic>;
              if (statusCode == 200) {
                return http.Response(
                  jsonEncode({
                    'data': {
                      'id': 1,
                      'name': 'Ada',
                      'email': 'ada@example.com',
                      'role': 'member',
                    },
                  }),
                  200,
                );
              }

              return http.Response(
                jsonEncode({
                  'message': 'Current password is incorrect.',
                  'errors': {
                    'current_password': ['Current password is incorrect.'],
                  },
                }),
                statusCode,
              );
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pumpAndSettle();

    expect(
      find.text('Current password is required to change your password.'),
      findsOneWidget,
    );
    expect(find.text('Password is required.'), findsOneWidget);
    expect(sentBody, isNull);

    final dialogFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(dialogFields.at(0), 'secret');
    await tester.enterText(dialogFields.at(1), 'short');
    await tester.enterText(dialogFields.at(2), 'other');
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pumpAndSettle();

    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
    expect(find.text('Password confirmation does not match.'), findsOneWidget);
    expect(sentBody, isNull);

    await tester.enterText(dialogFields.at(1), 'new-password');
    await tester.enterText(dialogFields.at(2), 'new-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pumpAndSettle();

    expect(sentBody, {
      'currentPassword': 'secret',
      'password': 'new-password',
      'passwordConfirmation': 'new-password',
    });
    expect(find.text('Current password is incorrect.'), findsOneWidget);

    statusCode = 200;
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Password changed.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(store.session?.token, 'token-1');
  });
}
