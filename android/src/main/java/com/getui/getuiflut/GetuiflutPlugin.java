package com.getui.getuiflut;

import android.content.Context;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.os.Handler;


import com.igexin.sdk.PushManager;
import com.igexin.sdk.Tag;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
  private static final int FLUTTER_CALL_BACK_CID = 1;
  private static final int FLUTTER_CALL_BACK_MSG =2;

  private Context fContext;

  enum MessageType {
    Default,
    onReceiveMessageData,
    onNotificationMessageArrived,
    onNotificationMessageClicked
  }

  enum StateType {
    Default,
    onReceiveClientId,
    onReceiveOnlineState
  }

  private final Registrar registrar;
  private final MethodChannel channel;

  public static GetuiflutPlugin instance;

  public final Map<Integer, Result> callbackMap;

  private static Handler flutterHandler = new Handler(Looper.getMainLooper()) {
    @Override
    public void handleMessage(Message msg) {
      switch (msg.what) {
        case FLUTTER_CALL_BACK_CID:
          if (msg.arg1 == StateType.onReceiveClientId.ordinal()) {
            GetuiflutPlugin.instance.channel.invokeMethod("onReceiveClientId", msg.obj);
            Log.d("flutterHandler", "onReceiveClientId >>> "+msg.obj);

          } else if (msg.arg1 == StateType.onReceiveOnlineState.ordinal()) {
            GetuiflutPlugin.instance.channel.invokeMethod("onReceiveOnlineState", msg.obj);
            Log.d("flutterHandler", "onReceiveOnlineState >>> "+msg.obj);
          } else  {
            Log.d(TAG,"default state type...");
          }
          break;
        case  FLUTTER_CALL_BACK_MSG:
          if (msg.arg1 == MessageType.onReceiveMessageData.ordinal()) {
            GetuiflutPlugin.instance.channel.invokeMethod("onReceiveMessageData", msg.obj);
            Log.d("flutterHandler", "onReceiveMessageData >>> "+msg.obj);

          } else if (msg.arg1 == MessageType.onNotificationMessageArrived.ordinal()) {
            GetuiflutPlugin.instance.channel.invokeMethod("onNotificationMessageArrived", msg.obj);
            Log.d("flutterHandler", "onNotificationMessageArrived >>> "+msg.obj);

          } else if (msg.arg1 == MessageType.onNotificationMessageClicked.ordinal()) {
            GetuiflutPlugin.instance.channel.invokeMethod("onNotificationMessageClicked", msg.obj);
            Log.d("flutterHandler", "onNotificationMessageClicked >>> "+msg.obj);
          } else {
            Log.d(TAG, "default Message type...");
          }
          break;

          default:
            break;
      }

    }
  };


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
      initGtSdk();
    } else if (call.method.equals("getClientId")) {
      result.success(getClientId());
    } else if (call.method.equals("resume")) {
      resume();
    } else if (call.method.equals("stopPush")) {
      stopPush();
    } else if (call.method.equals("bindAlias"))  {
      Log.d(TAG, "bindAlias:"+call.argument("alias").toString());
      bindAlias(call.argument("alias").toString(),"");
    } else if (call.method.equals("unbindAlias")) {
      Log.d(TAG, "unbindAlias:" + call.argument("alias").toString());
      unbindAlias(call.argument("alias").toString(),"");
    } else if (call.method.equals("setTag")){
      Log.d(TAG,"tags:" + (ArrayList<String>) call.argument("tags"));
      setTag((ArrayList<String>) call.argument("tags"));
    } else if (call.method.equals("onActivityCreate")) {
      Log.d(TAG,"do onActivityCreate");
      onActivityCreate();
    } else {
      result.notImplemented();
    }
  }

  private void initGtSdk() {
    Log.d(TAG, "init getui sdk...test");
    fContext = registrar.context();
    PushManager.getInstance().initialize(registrar.context(), FlutterPushService.class);
    PushManager.getInstance().registerPushIntentService(registrar.context(), FlutterIntentService.class);
  }

  private void onActivityCreate() {
    try {
      Method method = PushManager.class.getDeclaredMethod("registerPushActivity", Context.class, Class.class);
      method.setAccessible(true);
      method.invoke(PushManager.getInstance(), registrar.context(), GetuiPluginActivity.class);
    } catch (Throwable e) {
      e.printStackTrace();
    }
  }

  private String getClientId() {
    Log.d(TAG, "get client id");
    return PushManager.getInstance().getClientid(registrar.context());
  }

  private void resume() {
    Log.d(TAG, "resume push service");
    PushManager.getInstance().turnOnPush(registrar.context());
  }

  private void stopPush() {
    Log.d(TAG, "stop push service");
    PushManager.getInstance().stopService(registrar.context());
  }

  /**
   * 绑定别名功能:后台可以根据别名进行推送
   *
   * @param alias 别名字符串
   * @param aSn   绑定序列码, Android中无效，仅在iOS有效
   */
  public void bindAlias(String alias, String aSn){
    PushManager.getInstance().bindAlias(registrar.context(), alias);
  }

  /**
   *  取消绑定别名功能
   *
   *  @param alias 别名字符串
   *  @param aSn   绑定序列码, Android中无效，仅在iOS有效
   */
  public void unbindAlias(String alias, String aSn){
    PushManager.getInstance().unBindAlias(registrar.context(), alias, false);
  }

  /**
   *  给用户打标签 , 后台可以根据标签进行推送
   *
   *  @param tags 别名数组
   */
  public void setTag(List<String> tags){
    if (tags == null || tags.size() == 0){
      return;
    }

    Tag[] tagArray = new Tag[tags.size()];
    for (int i = 0; i < tags.size(); i++ ){
      Tag tag = new Tag();
      tag.setName(tags.get(i));
      tagArray[i] = tag;
    }

    PushManager.getInstance().setTag(registrar.context(), tagArray, "setTag");
  }

  static void transmitMessageReceive(String message, String func) {
    if (instance == null) {
      Log.d(TAG, "Getui flutter plugin doesn't exist");
      return;
    }
    int type;
    if (func.equals("onReceiveClientId")){
      type = StateType.onReceiveClientId.ordinal();
    } else if (func.equals("onReceiveOnlineState")) {
      type = StateType.onReceiveOnlineState.ordinal();
    } else {
      type = StateType.Default.ordinal();
    }
    Message msg = Message.obtain();
    msg.what = FLUTTER_CALL_BACK_CID;
    msg.arg1 = type;
    msg.obj = message;
    flutterHandler.sendMessage(msg);
  }

  static void transmitMessageReceive(Map<String, Object> message, String func) {
    if (instance == null) {
      Log.d(TAG, "Getui flutter plugin doesn't exist");
      return;
    }
    int type;
    if (func.equals("onReceiveMessageData")) {
      type = MessageType.onReceiveMessageData.ordinal();
    } else if (func.equals("onNotificationMessageArrived")){
      type = MessageType.onNotificationMessageArrived.ordinal();
    } else if (func.equals("onNotificationMessageClicked")) {
      type = MessageType.onNotificationMessageClicked.ordinal();
    }  else {
      type = MessageType.Default.ordinal();
    }
    Message msg = Message.obtain();
    msg.what = FLUTTER_CALL_BACK_MSG;
    msg.arg1 = type;
    msg.obj = message;
    flutterHandler.sendMessage(msg);
  }
}
