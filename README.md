# Getui Flutter Plugin



### 引用
在工程 pubspec.yaml 中加入 dependencies
```yaml
dependencies:
  getuiflut: ^0.0.7  
```
Pub.dev:
<a href=" https://pub.dartlang.org/packages?q=getuiflut" target="_blank">getui-flutter-plugin</a>

### 配置
##### Android:

在 `/android/app/build.gradle` 中添加下列代码：
```groovy
android: {
  ....
  defaultConfig {
    applicationId ""
    
    manifestPlaceholders = [
    	GETUI_APP_ID    : "USER_APP_ID",
    	GETUI_APP_KEY   : "USER_APP_KEY",
    	GETUI_APP_SECRET: "USER_APP_SECRET" 
    ]
  }    
}
```
##### Android多厂商版本：getuiflut:^0.0.8
```
android: {
  ....
  defaultConfig {
    applicationId ""
    
    manifestPlaceholders = [
    		    GETUI_APP_ID    : "",
                GETUI_APP_KEY   : "",
                GETUI_APP_SECRET: "",

                XIAOMI_APP_ID : "",
                XIAOMI_APP_KEY : "",

                MEIZU_APP_ID : "",
                MEIZU_APP_KEY : "",

                HUAWEI_APP_ID : "",

                OPPO_APP_KEY   : "",
                OPPO_APP_SECRET  : "",

                VIVO_APP_ID   : "",
                VIVO_APP_KEY  : "" 
    ]
  }    
}
```
个推多厂商的各类参数及服务开通请联系技术人员 🦀boss



##### iOS:

在你项目的main.dart中添加下列代码：

```
   Getuiflut().startSdk(
      appId: "8eLAkGIYnGAwA9fVYZU93A",
      appKey: "VFX8xYxvVF6w59tsvY6XN",
      appSecret: "Kv3TeED8z19QwnMLdzdI35"
   );
    
```

### 使用
```dart
import 'package:getuiflut/getuiflut.dart';
```

### iOS API

```
	Getuiflut().addEventHandler(
      onReceiveClientId: (String message) async {
        print("flutter onReceiveClientId: $message");
        setState(() {
          _getClientId = "ClientId: $message";
        });
      },
      onRegisterDeviceToken: (String message) async {
        setState(() {
          _getDeviceToken = "DeviceToken: $message";
        });
      },
      onReceivePayload: (String message) async {
        setState(() {
          _onReceivePayload = "$message";
        });
      },
      onReceiveNotificationResponse: (Map<String, dynamic> message) async {
        setState(() {
          _onReceiveNotificationResponse = "$message";
        });
      },
      onAppLinkPayload: (String message) async {
        setState(() {
          _onAppLinkPayLoad = "$message";
        });
      },
      onRegisterVoipToken: (String message) async {
        setState(() {
          _getVoipToken = "$message";
        });
      },
      onReceiveVoipPayLoad: (Map<String, dynamic> message) async {
        setState(() {
          _onReceiveVoipPayLoad = "$message";
        });
      },
    ）;
```


### Android API 

```dart
Getuiflut().addEventHandler(
      onReceiveClientId: (String message) async {
        print("flutter onReceiveClientId: $message"); // 注册收到 cid 的回调
        setState(() {
          _getClientId = "flutter onReceiveClientId: $message";
        });
      },
      onReceiveMessageData: (Map<String, dynamic> msg) async {
        print("flutter onReceiveMessageData: $msg"); // 透传消息的内容都会走到这里
        setState(() {
          _payloadInfo = msg['payload'];
        });
      },
      onNotificationMessageArrived: (Map<String, dynamic> msg) async {
        print("flutter onNotificationMessageArrived"); // 消息到达的回调
        setState(() {
          _notificationState = 'Arrived';
        });
      },
      onNotificationMessageClicked: (Map<String, dynamic> msg) async {
        print("flutter onNotificationMessageClicked"); // 消息点击的回调
        setState(() {
          _notificationState = 'Clicked';
        });
      },
    );
```

