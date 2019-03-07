import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';


typedef Future<dynamic> EventHandler(String res);
typedef Future<dynamic> EventHandlerMap(Map<String, dynamic> event);

class Getuiflut {

  static const MethodChannel _channel = const MethodChannel('getuiflut');

  EventHandler _onReceiveClientId;
  EventHandlerMap _onReceiveMessageData;
  EventHandlerMap _onNotificationMessageArrived;
  EventHandlerMap _onNotificationMessageClicked;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> get initGetuiSdk async {
    await _channel.invokeMethod('initGetuiPush');
  }

  void addEventHandler({
    EventHandler onReceiveClientId,
    EventHandlerMap onReceiveMessageData,
    EventHandlerMap onNotificationMessageArrived,
    EventHandlerMap onNotificationMessageClicked,
  }){
    _onReceiveClientId = onReceiveClientId;
    _onReceiveMessageData = onReceiveMessageData;
    _onNotificationMessageArrived = onNotificationMessageArrived;
    _onNotificationMessageClicked = onNotificationMessageClicked;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<Null> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "onReceiveClientId":
        print("whb onReceiveClientId:" + call.arguments);
        return _onReceiveClientId(call.arguments);
        break;
      case "onReceiveMessageData":
        print("whb onReceiveMessageData");
        return _onReceiveMessageData(call.arguments.cast<String, dynamic>());
      case "onNotificationMessageArrived":
        return _onNotificationMessageArrived(call.arguments.cast<String, dynamic>());
      case "onNotificationMessageClicked":
        return _onNotificationMessageClicked(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecongnized Event");
    }
  }

}
