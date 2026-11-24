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
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(
      find.text('${AppVersion.version} (${AppVersion.buildNumber})'),
      findsOneWidget,
    );
  });
}
