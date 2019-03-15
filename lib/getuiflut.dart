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


  // deviceToken
  EventHandler _onRegisterDeviceToken;
  // voipToken
  EventHandler _onRegisterVoipToken;
  //  iOS收到的透传内容
  EventHandler _onReceivePayload;
  // ios 收到APNS消息
  EventHandlerMap _onReceiveNotificationResponse;
  // ios 收到AppLink消息
  EventHandler _onAppLinkPayload;
  // ios 收到VOIP消息
  EventHandlerMap _onReceiveVoipPayLoad;


  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    print(version);
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


    //deviceToken
    EventHandler onRegisterDeviceToken,
    //voipToken
    EventHandler onRegisterVoipToken,
    //ios 收到的透传内容
    EventHandler onReceivePayload,
    // ios 收到APNS消息
    EventHandlerMap onReceiveNotificationResponse,
    // ios 收到AppLink消息
    EventHandler onAppLinkPayload,
    // ios 收到VOIP消息
    EventHandlerMap onReceiveVoipPayLoad,
  }){
    _onReceiveClientId = onReceiveClientId;
    _onRegisterDeviceToken = onRegisterDeviceToken;
    _onRegisterVoipToken = onRegisterVoipToken;
    _onReceiveMessageData = onReceiveMessageData;
    _onNotificationMessageArrived = onNotificationMessageArrived;
    _onNotificationMessageClicked = onNotificationMessageClicked;

    _onReceivePayload = onReceivePayload;
    _onReceiveNotificationResponse = onReceiveNotificationResponse;
    _onAppLinkPayload = onAppLinkPayload;
    _onReceiveVoipPayLoad = onReceiveVoipPayLoad;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<Null> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "onReceiveClientId":
        print('onReceiveClientId' + call.arguments);
        return _onReceiveClientId(call.arguments);
        break;
      case "onReceiveMessageData":
        return _onReceiveMessageData(call.arguments.cast<String, dynamic>());
      case "onNotificationMessageArrived":
        return _onNotificationMessageArrived(call.arguments.cast<String, dynamic>());
      case "onNotificationMessageClicked":
        return _onNotificationMessageClicked(call.arguments.cast<String, dynamic>());
      case "onRegisterDeviceToken":
        return _onRegisterDeviceToken(call.arguments);
      case "onReceivePayload":
        return _onReceivePayload(call.arguments);
      case "onReceiveNotificationResponse":
        return _onReceiveNotificationResponse(call.arguments.cast<String, dynamic>());
      case "onAppLinkPayload":
        return _onAppLinkPayload(call.arguments);
      case "onRegisterVoipToken":
        return _onRegisterVoipToken(call.arguments);
      case "onReceiveVoipPayLoad":
        return _onReceiveVoipPayLoad(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecongnized Event");
    }
  }

  //ios
  //初始化SDK
  void startSdk({
    String appId,
    String appKey,
    String appSecret,

  }) {
    _channel.invokeMethod('startSdk',{'appId':appId, 'appKey':appKey, 'appSecret':appSecret});
  }



}
