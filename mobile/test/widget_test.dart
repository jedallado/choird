import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:choird/main.dart';

void main() {
  testWidgets('shows Songs, Set Lists, and Settings tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChoirdApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Set Lists'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
