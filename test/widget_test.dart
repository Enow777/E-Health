import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ehealth/main.dart';

void main() {
  testWidgets('splash opens onboarding and skip enters app', (tester) async {
    await tester.pumpWidget(const NkapHealthApp());

    expect(find.text('Healthcare,\nmade personal.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Find trusted care\nwithout the wait.'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Flavien'), findsOneWidget);
  });

  testWidgets('patient dashboard renders core services', (tester) async {
    await tester.pumpWidget(const NkapHealthApp(showIntro: false));

    expect(find.text('Good morning, Flavien'), findsOneWidget);
    expect(find.text('NEXT APPOINTMENT'), findsOneWidget);
    expect(find.text('Your health services'), findsOneWidget);
  });

  testWidgets('discover screen filters doctors by specialty', (tester) async {
    await tester.pumpWidget(const NkapHealthApp(showIntro: false));

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Paediatrics'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Leslie Fomba'), findsOneWidget);
    expect(find.text('Dr. Carine Njoya'), findsNothing);
  });

  testWidgets('doctor profile opens booking flow', (tester) async {
    await tester.pumpWidget(const NkapHealthApp(showIntro: false));

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dr. Carine Njoya'));
    await tester.pumpAndSettle();

    expect(find.text('Doctor profile'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Book an appointment'), 220);
    await tester.tap(find.text('Book an appointment'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a date'), findsOneWidget);
    expect(find.text('Consultation type'), findsOneWidget);
  });

  testWidgets('home service cards open real pages', (tester) async {
    await tester.pumpWidget(const NkapHealthApp(showIntro: false));

    final bookVisit = find.byKey(const ValueKey('home-service-book-a-visit'));
    await tester.drag(find.byType(ListView).first, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(bookVisit);
    await tester.pumpAndSettle();

    expect(find.text('Choose the care you need'), findsOneWidget);
    expect(find.text('Available doctors'), findsOneWidget);
  });
}
