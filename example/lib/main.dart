import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';


import 'package:flutter/services.dart';
import 'package:getuiflut/getuiflut.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() =>new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _payloadInfo = 'Null';
  String _notificationState = "";
  String _getClientId = "";
  String _getDeviceToken="";
  String _getVoipToken="";
  String _onReceivePayload="";
  String _onReceiveNotificationResponse="";
  String _onAppLinkPayLoad="";
  String _onReceiveVoipPayLoad;
  //final Getuiflut getui = new Getuiflut();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    String payloadInfo="default";
    String notificationState="default";
    // Platform messages may fail, so we use a try/catch PlatformException.


    if (Platform.isIOS) {
      Getuiflut().startSdk(
          appId: "iMahVVxurw6BNr7XSn9EF2",
          appKey: "yIPfqwq6OMAPp6dkqgLpG5",
          appSecret: "G0aBqAD6t79JfzTB6Z5lo5"
      );
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

    Getuiflut().addEventHandler(
      onReceiveClientId: (String message) async {
        print("flutter onReceiveClientId: $message");
        setState(() {
          _getClientId = "ClientId: $message";
        });
      },
      onReceiveMessageData: (Map<String, dynamic> msg) async {
        print("flutter onReceiveMessageData: $msg");
        setState(() {
          _payloadInfo = msg['payload'];
        });
      },
      onNotificationMessageArrived: (Map<String, dynamic> msg) async {
        print("flutter onNotificationMessageArrived");
        setState(() {
          _notificationState = 'Arrived';
        });
      },
      onNotificationMessageClicked: (Map<String, dynamic> msg) async {
        print("flutter onNotificationMessageClicked");
        setState(() {
          _notificationState = 'Clicked';
        });
      },
      onRegisterDeviceToken: (String message) async {
        setState(() {
          _getDeviceToken = "$message";
        });
      },
      onReceivePayload: (Map<String, dynamic> message) async {
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
    );
  }

  Future<void> initGetuiSdk() async {
    try {
      Getuiflut.initGetuiSdk;
    } catch(e) {
      e.toString();
    }
  }

  Future<void> getClientId() async {
    String getClientId;
    try {
      getClientId = await Getuiflut.getClientId;
      print(getClientId);
    } catch(e) {
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
        body: Center(
          child: Column(
              children:<Widget>[
                Text('platformVersion: $_platformVersion\n'),
                Text('clientId: $_getClientId\n'),
                Text(
                    'Android Public Funcation',
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 20.0,
                    ),
                ),
                Text('payload: $_payloadInfo\n'),
                Text('notificaiton state: $_notificationState\n'),
                RaisedButton(
                  onPressed: () {initGetuiSdk();},
                  child: const Text('initGetuiSdk'),
                ),
                RaisedButton(
                  onPressed: () {getClientId();},
                  child: const Text('getClientId11111111'),
                ),
                RaisedButton(
                  onPressed: () {Getuiflut().stopPush();},
                  child: const Text('stop push'),
                ),
                RaisedButton(
                  onPressed: () {Getuiflut().resumePush();},
                  child: const Text('resume push'),
                ),
                RaisedButton(
                  onPressed: () {Getuiflut().bindAlias('test', '');},
                  child: const Text('bindAlias test'),
                ),
                RaisedButton(
                  onPressed: () {Getuiflut().unbindAlias('test', '', true);},
                  child: const Text('unbindAlias test'),
                ),
                RaisedButton(
                  onPressed: () {
                    List test = new List();
                    test.add('abc');
                    Getuiflut().setTag(test);},
                  child: const Text('setTag test'),
                ),
                Text(
                    'ios Public Funcation',
                    style: TextStyle(color: Colors.redAccent, fontSize: 20.0,),
                ),
                Text('DeviceToken: $_getDeviceToken'),
                Text('VoipToken: $_getVoipToken'),
                Text('payload: $_onReceivePayload'),
                Text('onReceiveNotificationResponse: $_onReceiveNotificationResponse'),
                Text('onAppLinkPayload: $_onAppLinkPayLoad'),
                Text('onReceiveVoipPayLoad: $_onReceiveVoipPayLoad'),
              ]
          ),
        ),
      ),
    );
  }
}
