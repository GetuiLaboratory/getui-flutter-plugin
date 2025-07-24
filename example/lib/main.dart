import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:getuiflut/getuiflut.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _payloadInfo = 'Null';
  String _userMsg = "";
  String _notificationState = "";
  String _getClientId = "";
  String _getDeviceToken = "";
  String _onReceivePayload = "";
  String _onReceiveNotificationResponse = "";
  String _onAppLinkPayLoad = "";

  // 已废弃
  // String _getVoipToken = "";
  // String _onReceiveVoipPayLoad;
  //final Getuiflut getui = new Getuiflut();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    String payloadInfo = "default";
    String notificationState = "default";
    // Platform messages may fail, so we use a try/catch PlatformException.

    if (Platform.isIOS) {
      getSdkVersion();
      Getuiflut().startSdk(
          appId: "xXmjbbab3b5F1m7wAYZoG2",
          appKey: "BZF4dANEYr8dwLhj6lRfx2",
          appSecret: "yXRS5zRxDt8WhMW8DD8W05");
    }

    try {
      platformVersion = await Getuiflut.platformVersion;

      print('platformVersion' + platformVersion);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _payloadInfo = payloadInfo;
      _notificationState = notificationState;
    });

    Getuiflut().addEventHandler(onReceiveClientId: (String message) async {
      print("flutter onReceiveClientId: $message");
      setState(() {
        _getClientId = "$message";
      });
    }, onReceiveMessageData: (Map<String, dynamic> msg) async {
      print("flutter onReceiveMessageData: $msg");
      setState(() {
        _payloadInfo = msg['payload'];
      });
    }, onNotificationMessageArrived: (Map<String, dynamic> msg) async {
      print("flutter onNotificationMessageArrived: $msg");
      setState(() {
        _notificationState = 'Arrived';
      });
    }, onNotificationMessageClicked: (Map<String, dynamic> msg) async {
      print("flutter onNotificationMessageClicked: $msg");
      setState(() {
        _notificationState = 'Clicked';
      });
    }, onTransmitUserMessageReceive: (Map<String, dynamic> msg) async {
      print("flutter onTransmitUserMessageReceive:$msg");
      setState(() {
        _userMsg = msg["msg"];
      });
    }, onRegisterDeviceToken: (String message) async {
      print("flutter onRegisterDeviceToken: $message");
      setState(() {
        _getDeviceToken = "$message";
      });
    }, onReceivePayload: (Map<String, dynamic> message) async {
      print("flutter onReceivePayload: $message");
      setState(() {
        _onReceivePayload = "$message";
      });
    }, onReceiveNotificationResponse: (Map<String, dynamic> message) async {
      print("flutter onReceiveNotificationResponse: $message");
      setState(() {
        _onReceiveNotificationResponse = "$message";
      });
    }, onAppLinkPayload: (String message) async {
      print("flutter onAppLinkPayload: $message");
      setState(() {
        _onAppLinkPayLoad = "$message";
      });
    }, onPushModeResult: (Map<String, dynamic> message) async {
      print("flutter onPushModeResult: $message");
    }, onSetTagResult: (Map<String, dynamic> message) async {
      print("flutter onSetTagResult: $message");
    }, onAliasResult: (Map<String, dynamic> message) async {
      print("flutter onAliasResult: $message");
    }, onQueryTagResult: (Map<String, dynamic> message) async {
      print("flutter onQueryTagResult: $message");
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
    }, onReceiveOnlineState: (bool online) async {
      print("flutter onReceiveOnlineState: $online");
    });
  }

  Future<void> initGetuiSdk() async {
    try {
      Getuiflut.initGetuiSdk;
    } catch (e) {
      e.toString();
    }
  }

  Future<void> getClientId() async {
    String getClientId;
    try {
      getClientId = await Getuiflut.getClientId;
      print(getClientId);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getSdkVersion() async {
    String ver;
    try {
      ver = await Getuiflut.sdkVersion;
      print(ver);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getLaunchNotification() async {
    Map info;
    try {
      info = await Getuiflut.getLaunchNotification;
      print("getLaunchNotification:$info");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getLaunchOptions() async {
    Map info;
    try {
      info = await Getuiflut.getLaunchOptions;
      print("getLaunchOptions:$info");
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: ListView(
            children: <Widget>[
              Container(
                // height: 200,
                alignment: Alignment.center,

                child: Column(
                  children: <Widget>[
                    Text('platformVersion: $_platformVersion\n'),
                    Text('clientId: $_getClientId\n'),
                    Text(
                      'Android Public Function',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 20.0,
                      ),
                    ),
                    Text('userMsg: $_userMsg\n'),
                    Text('payload: $_payloadInfo\n'),
                    Text('notificaiton state: $_notificationState\n'),
                    ElevatedButton(
                      onPressed: () {
                        initGetuiSdk();
                      },
                      child: const Text('initGetuiSdk'),
                    ),
                    Text(
                      'SDK Public Function',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 20.0,
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              if (Platform.isIOS) {
                                Getuiflut().onActivityCreate();
                              }
                            },
                            child: const Text('onActivityCreate'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Getuiflut().setBadge(5);
                            },
                            child: const Text('setBadge'),
                          ),
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            getClientId();
                          },
                          child: const Text('getClientId'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Getuiflut().turnOffPush();
                          },
                          child: const Text('stop push'),
                        ),
                        // RaisedButton(
                        //   onPressed: () {
                        //     Getuiflut().turnOnPush();
                        //   },
                        //   child: const Text('resume push'),
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Getuiflut().bindAlias('test', 'test');
                          },
                          child: const Text('bindAlias'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Getuiflut().unbindAlias('test', 'test', true);
                          },
                          child: const Text('unbindAlias'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            List test = List.filled(1, 'abc');
                            Getuiflut().setTag(test);
                          },
                          child: const Text('setTag'),
                        ),
                      ],
                    ),

                    Text(
                      'iOS Public Function',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 20.0,
                      ),
                    ),
                    Text('DeviceToken: $_getDeviceToken'),
                    Text('onAppLinkPayload: $_onAppLinkPayLoad'),
                    Text('Payload: $_onReceivePayload'),
                    Text('APNs: $_onReceiveNotificationResponse'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            getLaunchNotification();
                          },
                          child: const Text('getLaunchNotification'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getLaunchOptions();
                          },
                          child: const Text('getLaunchOptions'),
                        ),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Getuiflut().setBadge(5);
                            },
                            child: const Text('setBadge'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Getuiflut().setLocalBadge(0);
                            },
                            child: const Text('setLocalBadge(0)'),
                          ),
                        ]),
                    // 已废弃
                    // Text('VoipToken: $_getVoipToken'),
                    // Text('onReceiveVoipPayLoad: $_onReceiveVoipPayLoad'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Getuiflut().resetBadge();
                          },
                          child: const Text('resetBadge'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Getuiflut().setPushMode(0);
                          },
                          child: const Text('setPushMode(0)'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Getuiflut().startSdkSimple(
                                appId: "xXmjbbab3b5F1m7wAYZoG2",
                                appKey: "BZF4dANEYr8dwLhj6lRfx2",
                                appSecret: "yXRS5zRxDt8WhMW8DD8W05");
                          },
                          child: const Text('startSimple(仅启动sdk)'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //需要先启动sdk
                            Getuiflut().registerRemoteNotification();
                          },
                          child: const Text('注册通知权限'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            //开发者需自行获取token
                            String token = _getDeviceToken;
                            Getuiflut().registerDeviceToken(token);
                          },
                          child: const Text('registerDeviceToken'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Getuiflut().runBackgroundEnable(1);
                          },
                          child: const Text('runBackgroundEnable'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            //开发者需自行获取token
                            String token =
                                "8048e0825f0034231ce2f638743584f47fb4fd49b5a6ad2a8a91b154966997465e6292780ff648edfea69168cb5c0df55bdc1da919c7b423053f127dbc79b9520366c95bbc40d6c8c9b1f9f4d4c1e452";
                            Getuiflut().registerActivityToken(
                                'aid_01', token, 'sn_01');
                          },
                          child: const Text('registerActivityToken'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //开发者需自行获取token
                            Getuiflut().registerPushToStartToken(
                                "attribute1", "faketoken", "attribute1_sn");
                          },
                          child: const Text('registerPushToStartToken'),
                        ),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[]),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
