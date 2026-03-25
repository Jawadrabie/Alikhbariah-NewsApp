import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newsappjs/dashboard/auth/login_screen.dart';

void main() {
  testWidgets('Dashboard login screen renders basic fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardLoginScreen()));

    expect(find.byType(FlutterLogo), findsOneWidget);
    expect(find.text('Dashboard Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
