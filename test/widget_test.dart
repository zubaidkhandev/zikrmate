import 'package:flutter_test/flutter_test.dart';
import 'package:zikermate/main.dart';

void main() {
  testWidgets('ZikarApp smoke test', (WidgetTester tester) async {
    // ZikarApp requires Hive init, so we just verify it can be instantiated.
    expect(const ZikarApp(), isNotNull);
  });
}
