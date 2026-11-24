import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/database/app_database.dart';
import 'package:choird/database/database_provider.dart';
import 'package:choird/main.dart';
import 'package:choird/services/auth_api.dart';
import 'package:choird/services/auth_controller.dart';
import 'package:choird/services/auth_token_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

  testWidgets('asks for sign in before showing the catalog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChoirdApp(
        authController: AuthController(
          store: MemoryAuthTokenStore(),
          api: AuthApi(
            client: MockClient((request) async => http.Response('', 500)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
