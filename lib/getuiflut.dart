import 'dart:async';
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

  static Future<String> get getClientId async {
    String cid = await _channel.invokeMethod('getClientId');
    return cid;
  }

  void resumePush() {
    _channel.invokeMethod('resume');
  }

  void stopPush() {
    _channel.invokeMethod('stopPush');
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
        return _onReceiveClientId(call.arguments);
        break;
      case "onReceiveMessageData":
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
