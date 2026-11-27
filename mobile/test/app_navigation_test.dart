import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/database/app_database.dart';
import 'package:choird/database/database_provider.dart';
import 'package:choird/main.dart';
import 'package:choird/models/auth_session.dart';
import 'package:choird/screens/main_screen.dart';
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

  testWidgets('opens on Home and reaches Posts and Settings from the menu', (
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

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Songs'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Set Lists'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Settings'),
      ),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Open menu').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(
      tester
          .widget<NavigationDrawer>(find.byType(NavigationDrawer))
          .selectedIndex,
      AppMenuSection.home.index,
    );

    await tester.tap(
      find.widgetWithText(NavigationDrawerDestination, 'Posts').hitTestable(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Open menu').hitTestable());
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<NavigationDrawer>(find.byType(NavigationDrawer))
          .selectedIndex,
      AppMenuSection.posts.index,
    );
    await tester.tap(
      find
          .widgetWithText(NavigationDrawerDestination, 'Settings')
          .hitTestable(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign out'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Open menu').hitTestable());
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<NavigationDrawer>(find.byType(NavigationDrawer))
          .selectedIndex,
      AppMenuSection.settings.index,
    );
    await tester.tap(
      find.widgetWithText(NavigationDrawerDestination, 'Home').hitTestable(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Songs'),
      ),
      findsOneWidget,
    );
  });
}
