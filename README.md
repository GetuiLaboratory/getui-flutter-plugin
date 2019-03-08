# Getui Flutter Plugin



### 引用
在工程 pubspec.yaml 中加入 dependencies
```yaml
dependencies:
  getuiflut: ^0.0.2
```

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
##### iOS:


### 使用
```dart
import 'package:getuiflut/getuiflut.dart';
```

### API 

```dart
Getuiflut().addEventHandler(
      onReceiveClientId: (String message) async {
        print("flutter onReceiveClientId: $message"); // 注册收到 cid 的回调
        setState(() {
          _platformVersion = "flutter onReceiveClientId: $message";
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

