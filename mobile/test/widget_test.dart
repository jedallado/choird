import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/database/app_database.dart';
import 'package:choird/database/database_provider.dart';
import 'package:choird/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DatabaseProvider.instance = AppDatabase.memory();
  });

  tearDown(() async {
    await DatabaseProvider.reset();
  });

  testWidgets('shows Songs, Set Lists, and Settings tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChoirdApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Set Lists'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
