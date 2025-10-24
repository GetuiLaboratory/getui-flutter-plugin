package com.getui.getuiflut;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.igexin.sdk.GTIntentService;
import com.igexin.sdk.PushConsts;
import com.igexin.sdk.Tag;
import com.igexin.sdk.message.BindAliasCmdMessage;
import com.igexin.sdk.message.FeedbackCmdMessage;
import com.igexin.sdk.message.GTCmdMessage;
import com.igexin.sdk.message.GTNotificationMessage;
import com.igexin.sdk.message.GTTransmitMessage;
import com.igexin.sdk.message.QueryTagCmdMessage;
import com.igexin.sdk.message.SetTagCmdMessage;
import com.igexin.sdk.message.UnBindAliasCmdMessage;

import java.util.HashMap;
import java.util.Map;

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
        Map<String, Object> payload = new HashMap<>();
        payload.put("messageId", msg.getMessageId());
        payload.put("payload", new String(msg.getPayload()));
        payload.put("payloadId", msg.getPayloadId());
        payload.put("taskId", msg.getTaskId());
        GetuiflutPlugin.transmitMessageReceive(GSON.toJson(payload), GetuiflutPlugin.StateType.onReceivePayload);
    }

    @Override
    public void onReceiveOnlineState(Context context, boolean online) {
        log("Received online state: " + online);
        GetuiflutPlugin.transmitMessageReceive(String.valueOf(online), GetuiflutPlugin.StateType.onReceiveOnlineState);
    }

    @Override
    public void onReceiveCommandResult(Context context, GTCmdMessage gtCmdMessage) {
        int action = gtCmdMessage.getAction();
        if (action == PushConsts.SET_TAG_RESULT) {
            GetuiflutPlugin.transmitMessageReceive(getTagResult((SetTagCmdMessage) gtCmdMessage), GetuiflutPlugin.StateType.onSetTagResult);
        } else if (action == PushConsts.BIND_ALIAS_RESULT) {
            GetuiflutPlugin.transmitMessageReceive(bindAliasResult((BindAliasCmdMessage) gtCmdMessage),GetuiflutPlugin.StateType.onAliasResult);
        } else if (action == PushConsts.UNBIND_ALIAS_RESULT) {
            GetuiflutPlugin.transmitMessageReceive(unBindAliasResult((UnBindAliasCmdMessage) gtCmdMessage),GetuiflutPlugin.StateType.onAliasResult);
        } else if ((action == PushConsts.THIRDPART_FEEDBACK)) {
            GetuiflutPlugin.transmitMessageReceive(feedbackResult((FeedbackCmdMessage) gtCmdMessage),GetuiflutPlugin.StateType.thirdPartFeedback);
        }else if(action == PushConsts.QUERY_TAG_RESULT){
            GetuiflutPlugin.transmitMessageReceive(onQueryTagResult((QueryTagCmdMessage) gtCmdMessage), GetuiflutPlugin.StateType.onQueryTagResult);
        }


    }

    private String onQueryTagResult(QueryTagCmdMessage gtCmdMessage) {
        String code = gtCmdMessage.getCode();
        String sn = gtCmdMessage.getSn();
        Tag[] tags = gtCmdMessage.getTags();
        HashMap<String, Object> map = new HashMap<>();
        map.put("sn",sn);
        map.put("result",Integer.parseInt(code)==0);
        map.put("code",Integer.parseInt(code));
        map.put("tags",tags);
        return GSON.toJson(map);
    }

    private String feedbackResult(FeedbackCmdMessage feedbackCmdMsg) {
        String appid = feedbackCmdMsg.getAppid();
        String taskid = feedbackCmdMsg.getTaskId();
        String actionid = feedbackCmdMsg.getActionId();
        String result = feedbackCmdMsg.getResult();
        long timestamp = feedbackCmdMsg.getTimeStamp();
        String cid = feedbackCmdMsg.getClientId();

        HashMap<String, Object> map = new HashMap<>();
        map.put("appid",appid);
        map.put("taskid",taskid);
        map.put("actionid",actionid);
        map.put("result",result);
        map.put("timestamp",timestamp);
        map.put("cid",cid);
        return GSON.toJson(map);
    }

    private String unBindAliasResult(UnBindAliasCmdMessage gtCmdMessage) {
        String sn = gtCmdMessage.getSn();
        String code = gtCmdMessage.getCode();

        int text = R.string.unbind_alias_unknown_exception;
        switch (Integer.parseInt(code)) {
            case PushConsts.UNBIND_ALIAS_SUCCESS:
                text = R.string.unbind_alias_success;
                break;
            case PushConsts.ALIAS_ERROR_FREQUENCY:
                text = R.string.unbind_alias_error_frequency;
                break;
            case PushConsts.ALIAS_OPERATE_PARAM_ERROR:
                text = R.string.unbind_alias_error_param_error;
                break;
            case PushConsts.ALIAS_REQUEST_FILTER:
                text = R.string.unbind_alias_error_request_filter;
                break;
            case PushConsts.ALIAS_OPERATE_ALIAS_FAILED:
                text = R.string.unbind_alias_unknown_exception;
                break;
            case PushConsts.ALIAS_CID_LOST:
                text = R.string.unbind_alias_error_cid_lost;
                break;
            case PushConsts.ALIAS_CONNECT_LOST:
                text = R.string.unbind_alias_error_connect_lost;
                break;
            case PushConsts.ALIAS_INVALID:
                text = R.string.unbind_alias_error_alias_invalid;
                break;
            case PushConsts.ALIAS_SN_INVALID:
                text = R.string.unbind_alias_error_sn_invalid;
                break;
            default:
                break;

        }
        HashMap<String, Object> map = new HashMap<>();
        map.put("sn",sn);
        map.put("result",Integer.parseInt(code)==0);
        map.put("code",Integer.parseInt(code));
        map.put("message",getResources().getString(text));
        return GSON.toJson(map);
    }

    private String bindAliasResult(BindAliasCmdMessage gtCmdMessage) {
        String sn = gtCmdMessage.getSn();
        String code = gtCmdMessage.getCode();

        int text = R.string.bind_alias_unknown_exception;
        switch (Integer.parseInt(code)) {
            case PushConsts.BIND_ALIAS_SUCCESS:
                text = R.string.bind_alias_success;
                break;
            case PushConsts.ALIAS_ERROR_FREQUENCY:
                text = R.string.bind_alias_error_frequency;
                break;
            case PushConsts.ALIAS_OPERATE_PARAM_ERROR:
                text = R.string.bind_alias_error_param_error;
                break;
            case PushConsts.ALIAS_REQUEST_FILTER:
                text = R.string.bind_alias_error_request_filter;
                break;
            case PushConsts.ALIAS_OPERATE_ALIAS_FAILED:
                text = R.string.bind_alias_unknown_exception;
                break;
            case PushConsts.ALIAS_CID_LOST:
                text = R.string.bind_alias_error_cid_lost;
                break;
            case PushConsts.ALIAS_CONNECT_LOST:
                text = R.string.bind_alias_error_connect_lost;
                break;
            case PushConsts.ALIAS_INVALID:
                text = R.string.bind_alias_error_alias_invalid;
                break;
            case PushConsts.ALIAS_SN_INVALID:
                text = R.string.bind_alias_error_sn_invalid;
                break;
            default:
                break;

        }
        HashMap<String, Object> map = new HashMap<>();
        map.put("sn",sn);
        map.put("result",Integer.parseInt(code)==0);
        map.put("code",Integer.parseInt(code));
        map.put("message",getResources().getString(text));
        return GSON.toJson(map);
    }

    private String getTagResult(SetTagCmdMessage gtCmdMessage) {
        String sn = gtCmdMessage.getSn();
        String code = gtCmdMessage.getCode();
        int text = R.string.add_tag_unknown_exception;
        switch (Integer.parseInt(code)) {
            case PushConsts.SETTAG_SUCCESS:
                text = R.string.add_tag_success;
                break;
            case PushConsts.SETTAG_ERROR_COUNT:
                text = R.string.add_tag_error_count;
                break;
            case PushConsts.SETTAG_ERROR_FREQUENCY:
                text = R.string.add_tag_error_frequency;
                break;
            case PushConsts.SETTAG_ERROR_REPEAT:
                text = R.string.add_tag_error_repeat;
                break;
            case PushConsts.SETTAG_ERROR_UNBIND:
                text = R.string.add_tag_error_unbind;
                break;
            case PushConsts.SETTAG_ERROR_EXCEPTION:
                text = R.string.add_tag_unknown_exception;
                break;
            case PushConsts.SETTAG_ERROR_NULL:
                text = R.string.add_tag_error_null;
                break;
            case PushConsts.SETTAG_NOTONLINE:
                text = R.string.add_tag_error_not_online;
                break;
            case PushConsts.SETTAG_IN_BLACKLIST:
                text = R.string.add_tag_error_black_list;
                break;
            case PushConsts.SETTAG_NUM_EXCEED:
                text = R.string.add_tag_error_exceed;
                break;
            case PushConsts.SETTAG_TAG_ILLEGAL:
                text = R.string.add_tag_error_tagIllegal;
                break;
            default:
                break;
        }

        HashMap<String, Object> map = new HashMap<>();
        map.put("sn",sn);
        map.put("result",Integer.parseInt(code)==0);
        map.put("code",Integer.parseInt(code));
        map.put("message",getResources().getString(text));
        return GSON.toJson(map);
    }

    @Override
    public void onNotificationMessageArrived(Context context, GTNotificationMessage message) {
        log("Notification arrived");
        Map<String, Object> notification = new HashMap<String, Object>();
        notification.put("messageId",message.getMessageId());
        notification.put("taskId",message.getTaskId());
        notification.put("title",message.getTitle());
        notification.put("content",message.getContent());
        GetuiflutPlugin.transmitMessageReceive(GSON.toJson(notification), GetuiflutPlugin.StateType.onNotificationMessageArrived);
    }

    @Override
    public void onNotificationMessageClicked(Context context, GTNotificationMessage message) {
        log("Notification clicked");
        Map<String, Object> notification = new HashMap<String, Object>();
        notification.put("messageId",message.getMessageId());
        notification.put("taskId",message.getTaskId());
        notification.put("title",message.getTitle());
        notification.put("content",message.getContent());
        GetuiflutPlugin.transmitMessageReceive(GSON.toJson(notification), GetuiflutPlugin.StateType.onNotificationMessageClicked);
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