import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/map_screen.dart';

void main() {
  testWidgets('Map placeholder shows info', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));

    expect(find.textContaining('Google Maps placeholder'), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
  });
}