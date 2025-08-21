import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:convert';

// 事件回调类型定义
typedef Future<dynamic> EventHandler(String res);
typedef Future<dynamic> EventHandlerBool(bool res);
typedef Future<dynamic> EventHandlerMap(Map<String, dynamic> event);

class Getuiflut {
  static const MethodChannel _channel = const MethodChannel('getuiflut');


  /*-----------------------------
   *         事件处理器
   *----------------------------*/
  late EventHandler _onReceiveClientId;
  late EventHandler _onRegisterDeviceToken;
  late EventHandler _onAppLinkPayload;
  late EventHandler _onGrantAuthorization;
  late EventHandler _onReceiveOnlineState;

  late EventHandlerMap _onNotificationMessageArrived;
  late EventHandlerMap _onNotificationMessageClicked;
  late EventHandlerMap _onTransmitUserMessageReceive;
  late EventHandlerMap _onSetTagResult;
  late EventHandlerMap _onAliasResult;
  late EventHandlerMap _onQueryTagResult;
  late EventHandlerMap _onReceivePayload;
  late EventHandlerMap _onReceiveNotificationResponse;
  late EventHandlerMap _onPushModeResult;
  late EventHandlerMap _onWillPresentNotification;
  late EventHandlerMap _onOpenSettingsForNotification;
  late EventHandlerMap _onLiveActivityResult;
  late EventHandlerMap _onRegisterPushToStartTokenResult;

  /*-----------------------------
   *         SDK基础方法
   *----------------------------*/

  /// 获取平台版本
  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    print(version);
    return version;
  }

  /// 初始化SDK（Android/ohos）
   void get initGetuiSdk {
     _channel.invokeMethod('initGetuiPush');
  }

  /// 启动SDK（iOS标准模式）
  void startSdk({
    required String appId,
    required String appKey,
    required String appSecret,
  }) {
    _channel.invokeMethod(
      'startSdk',
      {'appId': appId, 'appKey': appKey, 'appSecret': appSecret},
    );
  }

  /// 启动SDK（iOS简单模式）
  void startSdkSimple({
    required String appId,
    required String appKey,
    required String appSecret,
  }) {
    if (Platform.isIOS) {
      _channel.invokeMethod(
        'startSdkSimple',
        {'appId': appId, 'appKey': appKey, 'appSecret': appSecret},
      );
    }
  }

  /*-----------------------------
   *        客户端信息获取
   *----------------------------*/

  /// 获取个推ClientId
   Future<String> get getClientId async {
    return await _channel.invokeMethod('getClientId');
  }

  /// 获取SDK版本号
   Future<String> get sdkVersion async {
    return await _channel.invokeMethod('sdkVersion');
  }
   Future<Map> get getLaunchNotification async {
    Map info = await _channel.invokeMethod('getLaunchNotification');
    return info;
  }

   Future<Map> get getLaunchLocalNotification async {
    Map info = await _channel.invokeMethod('getLaunchLocalNotification');
    return info;
  }


  /*-----------------------------
   *        推送控制方法
   *----------------------------*/

  /// 开启推送
  void turnOnPush() {
    if (!Platform.isIOS) {
      _channel.invokeMethod('resume');
    }
  }

  /// 关闭推送
  void turnOffPush() {
    if (!Platform.isIOS) {
      _channel.invokeMethod('stopPush');
    }
  }

  /// Android 注册Activity
  void onActivityCreate() {
    if (Platform.isAndroid) {
      _channel.invokeMethod('onActivityCreate');
    }
  }

  /*-----------------------------
   *        别名标签管理
   *----------------------------*/

  /// 绑定别名
  void bindAlias(String alias, String sn) {
    _channel.invokeMethod('bindAlias', {'alias': alias, 'aSn': sn});
  }

  /// 解绑别名
  void unbindAlias(String alias, String sn, bool isSelf) {
    _channel.invokeMethod(
        'unbindAlias', {'alias': alias, 'aSn': sn, 'isSelf': isSelf});
  }

  /// 设置标签
  void setTag(List<String> tags, String sn) {
    _channel.invokeMethod('setTag', {'tags': tags,'sn':sn});
  }

  //查询标签
  void queryTag(String sn) {
    _channel.invokeMethod('queryTag', {'sn':sn});
  }

  ///设置后台运行
  void runBackgroundEnable(int enable) {
    if (Platform.isAndroid) {
    } else {
      _channel.invokeMethod(
          'runBackgroundEnable', <String, dynamic>{'enable': enable});
    }
  }

  /// 设置角标
  void setBadge(int badge) {
    _channel.invokeMethod('setBadge', {'badge': badge});
  }
  //设置静默时间
  void setSilentTime(int beginHour, int duration) {
    _channel.invokeMethod('setSilentTime', {'beginHour': beginHour, "duration": duration});
  }
 //自定义action
  void sendFeedbackMessage(String taskId, String messageId, int actionId) {
    _channel.invokeMethod('sendFeedbackMessage', {'taskId': taskId , "messageId":messageId, "actionId":actionId});
  }


  /*-----------------------------
   *        iOS专属功能
   *----------------------------*/

  /// 设置推送模式（iOS）
  void setPushMode(int mode) {
    if (Platform.isIOS) {
      _channel.invokeMethod('setPushMode', {'mode': mode});
    }
  }

  /// 重置角标（iOS）
  void resetBadge() {
    if (Platform.isIOS) {
      _channel.invokeMethod('resetBadge');
    }
  }

  /// 设置本地角标（iOS）
  void setLocalBadge(int badge) {
    if (Platform.isIOS) {
      _channel.invokeMethod('setLocalBadge', {'badge': badge});
    }
  }

  /*-----------------------------
   *        设备Token管理
   *----------------------------*/

  /// 注册ActivityToken（iOS灵动岛）
  void registerActivityToken(String aid, String token, String sn) {
    _channel.invokeMethod(
        'registerActivityToken', {'aid': aid, 'token': token, 'sn': sn});
  }

  /// 注册PushToStartToken（iOS）
  void registerPushToStartToken(String attribute, String token, String sn) {
    _channel.invokeMethod('registerPushToStartToken',
        {'attribute': attribute, 'token': token, 'sn': sn});
  }

  /// 注册DeviceToken（iOS/Android）
  void registerDeviceToken(String token) {
    _channel.invokeMethod('registerDeviceToken', {'token': token});
  }

  /// 注册远程通知（iOS）
  void registerRemoteNotification() {
    if (Platform.isIOS) {
      _channel.invokeMethod('registerRemoteNotification');
    }
  }

  /*-----------------------------
   *        事件处理器配置
   *----------------------------*/
  void addEventHandler({
    required EventHandler onReceiveClientId,
    required EventHandlerMap onNotificationMessageArrived,
    required EventHandlerMap onNotificationMessageClicked,
    required EventHandlerMap onTransmitUserMessageReceive,
    required EventHandler onReceiveOnlineState,
    required EventHandler onRegisterDeviceToken,
    required EventHandlerMap onReceivePayload,
    required EventHandlerMap onReceiveNotificationResponse,
    required EventHandler onAppLinkPayload,
    required EventHandlerMap onPushModeResult,
    required EventHandlerMap onSetTagResult,
    required EventHandlerMap onAliasResult,
    required EventHandlerMap onQueryTagResult,
    required EventHandlerMap onWillPresentNotification,
    required EventHandlerMap onOpenSettingsForNotification,
    required EventHandler onGrantAuthorization,
    required EventHandlerMap onLiveActivityResult,
    required EventHandlerMap onRegisterPushToStartTokenResult,
  }) {
    // 初始化所有事件处理器
    _onReceiveClientId = onReceiveClientId;
    _onRegisterDeviceToken = onRegisterDeviceToken;
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
    _onTransmitUserMessageReceive = onTransmitUserMessageReceive;
    _onGrantAuthorization = onGrantAuthorization;
    _onLiveActivityResult = onLiveActivityResult;
    _onRegisterPushToStartTokenResult = onRegisterPushToStartTokenResult;
    _onReceiveOnlineState = onReceiveOnlineState;

    // 设置方法调用处理器
    _channel.setMethodCallHandler(_handleMethod);
  }

  /*-----------------------------
   *        内部处理方法
   *----------------------------*/
  Future _handleMethod(MethodCall call) async {
    print('_handleMethod  method:' + call.method);
    print('_handleMethod  args :' + call.arguments.toString());
    switch (call.method) {
      case "onReceiveClientId":
        return _onReceiveClientId(call.arguments);
      case "onRegisterDeviceToken":
        return _onRegisterDeviceToken(call.arguments);
      case "onNotificationMessageArrived":
        dynamic result;
        if (call.arguments is String) {
          result = jsonDecode(call.arguments) as Map<String, dynamic>;
        } else {
          result = call.arguments.cast<String, dynamic>();
        }
        return _onNotificationMessageArrived(result);
      case "onNotificationMessageClicked":
        dynamic result;
        if (call.arguments is String) {
          result = jsonDecode(call.arguments) as Map<String, dynamic>;
        } else {
          result = call.arguments.cast<String, dynamic>();
        }
        return _onNotificationMessageClicked(result);
      case "onReceivePayload":
        dynamic result;
        if (call.arguments is String) {
          result = jsonDecode(call.arguments) as Map<String, dynamic>;
        } else {
          result = call.arguments.cast<String, dynamic>();
        }
        return _onReceivePayload(result);
      case "onSetTagResult":
        dynamic result;
        if (call.arguments is String) {
          result = jsonDecode(call.arguments) as Map<String, dynamic>;
        } else {
          result = call.arguments.cast<String, dynamic>();
        }
        return _onSetTagResult(result);
      case "onAliasResult":
        dynamic result;
        if (call.arguments is String) {
          result = jsonDecode(call.arguments) as Map<String, dynamic>;
        } else {
          result = call.arguments.cast<String, dynamic>();
        }
        return _onAliasResult(result);
      case "onQueryTagResult":
        dynamic result;
        if (call.arguments is String) {
          result = jsonDecode(call.arguments) as Map<String, dynamic>;
        } else {
          result = call.arguments.cast<String, dynamic>();
        }
        return _onQueryTagResult(result);
      case "onReceiveNotificationResponse":
        return _onReceiveNotificationResponse(
            call.arguments.cast<String, dynamic>());
      case "onAppLinkPayload":
        return _onAppLinkPayload(call.arguments);
      case "onPushModeResult":
        return _onPushModeResult(call.arguments.cast<String, dynamic>());
      case "onWillPresentNotification":
        return _onWillPresentNotification(
            call.arguments.cast<String, dynamic>());
      case "onOpenSettingsForNotification":
        return _onOpenSettingsForNotification(
            call.arguments.cast<String, dynamic>());
      case "onTransmitUserMessageReceive":
        return _onTransmitUserMessageReceive(
            call.arguments.cast<String, dynamic>());
      case "onGrantAuthorization":
        return _onGrantAuthorization(call.arguments);
      case "onLiveActivityResult":
        return _onLiveActivityResult(call.arguments.cast<String, dynamic>());
      case "onRegisterPushToStartTokenResult":
        return _onRegisterPushToStartTokenResult(
            call.arguments.cast<String, dynamic>());
      case "onReceiveOnlineState":
        return _onReceiveOnlineState(call.arguments);
      default:
        throw new UnsupportedError("Unrecongnized Event");
    }
  }
}
