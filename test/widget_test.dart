import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app/main.dart';

void main() {
  testWidgets('SmartSklad App launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartSkladApp());
    expect(find.byType(SmartSkladApp), findsOneWidget);
  });
}
