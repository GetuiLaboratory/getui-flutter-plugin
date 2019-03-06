import 'dart:async';

import 'package:flutter/services.dart';

class Getuiflut {
  static const MethodChannel _channel =
      const MethodChannel('getuiflut');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
