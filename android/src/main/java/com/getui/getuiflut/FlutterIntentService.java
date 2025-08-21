package com.getui.getuiflut;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.igexin.sdk.GTIntentService;
import com.igexin.sdk.PushConsts;
import com.igexin.sdk.message.BindAliasCmdMessage;
import com.igexin.sdk.message.GTCmdMessage;
import com.igexin.sdk.message.GTNotificationMessage;
import com.igexin.sdk.message.GTTransmitMessage;
import com.igexin.sdk.message.QueryTagCmdMessage;
import com.igexin.sdk.message.SetTagCmdMessage;
import com.igexin.sdk.message.UnBindAliasCmdMessage;

/**
 * 推送服务处理类，继承自 GTIntentService，处理推送相关事件
 */
public class FlutterIntentService extends GTIntentService {
    private static final String TAG = "FlutterIntentService";
    private static final Gson GSON = new Gson();

    @Override
    public void onCreate() {
        super.onCreate();
        log("Service created");
    }

    @Override
    public void onReceiveServicePid(Context context, int pid) {
        log("Received service PID: " + pid);
    }

    @Override
    public void onReceiveClientId(Context context, String clientId) {
        log("Received client ID: " + clientId);
        GetuiflutPlugin.transmitMessageReceive(clientId, GetuiflutPlugin.StateType.onReceiveClientId);
    }

    @Override
    public void onReceiveMessageData(Context context, GTTransmitMessage msg) {
        log("Received message data");
        JsonObject result = JsonParser.parseString(GSON.toJson(msg)).getAsJsonObject();
        result.addProperty("payload", new String(msg.getPayload()));
        GetuiflutPlugin.transmitMessageReceive(GSON.toJson(result), GetuiflutPlugin.StateType.onReceivePayload);
    }

    @Override
    public void onReceiveOnlineState(Context context, boolean online) {
        log("Received online state: " + online);
        GetuiflutPlugin.transmitMessageReceive(String.valueOf(online), GetuiflutPlugin.StateType.onReceiveOnlineState);
    }

    @Override
    public void onReceiveCommandResult(Context context, GTCmdMessage cmdMessage) {
        log("Received command result: " + cmdMessage.getClass().getSimpleName());
        int action = cmdMessage.getAction();
        JsonObject result = JsonParser.parseString(GSON.toJson(cmdMessage)).getAsJsonObject();
        GetuiflutPlugin.StateType stateType;

        switch (action) {
            case PushConsts.SET_TAG_RESULT:
                SetTagCmdMessage setTagCmd = (SetTagCmdMessage) cmdMessage;
                result.addProperty("message", getResources().getString(getMessageResIdForTag(setTagCmd.getCode())));
                result.addProperty("result", Integer.parseInt(setTagCmd.getCode()) == 0);
                stateType = GetuiflutPlugin.StateType.onSetTagResult;
                break;
            case PushConsts.BIND_ALIAS_RESULT:
                BindAliasCmdMessage bindCmd = (BindAliasCmdMessage) cmdMessage;
                result.addProperty("message", getResources().getString(getMessageResIdForAlias(bindCmd.getCode(), true)));
                result.addProperty("result", Integer.parseInt(bindCmd.getCode()) == 0);
                stateType = GetuiflutPlugin.StateType.onAliasResult;
                break;
            case PushConsts.UNBIND_ALIAS_RESULT:
                UnBindAliasCmdMessage unbindCmd = (UnBindAliasCmdMessage) cmdMessage;
                result.addProperty("message", getResources().getString(getMessageResIdForAlias(unbindCmd.getCode(), false)));
                result.addProperty("result", Integer.parseInt(unbindCmd.getCode()) == 0);
                stateType = GetuiflutPlugin.StateType.onAliasResult;
                break;
            case PushConsts.QUERY_TAG_RESULT:
                result.addProperty("result", Integer.parseInt(((QueryTagCmdMessage) cmdMessage).getCode()) == 0);
                stateType = GetuiflutPlugin.StateType.onQueryTagResult;
                break;
            case PushConsts.THIRDPART_FEEDBACK:
                stateType = GetuiflutPlugin.StateType.thirdPartFeedback;
                break;
            default:
                log("Unhandled command result action: " + action);
                return;
        }

        GetuiflutPlugin.transmitMessageReceive(GSON.toJson(result), stateType);
    }

    @Override
    public void onNotificationMessageArrived(Context context, GTNotificationMessage message) {
        log("Notification arrived");
        GetuiflutPlugin.transmitMessageReceive(GSON.toJson(message), GetuiflutPlugin.StateType.onNotificationMessageArrived);
    }

    @Override
    public void onNotificationMessageClicked(Context context, GTNotificationMessage message) {
        log("Notification clicked");
        GetuiflutPlugin.transmitMessageReceive(GSON.toJson(message), GetuiflutPlugin.StateType.onNotificationMessageClicked);
    }

    // 统一日志记录方法
    private void log(String message) {
        Log.d(TAG, message);
    }

    // 获取设置标签的提示信息资源 ID
    private int getMessageResIdForTag(String code) {
        switch (Integer.parseInt(code)) {
            case PushConsts.SETTAG_SUCCESS: return R.string.add_tag_success;
            case PushConsts.SETTAG_ERROR_COUNT: return R.string.add_tag_error_count;
            case PushConsts.SETTAG_ERROR_FREQUENCY: return R.string.add_tag_error_frequency;
            case PushConsts.SETTAG_ERROR_REPEAT: return R.string.add_tag_error_repeat;
            case PushConsts.SETTAG_ERROR_UNBIND: return R.string.add_tag_error_unbind;
            case PushConsts.SETTAG_ERROR_EXCEPTION: return R.string.add_tag_unknown_exception;
            case PushConsts.SETTAG_ERROR_NULL: return R.string.add_tag_error_null;
            case PushConsts.SETTAG_NOTONLINE: return R.string.add_tag_error_not_online;
            case PushConsts.SETTAG_IN_BLACKLIST: return R.string.add_tag_error_black_list;
            case PushConsts.SETTAG_NUM_EXCEED: return R.string.add_tag_error_exceed;
            case PushConsts.SETTAG_TAG_ILLEGAL: return R.string.add_tag_error_tagIllegal;
            default: return R.string.add_tag_unknown_exception;
        }
    }

    // 获取别名操作的提示信息资源 ID
    private int getMessageResIdForAlias(String code, boolean isBind) {
        int baseResId = isBind ? R.string.bind_alias_unknown_exception : R.string.unbind_alias_unknown_exception;
        switch (Integer.parseInt(code)) {
            case PushConsts.BIND_ALIAS_SUCCESS: return isBind ? R.string.bind_alias_success : R.string.unbind_alias_success;
            case PushConsts.ALIAS_ERROR_FREQUENCY: return isBind ? R.string.bind_alias_error_frequency : R.string.unbind_alias_error_frequency;
            case PushConsts.ALIAS_OPERATE_PARAM_ERROR: return isBind ? R.string.bind_alias_error_param_error : R.string.unbind_alias_error_param_error;
            case PushConsts.ALIAS_REQUEST_FILTER: return isBind ? R.string.bind_alias_error_request_filter : R.string.unbind_alias_error_request_filter;
            case PushConsts.ALIAS_OPERATE_ALIAS_FAILED: return baseResId;
            case PushConsts.ALIAS_CID_LOST: return isBind ? R.string.bind_alias_error_cid_lost : R.string.unbind_alias_error_cid_lost;
            case PushConsts.ALIAS_CONNECT_LOST: return isBind ? R.string.bind_alias_error_connect_lost : R.string.unbind_alias_error_connect_lost;
            case PushConsts.ALIAS_INVALID: return isBind ? R.string.bind_alias_error_alias_invalid : R.string.unbind_alias_error_alias_invalid;
            case PushConsts.ALIAS_SN_INVALID: return isBind ? R.string.bind_alias_error_sn_invalid : R.string.unbind_alias_error_sn_invalid;
            default: return baseResId;
        }
    }
}