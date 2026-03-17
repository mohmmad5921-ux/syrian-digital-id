import 'package:flutter_test/flutter_test.dart';
import 'package:syrian_digital_id/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SyrianDigitalIdApp());
    expect(find.text('الهوية الرقمية السورية'), findsOneWidget);
  });
}
