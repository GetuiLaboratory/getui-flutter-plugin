# Getui Flutter Plugin


## 1、引用

Pub.dev:
<a href="https://pub.dev/packages/getuiflut" target="_blank">getui-flutter-plugin</a>

增加依赖：

```shell
flutter pub add getuiflut
```

或者手动在工程 pubspec.yaml 中加入 dependencies：

```yaml
dependencies:
  getuiflut: ^0.2.24
```
下载依赖：

```shell
flutter pub get
flutter run
```

## 2、配置

### 2.1、Android:

参考官网文档中心进行配置：https://docs.getui.com/getui/mobile/android/overview/

flutter插件默认包含自定义组件，Flutter用户不用处理以下配置：

- Android->集成指南-> 3.配置推送服务-> FlutterPushService ("继承自 com.igexin.sdk.PushService 的自定义 Service")

- Android->集成指南-> 6.编写集成代码-> FlutterIntentService ("继承自 com.igexin.sdk.GTIntentService 的自定义 Service")

**注意：**
^0.2.19开始getuiflut不再默认依赖GTSDK，请自己在android/app/build.gradle文件下增加依赖，如：
```yaml
dependencies {
    implementation 'com.getui:gtsdk:3.2.18.0'  //个推SDK
    implementation 'com.getui:gtc:3.2.6.0'  //个推核心组件
}
```

### 2.2、iOS:

在你项目的main.dart中添加下列代码：
```dart
   Getuiflut().startSdk(
      appId: "8eLAkGIYnGAwA9fVYZU93A",
      appKey: "VFX8xYxvVF6w59tsvY6XN",
      appSecret: "Kv3TeED8z19QwnMLdzdI35"
   );
```
启用notification：xcode主工程配置 > Signing & Capabilities > +Push Noticifations

**注意：** 

Apple 在 iOS 10 中新增了Notification Service Extension机制，可在消息送达时进行业务处理。为精确统计消息送达率，在集成个推SDK时，可以添加 Notification Service Extension，并在 Extensions 中添加 GTExtensionSDK 的统计接口，实现消息展示回执统计功能。具体可参考[个推集成文档](https://docs.getui.com/getui/mobile/ios/xcode/)。

## 3、使用
```dart
import 'package:getuiflut/getuiflut.dart';
```

### 3.1、公共 API

* 公共 API

```dart
/**
	* 绑定别名功能:后台可以根据别名进行推送
	*
	* @param alias 别名字符串
	* @param aSn   绑定序列码, Android中无效，仅在iOS有效
	*/
bindAlias(alias, sn);
unbindAlias(alias, sn);

/**
  *  给用户打标签 , 后台可以根据标签进行推送
  *
  *  @param tags 别名数组
  */
setTag(tags);

/**
  *  停止SDK服务
  *
  */
turnOffPush();

/**
  *  开启SDK服务
  *
  */
turnOnPush();
```

* 回调方法

```dart
Getuiflut().addEventHandler(
    	// 注册收到 cid 的回调
      onReceiveClientId: (String message) async {
        print("flutter onReceiveClientId: $message");
        setState(() {
          _getClientId = "ClientId: $message";
        });
      },
    	// 注册 DeviceToken 回调
      onRegisterDeviceToken: (String message) async {
        setState(() {
          _getDeviceToken = "DeviceToken: $message";
        });
      },
    	// SDK收到透传消息回调
      onReceivePayload: (Map<String, dynamic> message) async {
        setState(() {
          _onReceivePayload = "$message";
        });
      },
    	// 点击通知回调
      onReceiveNotificationResponse: (Map<String, dynamic> message) async {
        setState(() {
          _onReceiveNotificationResponse = "$message";
        });
      },
    	// APPLink中携带的透传payload信息
      onAppLinkPayload: (String message) async {
        setState(() {
          _onAppLinkPayLoad = "$message";
        });
      },
    	//通知服务开启\关闭回调
      onPushModeResult: (Map<String, dynamic> message) async {
        print("flutter onPushModeResult: $message");
      },
	// SetTag回调
      onSetTagResult: (Map<String, dynamic> message) async {
        print("flutter onSetTagResult: $message");
      },
	//设置别名回调
      onAliasResult: (Map<String, dynamic> message) async {
        print("flutter onAliasResult: $message");
      },
	//查询别名回调
      onQueryTagResult: (Map<String, dynamic> message) async {
        print("flutter onQueryTagResult: $message");
      },
	//APNs通知即将展示回调
      onWillPresentNotification: (Map<String, dynamic> message) async {
        print("flutter onWillPresentNotification: $message");
      }, 
	//APNs通知设置跳转回调
      onOpenSettingsForNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenSettingsForNotification: $message");
      }, 
      onGrantAuthorization: (String granted) async {
        print("flutter onGrantAuthorization: $granted");
      },
    ）;
```

### 3.2、Android API

```dart
/**
	*初始化个推sdk
	*/
Getuiflut.initGetuiSdk();
/**
*设置角标
*/
  setBadge(badge);
```

### 3.2、iOS API

首先，开发者需要在AppDelegate.m中，重写APNs系统方法，如：

```
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //warning: 需要重写当前方法，gtsdk的接管系统方法就会生效，否则会影响回执
    //保持空实现
}
```





- GTSDK<=2.4.6.0版本，需要使用插件版本<=0.2.5
- GTSDK>2.4.6.0版本，需要使用最新插件版本
```dart
    /**
    *  启动sdk+通知授权
    */ 
    startSdk(appId,appKey,appSecret);
    

    /**
    *  启动sdk
    */ 
    startSdkSimple(appId,appKey,appSecret);


    /**
    *  通知授权,需要先启动sdk。
    */ 
    registerRemoteNotification(appId,appKey,appSecret);
 

    /**
    *  获取冷启动APNs参数
    */
    getLaunchNotification();

    /**
    *  同步服务端角标
    */
    setBadge(badge);

    /**
    *  复位服务端角标
    */
    resetBadge();

    /**
    *  同步App本地角标
    *
    */
    setLocalBadge(badge); 

    /*
    *  开启\关闭后台模式
    */
    runBackgroundEnable(enable)
    
    /*
    *  注册灵动岛token。支持版本2.7.3.0及以上。 
    *  GTSDK>=3.0.3.0，会有onLiveActivityResult回调
    */
    registerActivityToken(aid, token,sn) 
```



