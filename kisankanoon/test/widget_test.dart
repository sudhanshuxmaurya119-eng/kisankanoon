import 'package:flutter_test/flutter_test.dart';
import 'package:kisankanoon/main.dart';

void main() {
  testWidgets('Agri-Shield app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriShieldApp());
    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.byType(AgriShieldApp), findsOneWidget);
  });
}
