import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:choird/config/app_version.dart';
import 'package:choird/main.dart';

void main() {
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
