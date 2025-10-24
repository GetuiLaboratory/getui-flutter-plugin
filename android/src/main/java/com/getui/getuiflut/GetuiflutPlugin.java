package com.getui.getuiflut;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import com.google.gson.Gson;
import com.igexin.sdk.PushManager;
import com.igexin.sdk.Tag;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Flutter 插件类，用于与个推推送服务交互
 */
public class GetuiflutPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "GetuiflutPlugin";
    private static final String CHANNEL_NAME = "getuiflut";
    private static final int FLUTTER_CALL_BACK = 1;
    private static final int FLUTTER_CALL_BACK_USER = 2;

    /**
     * 状态类型枚举
     */
    enum StateType {
        Default,
        onReceiveClientId,
        onReceiveOnlineState,
        onReceivePayload,
        onNotificationMessageArrived,
        onNotificationMessageClicked,
        onSetTagResult,
        onAliasResult,
        onQueryTagResult,
        thirdPartFeedback
    }

    private MethodChannel channel;
    private Context context;
    public static GetuiflutPlugin instance;

    public GetuiflutPlugin() {
        Log.d(TAG, "Plugin initialized");
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);

        Log.d(TAG, "Attached to Flutter engine");
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        Log.d(TAG, "Detached from Flutter engine");
    }

    /**
     * 处理 Flutter 端调用
     */
    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.d(TAG, "Method call: " + call.method + ", arguments: " + (call.arguments == null ? "none" : call.arguments));
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "initGetuiPush":
                initGtSdk();
                result.success(null);
                break;
            case "getClientId":
                result.success(getClientId());
                break;
            case "resume":
                resume();
                result.success(null);
                break;
            case "stopPush":
                stopPush();
                result.success(null);
                break;
            case "bindAlias":
                bindAlias(call.argument("alias"), call.argument("aSn"));
                result.success(null);
                break;
            case "unbindAlias":
                unbindAlias(call.argument("alias"), call.argument("aSn"), Boolean.TRUE.equals(call.argument("isSelf")));
                result.success(null);
                break;
            case "setTag":
                setTag(call.argument("tags"), call.argument("sn"));
                result.success(null);
                break;
            case "queryTag":
                PushManager.getInstance().queryTag(context, call.argument("sn"));
                result.success(null);
                break;
            case "onActivityCreate":
                onActivityCreate();
                result.success(null);
                break;
            case "setBadge":
                setBadge(call.argument("badge"));
                result.success(null);
                break;
            case "registerDeviceToken":
                PushManager.getInstance().setDeviceToken(context, call.argument("token"));
                result.success(null);
                break;
            case "setSilentTime":
                PushManager.getInstance().setSilentTime(context, call.argument("beginHour"), call.argument("duration"));
                result.success(null);
                break;
            case "sendFeedbackMessage":
                PushManager.getInstance().sendFeedbackMessage(context, call.argument("taskId"), call.argument("messageId"), call.argument("actionId"));
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * 初始化个推 SDK
     */
    private void initGtSdk() {
        instance =  this;
        try {
             Log.d(TAG, "Initializing Getui SDK "+PushManager.getInstance().getVersion(context));
        } catch (Throwable e) {

        }
        try {
            PushManager.getInstance().initialize(context);
        } catch (Throwable e) {
            Log.e(TAG, "Initialization failed, setting privacy policy", e);
            try {
                Method setPrivacyPolicyStrategy = PushManager.class.getDeclaredMethod("setPrivacyPolicyStrategy", Context.class, boolean.class);
                setPrivacyPolicyStrategy.invoke(PushManager.getInstance(), context, true);
            } catch (Throwable ex) {
                throw new RuntimeException("Failed to set privacy policy", ex);
            }
            PushManager.getInstance().registerPushIntentService(context, FlutterIntentService.class);
            PushManager.getInstance().initialize(context, FlutterPushService.class);
        }
    }

    /**
     * 注册推送 Activity
     */
    private void onActivityCreate() {
        try {
            Method method = PushManager.class.getDeclaredMethod("registerPushActivity", Context.class, Class.class);
            method.setAccessible(true);
            method.invoke(PushManager.getInstance(), context, GetuiPluginActivity.class);
            Log.d(TAG, "Push activity registered");
        } catch (Throwable e) {
            Log.e(TAG, "Failed to register push activity", e);
        }
    }

    /**
     * 设置应用角标
     */
    private void setBadge(int badgeNum) {
        try {
            Method method = PushManager.class.getDeclaredMethod("setBadgeNum", Context.class, int.class);
            method.setAccessible(true);
            method.invoke(PushManager.getInstance(), context, badgeNum);
            Log.d(TAG, "Badge set to: " + badgeNum);
        } catch (Throwable e) {
            Log.e(TAG, "Failed to set badge", e);
        }
    }

    /**
     * 获取客户端 ID
     */
    private String getClientId() {
        String clientId = PushManager.getInstance().getClientid(context);
        Log.d(TAG, "Client ID: " + clientId);
        return clientId;
    }

    /**
     * 恢复推送服务
     */
    private void resume() {
        PushManager.getInstance().turnOnPush(context);
        Log.d(TAG, "Push service resumed");
    }

    /**
     * 停止推送服务
     */
    private void stopPush() {
        PushManager.getInstance().turnOffPush(context);
        Log.d(TAG, "Push service stopped");
    }

    /**
     * 绑定别名
     */
    private void bindAlias(String alias, String sn) {
        PushManager.getInstance().bindAlias(context, alias,sn);
        Log.d(TAG, "Binding alias: " + alias + ", sn: " + sn);
    }

    /**
     * 解绑别名
     */
    private void unbindAlias(String alias, String sn, boolean isSelf) {
        PushManager.getInstance().unBindAlias(context, alias, isSelf, sn);
        Log.d(TAG, "Unbinding alias: " + alias + ", sn: " + sn + ", isSelf: " + isSelf);
    }

    /**
     * 设置标签
     */
    private void setTag(List<String> tags, String sn) {
        if (tags == null || tags.isEmpty()) {
            Log.d(TAG, "No tags provided");
            return;
        }

        Tag[] tagArray = new Tag[tags.size()];
        for (int i = 0; i < tags.size(); i++) {
            Tag tag = new Tag();
            tag.setName(tags.get(i));
            tagArray[i] = tag;
        }
        PushManager.getInstance().setTag(context, tagArray, sn);
        Log.d(TAG, "Tags set: " + tags + ", sn: " + sn);
    }

    /**
     * 处理消息回调的 Handler
     */
    private static final Handler flutterHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case FLUTTER_CALL_BACK:
                    StateType type = StateType.values()[msg.arg1];
                    instance.channel.invokeMethod(type.name(), msg.obj);
                    Log.d(TAG, type.name() + ": " + msg.obj);
                    break;
                case FLUTTER_CALL_BACK_USER:
                    instance.channel.invokeMethod("onTransmitUserMessageReceive", msg.obj);
                    Log.d(TAG, "User message: " + msg.obj);
                    break;
                default:
                    Log.d(TAG, "Unknown message type: " + msg.what);
                    break;
            }
        }
    };

    /**
     * 传输消息到 Flutter
     */
    static void transmitMessageReceive(String message, StateType type) {
        if (instance == null) {
            Log.d(TAG, "Plugin instance is null");
            return;
        }
        Message msg = Message.obtain();
        msg.what = FLUTTER_CALL_BACK;
        msg.arg1 = type.ordinal();
        msg.obj = message;
        flutterHandler.sendMessage(msg);
    }

    /**
     * 传输用户消息到 Flutter
     */
   public static void transmitUserMessage(Map<String, Object> message) {
       if (instance == null) {
           Log.d(TAG, "Plugin instance is null");
           return;
       }
        Message msg = Message.obtain();
        msg.what = FLUTTER_CALL_BACK_USER;
        msg.obj = new Gson().toJson(message);
        flutterHandler.sendMessage(msg);
    }
}