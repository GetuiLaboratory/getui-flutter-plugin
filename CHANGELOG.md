## 0.1.9

1.新增bindAlias& unbindAlias &setBadge & resetBadge接口
2.新增setTags接口
3.完善readme
4.添加支持静态库
5.修复已知问题

## 0.2.1
1.新增setLocalBadge接口

## 0.2.3
1.新增getLaunchNotification

## 0.2.4
1. iOS application:continueUserActivity:restorationHandler 避免userActivity被系统清除
* TODO: Describe initial release.

## 0.2.5
1. 升级安卓个推和厂商SDK
2. 增加turnOnPush接口
3. stopPush接口修改为turnOffPush

## 0.2.6
1. 升级iOS GTSDK到2.5.4.0
2. iOS侧不再支持voip

## 0.2.7
1. 修复GTSDK兼容性问题 

## 0.2.8
1. iOS GTSDK 增加插件回调事件

## 0.2.9
1. 安卓升级flutter，替换过期方法


## 0.2.10
1. 支持 null safe

## 0.2.11
1. 去除v4包

## 0.2.12
1. 兼容iOS GTSDK 2.6.4.0
2. 增加setPushMode API

## 0.2.13
1.修改Android集成方式

## 0.2.14
提供函数给用户传递信息 GetuiflutPlugin.transmitUserMessage(map)

## 0.2.15
1. 兼容iOS GTSDK 2.7.0.0
2. iOS增加授权状态回调 onGrantAuthorization
3. continueUserActivity返回YES

## 0.2.16
1. 兼容Android setBadge接口

## 0.2.17
1. iOS 添加startSdkSimple、registerRemoteNotification、sdkVersion插件方法
2. android 适配Android 13

## 0.2.18
1. iOS 添加registerActivityToken插件方法
2. 
## 0.2.19
1.android 不再默认依赖GTSDK


## 0.2.20
1.android 扩展unbindAlias函数

## 0.2.21
1.android 扩展unbindAlias函数,bindAlias函数

## 0.2.22
1.android 修复setBadge函数

## 0.2.23
1. iOS 修复APNs静默回调问题,  新增runBackgroundEnable

## 0.2.24
1. iOS 升级实时活动（灵动岛）API，2. 修复冷启动点击回执。3. 修改静默回调处理

## 0.2.25
1. 升级dart版本为 ">=2.12.0 <=3.2.3"
2. 
## 0.2.26
1. andoird GetuiflutPlugin 实例在初始化的时候设置 
