# Getui Flutter Plugin



### 引用
在工程 pubspec.yaml 中加入 dependencies
```yaml
dependencies:
  getuiflut: ^0.2.8
```
Pub.dev:
<a href=" https://pub.dartlang.org/packages?q=getuiflut" target="_blank">getui-flutter-plugin</a>

### 配置
### Android:

#### 1.添加相关配置：

在 `/android/app/build.gradle` 中添加下列代码：
```groovy
android: {
  ....
  defaultConfig {
    applicationId ""
    
    manifestPlaceholders = [
    	GETUI_APP_ID    : "USER_APP_ID",
    	GETUI_APP_KEY   : "USER_APP_KEY",
    	GETUI_APP_SECRET: "USER_APP_SECRET",
        // 下面是多厂商配置，如需要开通使用请联系技术支持
        // 如果不需要使用，预留空字段即可
         XIAOMI_APP_ID   : "",
         XIAOMI_APP_KEY  : "",
         MEIZU_APP_ID    : "",
         MEIZU_APP_KEY   : "",
         HUAWEI_APP_ID   : "",
         OPPO_APP_KEY   : "",
         OPPO_APP_SECRET  : "",
         VIVO_APP_ID   : "",
         VIVO_APP_KEY  : ""
    ]
  }    
}
```

#### 2.添加依赖地址

```
buildscript {
    repositories {
        jcenter()
        google()
        maven {
            url "http://mvn.gt.getui.com/nexus/content/repositories/releases/"
        }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:3.1.0'
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }

}

allprojects {
    repositories {
        jcenter()
        google()
        maven {
            url "http://mvn.gt.getui.com/nexus/content/repositories/releases/"
        }
    }
}
```

### 集成 HMS SDK

#### 1. 添加应用的 AppGallery Connect 配置文件

1. 登录 AppGallery Connect 网站，选择“我的应用”。找到应用所在的产品，点击应用名称。

2. 选择“开发 > 概览”，单击“应用”栏下的“agconnect-services.json”下载配置文件。

3. 将 agconnect-services.json 文件拷贝到应用级根目录下。如下：

   ```
   android/
     |- app/ （项目主模块）
     |  ......
     |    |- build.gradle （模块级 gradle 文件）
     |    |- agconnect-services.json 
     |- gradle/
     |- build.gradle （顶层 gradle 文件）
     |- settings.gradle
     | ......
   ```

#### 2. 配置相应依赖

1.在以项目名为命名的**顶层** `build.gradle` 文件的 `buildscript.repositories` 和 `allprojects.repositories` 中，添加 HMS SDK 的 maven 仓地址 `maven {url 'http://developer.huawei.com/repo/'}`。在 `buildscript.dependencies` 添加 `classpath 'com.huawei.agconnect:agcp:${version}'` 如下所示：

```
buildscript {
    repositories {
        jcenter()
        google()
        maven {url 'http://developer.huawei.com/repo/'}
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:3.1.0'
        classpath 'com.huawei.agconnect:agcp:1.3.1.300'
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }

}

allprojects {
    repositories {
        jcenter()
        google()
        maven {url 'http://developer.huawei.com/repo/'}
    }
}
```

2.该步骤需要在模块级别 `app/build.gradle` 中文件头配置 `apply plugin: 'com.huawei.agconnect'` 以及在 `dependencies` 块配置 HMS Push 依赖 `implementation 'com.huawei.hms:push:${version}'`，如下：

```
apply plugin: 'com.android.application'
apply plugin: 'com.huawei.agconnect'
android { 
    ......
}
dependencies { 
    ......
    implementation 'com.huawei.hms:push:5.0.2.300'
}
```

3.配置签名信息：将步骤一【创建华为应用】中官方文档**生成签名证书指纹步骤中生成的签名文件拷贝到工程的 app 目录下**，在 app/build.gradle 文件中配置签名。如下（具体请根据您当前项目的配置修改）：

```
signingConfigs {
     config {
         keyAlias 'pushdemo'
         keyPassword '123456789'
         storeFile file('pushdemo.jks')
         storePassword '123456789'
     }
 }
 buildTypes {
     debug {
         signingConfig signingConfigs.config
     }
     release {
         signingConfig signingConfigs.config
         minifyEnabled false
         proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
     }
 }
```

### iOS:

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

​	

### Android API

```dart
/**
	*初始化个推sdk
	*/
Getuiflut.initGetuiSdk();

### 公用 API
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

### iOS API

- GTSDK<=2.4.6.0版本，需要使用插件版本<=0.2.5
- GTSDK>2.4.6.0版本，需要使用最新插件版本

/**
  *  同步服务端角标
    *
    */
setBadge(badge);

/**
  *  复位服务端角标
    *
    */
resetBadge();

/**
  *  同步App本地角标
    *
    */
setLocalBadge(badge); 


/**
  *  获取冷启动Apns参数
    *
    */
getLaunchNotification();

#### 回调方法

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
    ）;
 
```




