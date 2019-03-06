import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getuiflut/getuiflut.dart';

void main() {
  const MethodChannel channel = MethodChannel('getuiflut');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Getuiflut.platformVersion, '42');
  });
}
