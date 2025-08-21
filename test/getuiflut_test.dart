import 'package:flutter_test/flutter_test.dart';
import 'package:getuiflut/getuiflut.dart';

void main() {
  // const MethodChannel channel = MethodChannel('getuiflut');

  setUp(() {
  });

  tearDown(() {
  });

  test('getPlatformVersion', () async {
    expect(await Getuiflut.platformVersion, '42');
  });
}
