import 'package:flutter_test/flutter_test.dart';

import 'package:stutimallika/main.dart';

void main() {
  testWidgets('App launches and shows the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StutiMallikaApp());
    await tester.pump();

    expect(find.text('स्तुतिमल्लिका'), findsOneWidget);

    // Flush the splash screen's delayed navigation and its transition
    // animation so no timers are left pending when the test ends.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
