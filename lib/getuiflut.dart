import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';

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
  EventHandlerMap _onReceivePayload;

  // ios 收到APNS消息
  EventHandlerMap _onReceiveNotificationResponse;

  // ios 收到AppLink消息
  EventHandler _onAppLinkPayload;

  // ios 收到VOIP消息
  EventHandlerMap _onReceiveVoipPayLoad;

  EventHandlerMap _onPushModeResult;
  EventHandlerMap _onSetTagResult;
  EventHandlerMap _onAliasResult;
  EventHandlerMap _onQueryTagResult;
  EventHandlerMap _onWillPresentNotification;
  EventHandlerMap _onOpenSettingsForNotification;

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
    EventHandler onReceiveClientId,
    EventHandlerMap onReceiveMessageData,
    EventHandlerMap onNotificationMessageArrived,
    EventHandlerMap onNotificationMessageClicked,

    //deviceToken
    EventHandler onRegisterDeviceToken,
    //voipToken
    EventHandler onRegisterVoipToken,
    //ios 收到的透传内容
    EventHandlerMap onReceivePayload,
    // ios 收到APNS消息
    EventHandlerMap onReceiveNotificationResponse,
    // ios 收到AppLink消息
    EventHandler onAppLinkPayload,
    // ios 收到VOIP消息
    EventHandlerMap onReceiveVoipPayLoad,

    // ios收到pushmode回调
    EventHandlerMap onPushModeResult,
    // ios收到setTag回调
    EventHandlerMap onSetTagResult,
    // ios收到别名回调
    EventHandlerMap onAliasResult,
    // ios收到查询tag回调
    EventHandlerMap onQueryTagResult,
    // ios收到APNs即将展示回调
    EventHandlerMap onWillPresentNotification,
    // ios收到APNs通知设置跳转回调
    EventHandlerMap onOpenSettingsForNotification,
  }) {
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
        print('onReceiveClientId' + call.arguments);
        if (_onReceiveClientId == null) {
          break;
        }
        return _onReceiveClientId(call.arguments);

      case "onReceiveMessageData":
        if (_onReceiveMessageData == null) {
          break;
        }
        return _onReceiveMessageData(call.arguments.cast<String, dynamic>());
      case "onNotificationMessageArrived":
        if (_onNotificationMessageArrived == null) {
          break;
        }
        return _onNotificationMessageArrived(
            call.arguments.cast<String, dynamic>());
      case "onNotificationMessageClicked":
        if (_onNotificationMessageClicked == null) {
          break;
        }
        return _onNotificationMessageClicked(
            call.arguments.cast<String, dynamic>());
      case "onRegisterDeviceToken":
        if (_onRegisterDeviceToken == null) {
          break;
        }
        return _onRegisterDeviceToken(call.arguments);
      case "onReceivePayload":
        if (_onReceivePayload == null) {
          break;
        }
        return _onReceivePayload(call.arguments.cast<String, dynamic>());
      case "onReceiveNotificationResponse":
        if (_onReceiveNotificationResponse == null) {
          break;
        }
        return _onReceiveNotificationResponse(
            call.arguments.cast<String, dynamic>());
      case "onAppLinkPayload":
        if (_onAppLinkPayload == null) {
          break;
        }
        return _onAppLinkPayload(call.arguments);
      case "onRegisterVoipToken":
        if (_onRegisterVoipToken == null) {
          break;
        }
        return _onRegisterVoipToken(call.arguments);
      case "onReceiveVoipPayLoad":
        if (_onReceiveVoipPayLoad == null) {
          break;
        }
        return _onReceiveVoipPayLoad(call.arguments.cast<String, dynamic>());

      case "onPushModeResult":
        if (_onPushModeResult == null) {
          break;
        }
        return _onPushModeResult(call.arguments.cast<String, dynamic>());
      case "onSetTagResult":
        if (_onSetTagResult == null) {
          break;
        }
        return _onSetTagResult(call.arguments.cast<String, dynamic>());
      case "onAliasResult":
        if (_onAliasResult == null) {
          break;
        }
        return _onAliasResult(call.arguments.cast<String, dynamic>());

      case "onWillPresentNotification":
        if (_onWillPresentNotification == null) {
          break;
        }
        return _onWillPresentNotification(
            call.arguments.cast<String, dynamic>());
      case "onOpenSettingsForNotification":
        if (_onOpenSettingsForNotification == null) {
          break;
        }
        return _onOpenSettingsForNotification(
            call.arguments.cast<String, dynamic>());
      case "onQueryTagResult":
        if (_onQueryTagResult == null) {
          break;
        }
        return _onQueryTagResult(call.arguments.cast<String, dynamic>());
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
    _channel.invokeMethod(
        'startSdk', {'appId': appId, 'appKey': appKey, 'appSecret': appSecret});
  }
}
