import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp smoke', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Uplift.ai'))),
      ),
    );
    expect(find.text('Uplift.ai'), findsOneWidget);
  });
}
