import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:getuiflut/getuiflut.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _payloadInfo = 'Null';
  String _notificationState = "";

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
    try {
      platformVersion = await Getuiflut.platformVersion;
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
          _platformVersion = "flutter onReceiveClientId: $message";
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
    );
  }

  Future<void> initGetuiSdk() async {
    try {
      Getuiflut.initGetuiSdk;
    } catch(e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
              children:<Widget>[
                Text('clientId: $_platformVersion\n'),
                Text('payload: $_payloadInfo\n'),
                Text('notificaiton state: $_notificationState\n'),
                RaisedButton(
                  onPressed: () {initGetuiSdk();},
                  child: const Text('Enabled Button'),
                ),
              ]
          ),
        ),
      ),
    );
  }
}
