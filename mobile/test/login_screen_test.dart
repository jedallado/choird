import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/database/app_database.dart';
import 'package:choird/database/database_provider.dart';
import 'package:choird/main.dart';
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

  testWidgets('signs in and can sign out without clearing the prompt copy', (
    WidgetTester tester,
  ) async {
    final store = MemoryAuthTokenStore();
    final auth = AuthController(
      store: store,
      api: AuthApi(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login')) {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            if (body['password'] != 'password123') {
              return http.Response(
                jsonEncode({
                  'message': 'These credentials do not match our records.',
                }),
                401,
              );
            }

            return http.Response(
              jsonEncode({
                'token': 'token-1',
                'tokenType': 'Bearer',
                'expiresAt': DateTime.now()
                    .toUtc()
                    .add(const Duration(days: 7))
                    .toIso8601String(),
                'user': {
                  'id': 1,
                  'name': 'Ada',
                  'email': 'ada@example.com',
                  'role': 'member',
                  'createdAt': '2026-01-01T00:00:00.000000Z',
                  'updatedAt': '2026-01-01T00:00:00.000000Z',
                },
              }),
              200,
            );
          }

          return http.Response('', 204);
        }),
      ),
    );

    await tester.pumpWidget(ChoirdApp(authController: auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'ada@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(
      find.text('These credentials do not match our records.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(store.session?.token, 'token-1');

    await tester.tap(find.byTooltip('Open menu').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .widgetWithText(NavigationDrawerDestination, 'Settings')
          .hitTestable(),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to see songs and set lists.'), findsOneWidget);
    expect(store.session, isNull);
  });
}
