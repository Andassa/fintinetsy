import 'package:flutter_test/flutter_test.dart';
import 'package:fintinetsy/main.dart';

void main() {
  testWidgets('App boots to splash', (tester) async {
    await tester.pumpWidget(const FintinetsyApp());
    expect(find.text('Uplift.ai'), findsOneWidget);
  });
}
