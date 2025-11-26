# Getui Flutter Plugin 集成与使用指南

## 1. 引入插件

在 `pubspec.yaml` 中添加以下依赖：

```markdown
dependencies:
  getuiflut: ^0.2.39
```


执行以下命令下载依赖并运行项目：

```shell
flutter pub get
flutter run
```

或者直接通过命令行添加：
```shell
flutter pub add getuiflut
```

## 2. 配置

### 2.1 Android 配置
参考[个推官网文档](https://docs.getui.com/getui/mobile/android/overview/)进行配置。
核心PushService、GTIntentService已经内置在flutter插件中

#### 配置 Maven 库地址
在项目根目录 `build.gradle` 文件中添加：
```yaml
allprojects {
    repositories {
        mavenCentral()
        google()
        maven {
            url "https://mvn.getui.com/nexus/content/repositories/releases/"
        }
    }
}
```

#### 添加依赖
在 `android/app/build.gradle` 文件中配置：
```yaml
android {
    defaultConfig {
        manifestPlaceholders = [
            GETUI_APPID: "your appid"
        ]
    }
}

dependencies {
    //在官网查阅最新版本(https://docs.getui.com/getui/mobile/android/overview/)
    implementation 'com.getui:gtsdk:3.3.12.0'  // 个推 SDK
    implementation 'com.getui:gtc:3.2.18.0'    // 个推核心组件
}
```

### 2.2 iOS 配置
在 `main.dart` 中添加以下代码以启动 SDK：
```dart
Getuiflut().startSdk(
    appId: "8eLAkGIYnGAwA9fVYZU93A",
    appKey: "VFX8xYxvVF6w59tsvY6XN",
    appSecret: "Kv3TeED8z19QwnMLdzdI35"
);
```

#### 启用通知
在 Xcode 中，进入 `Signing & Capabilities`，添加 `Push Notifications`。

#### Notification Service Extension
为精确统计消息送达率，可添加 `Notification Service Extension`，并在 Extensions 中调用 `GTExtensionSDK` 的统计接口。具体参考[个推 iOS 集成文档](https://docs.getui.com/getui/mobile/ios/xcode/)。

### 2.3 HarmonyOS 配置
*  引入插件, 见上文
* 使用鸿蒙定制版 Flutter，否则报错依赖缺失, 下载地址: [OpenHarmony Flutter](https://gitcode.com/openharmony-tpc/flutter_flutter) 及 [使用教程](https://developer.huawei.com/consumer/cn/blog/topic/03178381351651116)。
* [启动应用教程](https://gitcode.com/openharmony-tpc/flutter_flutter#%E6%9E%84%E5%BB%BA%E6%AD%A5%E9%AA%A4)

#### 2.3.1 配置 `build-profile.json5`
ohos工程需要兼容字节码包,在项目级build-profile.json5:
```yaml
    "buildOption": {
      "strictMode": {
         "useNormalizedOHMUrl": true
      }
    }
```

#### 2.3.2 配置 `module.json5`
在项目中配置：
```yaml
"requestPermissions": [
    {"name": "ohos.permission.INTERNET"},
    {"name": "ohos.permission.GET_NETWORK_INFO"},
    {"name": "ohos.permission.KEEP_BACKGROUND_RUNNING"},
    {
        "name": "ohos.permission.APP_TRACKING_CONSENT",
        "reason": "$string:tracking_reason",
        "usedScene": {
            "abilities": ["EntryAbility"]
        }
    }
],
"metadata": [
    {"name": "GETUI_APPID", "value": "djYjSlFVMf6p5YOy2OQUs8"},//你的appid
    {"name": "ZX_CHANNELID_GT", "value": "C01-GEztJH0JLdBC"},
    {"name": "client_id", "value": "109599703"},//厂商appid,开通在官网找技术支持协助
    {"name": "GT_PUSH_LOG", "value": "false"} //sdk文件日志开关, 技术支持问题排查时使用
]
```
#### 2.3.3 注册插件
运行 fvm flutter build hap 后自动生成 GeneratedPluginRegistrant


#### 2.3.4 配置在线通知点击事件
* 通过个推在线渠道展示的通知类消息，待通知点击打开目的页面后，由客户必须调用PushManager.setClickWant(want)完善报表和完成后续业务，以免影响消息业务使用（重要）
  * 通知点击打开应用页面（目的页面由下发通知时决定）
  * 通知点击打开浏览器
* 配置参考demo代码: [EntryAbility.ets](example/ohos/entry/src/main/ets/entryability/EntryAbility.ets)



#### 2.3.5 其他API功能
参考: [官网文档](https://docs.getui.com/getui/mobile/harmonyos/vendor/vendor_open/)



## 3. 使用方法

### 3.1 公共 API
导入插件：
```dart
import 'package:getuiflut/getuiflut.dart';
```

#### 初始化 SDK (Android/ohos)
```dart
Getuiflut().initGetuiSdk;
```

#### 设置角标
```dart
setBadge(badge);
```

#### 绑定/解绑别名
```dart
bindAlias(alias, sn);
unbindAlias(alias, sn);
```
* sn:  绑定序列码,不为nil


#### 设置/查询标签
```dart
setTag(tags,sn);
queryTag(sn)
```
* sn:  绑定序列码,不为nil

#### 开启/关闭推送服务（iOS 不支持）
```dart
turnOnPush();
turnOffPush();
```

#### 获取版本和 CID
```dart
getClientId();
```

#### 设置静默时间(IOS不支持)
```dart
setSilentTime(beginHour,duration)
```
* 开始时间，beginHour >= 0 && beginHour < 24，单位 h
* duration：持续时间，duration > 0 && duration <= 23，持续时间为 0 则取消静默，单位 h


#### 自定义回执
```dart
sendFeedbackMessage( taskId,  messageId,  actionId)
```
* actionId：自定义的actionId，取值范围是 90001-90999

#### 回调方法
设置事件监听：
```dart
Getuiflut().addEventHandler(
  	onReceiveClientId: (String message) async {
      print("flutter onReceiveClientId: $message");
    }, onReceiveOnlineState: (String online) async {
      print("flutter onReceiveOnlineState: $online");
    },onReceivePayload: (Map<String, dynamic> message) async {
      print("flutter onReceivePayload: $message");
    },onSetTagResult: (Map<String, dynamic> message) async {
      print("flutter onSetTagResult: $message");
    }, onAliasResult: (Map<String, dynamic> message) async {
      print("flutter onAliasResult: $message");
    }, onQueryTagResult: (Map<String, dynamic> message) async {
      print("flutter onQueryTagResult: $message");
    },onRegisterDeviceToken: (String message) async {
      print("flutter onRegisterDeviceToken: $message");
    },
  	//Android 、ohos 特有
  	onNotificationMessageArrived: (Map<String, dynamic> msg) async {
      print("flutter onNotificationMessageArrived: $msg");
    }, onNotificationMessageClicked: (Map<String, dynamic> msg) async {
      print("flutter onNotificationMessageClicked: $msg");
    },
    //以下IOS特有                        
    onTransmitUserMessageReceive: (Map<String, dynamic> msg) async {
      print("flutter onTransmitUserMessageReceive:$msg");
    },onReceiveNotificationResponse: (Map<String, dynamic> message) async {
      print("flutter onReceiveNotificationResponse: $message");
    }, onAppLinkPayload: (String message) async {
      print("flutter onAppLinkPayload: $message");
    }, onPushModeResult: (Map<String, dynamic> message) async {
      print("flutter onPushModeResult: $message");
    }, onWillPresentNotification: (Map<String, dynamic> message) async {
      print("flutter onWillPresentNotification: $message");
    }, onOpenSettingsForNotification: (Map<String, dynamic> message) async {
      print("flutter onOpenSettingsForNotification: $message");
    }, onGrantAuthorization: (String granted) async {
      print("flutter onGrantAuthorization: $granted");
    }, onLiveActivityResult: (Map<String, dynamic> message) async {
      print("flutter onLiveActivityResult: $message");
    }, onRegisterPushToStartTokenResult: (Map<String, dynamic> message) async {
      print("flutter onRegisterPushToStartTokenResult: $message");
    });
```

### 3.2 iOS 专用 API
#### 启动 SDK 并请求通知权限
```dart
startSdk(appId, appKey, appSecret);
```

#### 仅启动 SDK
```dart
startSdkSimple(appId, appKey, appSecret);
```

#### 注册远程通知
```dart
registerRemoteNotification(appId, appKey, appSecret);
```

#### 获取启动参数
```dart
getLaunchOptions();
getLaunchNotification();
```

#### 管理角标
```dart
setBadge(badge);
resetBadge();
setLocalBadge(badge);
```

#### 后台模式
```dart
runBackgroundEnable(enable);
```

#### 灵动岛支持（GTSDK ≥ 2.7.3.0）
```dart
registerActivityToken(aid, token, sn);
registerPushToStartToken(attribute, token, sn);
```



#### AppDelegate 配置

在 `AppDelegate.m` 中重写以下方法以确保 SDK 正常工作：
```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // 保持空实现
}
```

**版本兼容性**：
- GTSDK ≤ 2.4.6.0：使用插件版本 ≤ 0.2.5
- GTSDK > 2.4.6.0：使用最新插件版本
```

**说明**：如需更多细节，可参考[个推官方文档](https://docs.getui.com),联系技术支持。
```





#### UIScene 配置

在 `SceneDelegate.m` 中需要将启动参数传递给flutter插件，[GetuiflutPlugin handleSceneWillConnectWithOptions:connectionOptions];

```
#import "SceneDelegate.h"
#import <Flutter/Flutter.h>
#import "GeneratedPluginRegistrant.h"
#import <GTSDK/GetuiSdk.h>
#import "GetuiflutPlugin.h"

@interface SceneDelegate () <GeTuiSdkDelegate>

@end
  
@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // 配置窗口场景
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    } else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    // 创建并设置 Flutter 视图控制器
    FlutterViewController *flutterViewController = [FlutterViewController new];
    self.window.rootViewController = flutterViewController;
    
    // 注册 Flutter 插件
    [GeneratedPluginRegistrant registerWithRegistry:flutterViewController];
    
     
    
    //TODO:用于获取UIScene模式下的通知数据
    [GetuiflutPlugin handleSceneWillConnectWithOptions:connectionOptions];
     
    
    // 使窗口可见
    [self.window makeKeyAndVisible];
}
```

