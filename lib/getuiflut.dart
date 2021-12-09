import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';

typedef Future<dynamic> EventHandler(String res);
typedef Future<dynamic> EventHandlerMap(Map<String, dynamic> event);

class Getuiflut {
  static const MethodChannel _channel = const MethodChannel('getuiflut');

  late EventHandler _onReceiveClientId;
  late EventHandlerMap _onReceiveMessageData;
  late EventHandlerMap _onNotificationMessageArrived;
  late EventHandlerMap _onNotificationMessageClicked;

  // deviceToken
  late EventHandler _onRegisterDeviceToken;

  //  iOS收到的透传内容
  late EventHandlerMap _onReceivePayload;

  // ios 收到APNS消息
  late EventHandlerMap _onReceiveNotificationResponse;

  // ios 收到AppLink消息
  late EventHandler _onAppLinkPayload;

  late EventHandlerMap _onPushModeResult;
  late EventHandlerMap _onSetTagResult;
  late EventHandlerMap _onAliasResult;
  late EventHandlerMap _onQueryTagResult;
  late EventHandlerMap _onWillPresentNotification;
  late EventHandlerMap _onOpenSettingsForNotification;

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

  static Future<Map> get getLaunchNotification async {
    Map info = await _channel.invokeMethod('getLaunchNotification');
    return info;
  }

  void turnOnPush() {
    _channel.invokeMethod('resume');
  }

  void turnOffPush() {
    if (Platform.isAndroid) {
      _channel.invokeMethod('stopPush');
    }
  }

  void onActivityCreate() {
    _channel.invokeMethod('onActivityCreate');
  }

  void bindAlias(String alias, String sn) {
    if (Platform.isAndroid) {
      _channel.invokeMethod('bindAlias', <String, dynamic>{'alias': alias});
    } else {
      _channel.invokeMethod(
          'bindAlias', <String, dynamic>{'alias': alias, 'aSn': sn});
    }
  }

  void unbindAlias(String alias, String sn, bool isSelf) {
    if (Platform.isAndroid) {
      _channel.invokeMethod('unbindAlias', <String, dynamic>{'alias': alias});
    } else {
      _channel.invokeMethod('unbindAlias',
          <String, dynamic>{'alias': alias, 'aSn': sn, 'isSelf': isSelf});
    }
  }

  void setBadge(int badge) {
    if (Platform.isAndroid) {
    } else {
      _channel.invokeMethod('setBadge', <String, dynamic>{'badge': badge});
    }
  }

  void resetBadge() {
    if (Platform.isAndroid) {
    } else {
      _channel.invokeMethod('resetBadge');
    }
  }

  void setLocalBadge(int badge) {
    if (Platform.isAndroid) {
    } else {
      _channel.invokeMethod('setLocalBadge', <String, dynamic>{'badge': badge});
    }
  }

  void setTag(List<dynamic> tags) {
    _channel.invokeMethod('setTag', <String, dynamic>{'tags': tags});
  }

  void addEventHandler({
    required EventHandler onReceiveClientId,
    required EventHandlerMap onReceiveMessageData,
    required EventHandlerMap onNotificationMessageArrived,
    required EventHandlerMap onNotificationMessageClicked,

    //deviceToken
    required EventHandler onRegisterDeviceToken,

    //ios 收到的透传内容
    required EventHandlerMap onReceivePayload,
    // ios 收到APNS消息
    required EventHandlerMap onReceiveNotificationResponse,
    // ios 收到AppLink消息
    required EventHandler onAppLinkPayload,

    // ios收到pushmode回调
    required EventHandlerMap onPushModeResult,
    // ios收到setTag回调
    required EventHandlerMap onSetTagResult,
    // ios收到别名回调
    required EventHandlerMap onAliasResult,
    // ios收到查询tag回调
    required EventHandlerMap onQueryTagResult,
    // ios收到APNs即将展示回调
    required EventHandlerMap onWillPresentNotification,
    // ios收到APNs通知设置跳转回调
    required EventHandlerMap onOpenSettingsForNotification,
  }) {
    _onReceiveClientId = onReceiveClientId;

    _onRegisterDeviceToken = onRegisterDeviceToken;

    _onReceiveMessageData = onReceiveMessageData;
    _onNotificationMessageArrived = onNotificationMessageArrived;
    _onNotificationMessageClicked = onNotificationMessageClicked;

    _onReceivePayload = onReceivePayload;
    _onReceiveNotificationResponse = onReceiveNotificationResponse;
    _onAppLinkPayload = onAppLinkPayload;

    _onPushModeResult = onPushModeResult;
    _onSetTagResult = onSetTagResult;
    _onAliasResult = onAliasResult;

    _onQueryTagResult = onQueryTagResult;
    _onWillPresentNotification = onWillPresentNotification;
    _onOpenSettingsForNotification = onOpenSettingsForNotification;
    _onQueryTagResult = onQueryTagResult;
    _onWillPresentNotification = onWillPresentNotification;
    _onOpenSettingsForNotification = onOpenSettingsForNotification;

    _channel.setMethodCallHandler(_handleMethod);
  }

  Future _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onReceiveClientId":
        print('onReceiveClientId:' + call.arguments);
        return _onReceiveClientId(call.arguments);
      case "onReceiveMessageData":
        return _onReceiveMessageData(call.arguments.cast<String, dynamic>());
      case "onNotificationMessageArrived":
        return _onNotificationMessageArrived(
            call.arguments.cast<String, dynamic>());
      case "onNotificationMessageClicked":
        return _onNotificationMessageClicked(
            call.arguments.cast<String, dynamic>());
      case "onRegisterDeviceToken":
        return _onRegisterDeviceToken(call.arguments);
      case "onReceivePayload":
        return _onReceivePayload(call.arguments.cast<String, dynamic>());
      case "onReceiveNotificationResponse":
        return _onReceiveNotificationResponse(
            call.arguments.cast<String, dynamic>());
      case "onAppLinkPayload":
        return _onAppLinkPayload(call.arguments);

      case "onPushModeResult":
        return _onPushModeResult(call.arguments.cast<String, dynamic>());
      case "onSetTagResult":
        return _onSetTagResult(call.arguments.cast<String, dynamic>());
      case "onAliasResult":
        return _onAliasResult(call.arguments.cast<String, dynamic>());

      case "onWillPresentNotification":
        return _onWillPresentNotification(
            call.arguments.cast<String, dynamic>());
      case "onOpenSettingsForNotification":
        return _onOpenSettingsForNotification(
            call.arguments.cast<String, dynamic>());
      case "onQueryTagResult":
        return _onQueryTagResult(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecongnized Event");
    }
  }

  //ios
  //初始化SDK
  void startSdk({
    required String appId,
    required String appKey,
    required String appSecret,
  }) {
    _channel.invokeMethod(
        'startSdk', {'appId': appId, 'appKey': appKey, 'appSecret': appSecret});
  }
}
