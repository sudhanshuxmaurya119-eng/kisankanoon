import 'package:flutter_test/flutter_test.dart';
import 'package:kisankanoon/main.dart';

void main() {
  testWidgets('KisanKanoon app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KisanKanoonApp());
    expect(find.byType(KisanKanoonApp), findsOneWidget);
  });
}
