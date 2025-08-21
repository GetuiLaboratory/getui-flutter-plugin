
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:getuiflut/getuiflut.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _userMsg = '';
  String _notificationState = '';
  String _getClientId = '';
  String _getDeviceToken = '';
  String _onReceivePayload = '';
  String _onReceiveNotificationResponse = '';
  String _onAppLinkPayLoad = '';
  final Getuiflut _getui = Getuiflut();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // 初始化平台状态
  Future<void> initPlatformState() async {
    String platformVersion;
    String payloadInfo = 'default';
    String notificationState = 'default';

    try {
      // 获取平台版本
      platformVersion = await _getui.platformVersion;
      print('平台版本: $platformVersion');

      // iOS 初始化 SDK
      if (Platform.isIOS) {
        _getui.startSdk(
          appId: 'xXmjbbab3b5F1m7wAYZoG2',
          appKey: 'BZF4dANEYr8dwLhj6lRfx2',
          appSecret: 'yXRS5zRxDt8WhMW8DD8W05',
        );
        await getSdkVersion();
      } else {
        // Android/HarmonyOS 初始化 SDK
        _getui.initGetuiSdk;
      }
    } on PlatformException catch (e) {
      platformVersion = '获取平台版本失败: ${e.message}';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _notificationState = notificationState;
    });

    // 设置事件监听
    _getui.addEventHandler(
      onReceiveClientId: (String message) async {
        print('收到客户端 ID: $message');
        setState(() {
          _getClientId = message;
        });
      },
      onReceiveOnlineState: (String online) async {
        print('在线状态: $online');
      },
      onReceivePayload: (Map<String, dynamic> message) async {
        print('收到 Payload: $message');
        setState(() {
          _onReceivePayload = message.toString();
        });
      },
      onSetTagResult: (Map<String, dynamic> message) async {
        print('设置标签结果: $message');
      },
      onAliasResult: (Map<String, dynamic> message) async {
        print('别名操作结果: $message');
      },
      onQueryTagResult: (Map<String, dynamic> message) async {
        print('查询标签结果: $message');
      },
      onRegisterDeviceToken: (String message) async {
        print('注册设备令牌: $message');
        setState(() {
          _getDeviceToken = message;
        });
      },
      // Android 和 HarmonyOS 专用
      onNotificationMessageArrived: (Map<String, dynamic> msg) async {
        print('通知到达: $msg');
        setState(() {
          _notificationState = '已到达';
        });
      },
      onNotificationMessageClicked: (Map<String, dynamic> msg) async {
        print('通知被点击: $msg');
        setState(() {
          _notificationState = '已点击';
        });
      },
      // iOS 专用
      onTransmitUserMessageReceive: (Map<String, dynamic> msg) async {
        print('收到用户消息: $msg');
        setState(() {
          _userMsg = msg['msg']?.toString() ?? '';
        });
      },
      onReceiveNotificationResponse: (Map<String, dynamic> message) async {
        print('收到通知响应: $message');
        setState(() {
          _onReceiveNotificationResponse = message.toString();
        });
      },
      onAppLinkPayload: (String message) async {
        print('收到 AppLink Payload: $message');
        setState(() {
          _onAppLinkPayLoad = message;
        });
      },
      onPushModeResult: (Map<String, dynamic> message) async {
        print('推送模式结果: $message');
      },
      onWillPresentNotification: (Map<String, dynamic> message) async {
        print('即将显示通知: $message');
      },
      onOpenSettingsForNotification: (Map<String, dynamic> message) async {
        print('打开通知设置: $message');
      },
      onGrantAuthorization: (String granted) async {
        print('授权状态: $granted');
      },
      onLiveActivityResult: (Map<String, dynamic> message) async {
        print('灵动岛结果: $message');
      },
      onRegisterPushToStartTokenResult: (Map<String, dynamic> message) async {
        print('注册推送启动令牌结果: $message');
      },
    );
  }

  // 获取 SDK 版本
  Future<void> getSdkVersion() async {
    try {
      final ver = await _getui.sdkVersion;
      print('SDK 版本: $ver');
    } catch (e) {
      print('获取 SDK 版本失败: $e');
    }
  }

  // 获取启动通知
  Future<void> getLaunchNotification() async {
    try {
      final info = await _getui.getLaunchNotification;
      print('启动通知: $info');
    } catch (e) {
      print('获取启动通知失败: $e');
    }
  }

  // 获取本地启动通知
  Future<void> getLaunchLocalNotification() async {
    try {
      final info = await _getui.getLaunchLocalNotification;
      print('本地启动通知: $info');
    } catch (e) {
      print('获取本地启动通知失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('个推插件示例应用'),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text('平台版本: $_platformVersion\n'),
                  Text('客户端 ID: $_getClientId\n'),
                  Text(
                    '公共功能',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20.0,
                    ),
                  ),
                  Text('用户消息: $_userMsg\n'),
                  Text('Payload: $_onReceivePayload'),
                  Text('通知状态: $_notificationState\n'),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            if (Platform.isIOS) {
                              _getui.startSdk(
                                appId: 'xXmjbbab3b5F1m7wAYZoG2',
                                appKey: 'BZF4dANEYr8dwLhj6lRfx2',
                                appSecret: 'yXRS5zRxDt8WhMW8DD8W05',
                              );
                            } else {
                              _getui.initGetuiSdk;
                            }
                          },
                          child: const Text('初始化 SDK'),
                        ),
                        ElevatedButton(
                          onPressed: Platform.isAndroid
                              ? () {
                            _getui.onActivityCreate();
                          }
                              : null,
                          child: const Text('onActivityCreate'),
                        ),
                      ]
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _getui.getClientId.then((value) {
                            print('客户端 ID: $value');
                            setState(() {
                              _getClientId = value;
                            });
                          });
                        },
                        child: const Text('获取客户端 ID'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _getui.turnOffPush();
                        },
                        child: const Text('关闭推送'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _getui.turnOnPush();
                        },
                        child: const Text('开启推送'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _getui.bindAlias('test', 'test');
                        },
                        child: const Text('绑定别名'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _getui.unbindAlias('test', 'test', true);
                        },
                        child: const Text('解绑别名'),
                      ),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _getui.setBadge(5);
                        },
                        child: const Text('设置角标'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          List<String> tags = ['abc'];
                          _getui.setTag(tags, "唯一标识");
                        },
                        child: const Text('设置标签'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _getui.queryTag("唯一标识");
                        },
                        child: const Text('查询标签'),
                      ),
                    ],
                  ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _getui.setSilentTime(13,0);
                      },
                      child: const Text('设置静默时间(非IOS)'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _getui.sendFeedbackMessage("taskId","messageId", 90002 );
                      },
                      child: const Text('自定义数据回执'),
                    )
                  ]
              ),

                  Text(
                    'iOS 专用功能',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 20.0,
                    ),
                  ),
                  Text('设备令牌: $_getDeviceToken'),
                  Text('AppLink Payload: $_onAppLinkPayLoad'),
                  Text('APNs 通知: $_onReceiveNotificationResponse'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: getLaunchNotification,
                        child: const Text('获取启动通知'),
                      ),
                      ElevatedButton(
                        onPressed: getLaunchLocalNotification,
                        child: const Text('获取本地启动通知'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: Platform.isIOS?() {
                          _getui.setBadge(5);
                        }:null,
                        child: const Text('设置角标'),
                      ),
                      ElevatedButton(
                        onPressed: Platform.isIOS
                            ? () {
                                _getui.setLocalBadge(5);
                              }
                            : null,
                        child: const Text('设置本地角标(5)'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: Platform.isIOS
                            ? () {
                                _getui.resetBadge();
                              }
                            : null,
                        child: const Text('重置角标'),
                      ),
                      ElevatedButton(
                        onPressed: Platform.isIOS
                            ? () {
                                _getui.setPushMode(0);
                              }
                            : null,
                        child: const Text('设置推送模式(0)'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: Platform.isIOS
                            ? () {
                                _getui.startSdkSimple(
                                  appId: 'xXmjbbab3b5F1m7wAYZoG2',
                                  appKey: 'BZF4dANEYr8dwLhj6lRfx2',
                                  appSecret: 'yXRS5zRxDt8WhMW8DD8W05',
                                );
                              }
                            : null,
                        child: const Text('仅启动 SDK'),
                      ),
                      ElevatedButton(
                        onPressed: Platform.isIOS
                            ? () {
                                _getui.registerRemoteNotification();
                              }
                            : null,
                        child: const Text('注册通知权限'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: Platform.isIOS
                            ? () {
                                _getui.registerDeviceToken(_getDeviceToken);
                              }
                            : null,
                        child: const Text('注册设备令牌'),
                      ),
                      ElevatedButton(
                        onPressed: !Platform.isAndroid
                            ? () {
                                _getui.runBackgroundEnable(1);
                              }
                            : null,
                        child: const Text('启用后台模式'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: Platform.isIOS
                            ? () {
                                _getui.registerActivityToken(
                                    'aid_01', _getDeviceToken, 'sn_01');
                              }
                            : null,
                        child: const Text('注册灵动岛令牌'),
                      ),
                      ElevatedButton(
                        onPressed: Platform.isIOS
                            ? () {
                                _getui.registerPushToStartToken(
                                    'attribute1', 'faketoken', 'attribute1_sn');
                              }
                            : null,
                        child: const Text('注册推送启动令牌'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
