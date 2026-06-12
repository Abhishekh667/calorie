import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_flow/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CalorieFlowApp());
    expect(find.byType(CalorieFlowApp), findsOneWidget);
  });
}
