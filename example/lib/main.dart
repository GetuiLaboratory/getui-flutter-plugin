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
  String _getClientId = "";

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

  Future<void> getClientId() async {
    String getClientId;
    try {
      getClientId = await Getuiflut.getClientId;
      showAlertDialog(context, getClientId);
    } catch(e) {
      print(e.toString());
    }
  }

  void showAlertDialog(BuildContext context, String content) {
    NavigatorState navigator= context.rootAncestorStateOfType(const TypeMatcher<NavigatorState>());
    debugPrint("navigator is null?"+(navigator==null).toString());


    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
            title: new Text("Dialog Title"),
            content: new Text("This is my content"),
            actions:<Widget>[
              new FlatButton(child:new Text("CANCEL"), onPressed: (){
                Navigator.of(context).pop();

              },),
              new FlatButton(child:new Text("OK"), onPressed: (){
                Navigator.of(context).pop();

              },)
            ]
        ));
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
                Text('getClientid: $_getClientId\n'),
                RaisedButton(
                  onPressed: () {initGetuiSdk();},
                  child: const Text('initGetuiSdk'),
                ),
                RaisedButton(
                  onPressed: () {showAlertDialog(context, "1111");},
                  child: const Text('getClientId'),
                ),
                RaisedButton(
                  onPressed: () {Getuiflut().stopPush();},
                  child: const Text('stop push'),
                ),
                RaisedButton(
                  onPressed: () {Getuiflut().resumePush();},
                  child: const Text('resume push'),
                ),
              ]
          ),
        ),
      ),
    );
  }
}
