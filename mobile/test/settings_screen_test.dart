import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/config/app_version.dart';
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

  testWidgets('shows app version on settings tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ChoirdApp());
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Version'), findsOneWidget);
    expect(
      find.text('${AppVersion.version} (${AppVersion.buildNumber})'),
      findsOneWidget,
    );
  });
}
