package com.getui.getuiflut;

import android.util.Log;

import com.igexin.sdk.PushManager;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** GetuiflutPlugin */
public class GetuiflutPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "getuiflut");
    channel.setMethodCallHandler(new GetuiflutPlugin(registrar, channel));
  }

  private static final String TAG = "GetuiflutPlugin";

  private final Registrar registrar;
  private final MethodChannel channel;
  public static GetuiflutPlugin instance;

  public final Map<Integer, Result> callbackMap;


  private GetuiflutPlugin(Registrar registrar, MethodChannel channel) {
    this.channel = channel;
    this.registrar = registrar;
    this.callbackMap = new HashMap<>();
    instance = this;
  }


  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("initGetuiPush")) {
      initGtSdk(call, result);
    } else {
      result.notImplemented();
    }
  }

  private void initGtSdk(MethodCall call, Result result) {
    Log.d(TAG, "init getui sdk...");
    PushManager.getInstance().initialize(registrar.context(), FlutterPushService.class);
    PushManager.getInstance().registerPushIntentService(registrar.context(), FlutterIntentService.class);
  }

}
