package com.getui.getuiflut;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

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

public class FlutterIntentService extends GTIntentService {
   private String TAG = "intentService";
    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int i, int i1) {
        if (intent != null) {
            processOnHandleIntent(this, intent);
        }
        return START_NOT_STICKY;
    }

    public void processOnHandleIntent(Context context, Intent intent) {
        if (intent == null || context == null) {
            Log.e(TAG, "onHandleIntent() context or intent is null");
            return;
        }

        try {
            Bundle bundle = intent.getExtras();
            if (bundle == null || bundle.get("action") == null || !(bundle.get("action") instanceof Integer)) {
                Log.d(TAG, "onHandleIntent, receive intent error");
                return;
            }

            int action = bundle.getInt(PushConsts.CMD_ACTION);

            Log.d(TAG, "onHandleIntent() action = " + action);

            context = context.getApplicationContext();

            switch (action) {
                case PushConsts.GET_MSG_DATA:
                    onReceiveMessageData(context, (GTTransmitMessage) intent.getSerializableExtra(PushConsts.KEY_MESSAGE_DATA));
                    Log.d(TAG, "onHandleIntent() = received msg data ");
                    break;

                case PushConsts.GET_CLIENTID:
                    onReceiveClientId(context, bundle.getString(PushConsts.KEY_CLIENT_ID));
                    Log.d(TAG, "onHandleIntent() = received client id ");
                    break;

                case PushConsts.GET_DEVICETOKEN:
                    onReceiveDeviceToken(context, bundle.getString(PushConsts.KEY_DEVICE_TOKEN));
                    Log.d(TAG, "onHandleIntent() = received device token ");
                    break;

                case PushConsts.GET_SDKONLINESTATE:
                    onReceiveOnlineState(context, bundle.getBoolean(PushConsts.KEY_ONLINE_STATE));
                    break;

                case PushConsts.GET_SDKSERVICEPID:
                    onReceiveServicePid(context, bundle.getInt(PushConsts.KEY_SERVICE_PIT));
                    Log.d(TAG, "onHandleIntent() = get sdk service pid ");
                    break;

                case PushConsts.KEY_CMD_RESULT:
                    onReceiveCommandResult(context, (GTCmdMessage) intent.getSerializableExtra(PushConsts.KEY_CMD_MSG));
                    Log.d(TAG, "onHandleIntent() = " + intent.getSerializableExtra(PushConsts.KEY_CMD_MSG).getClass().getSimpleName());
                    break;

                case PushConsts.ACTION_NOTIFICATION_ARRIVED:
                    onNotificationMessageArrived(context, (GTNotificationMessage) intent.getSerializableExtra(PushConsts.KEY_NOTIFICATION_ARRIVED));
                    Log.d(TAG, "onHandleIntent() = notification arrived ");
                    break;

                case PushConsts.ACTION_NOTIFICATION_CLICKED:
                    onNotificationMessageClicked(context, (GTNotificationMessage) intent.getSerializableExtra(PushConsts.KEY_NOTIFICATION_CLICKED));
                    Log.d(TAG, "onHandleIntent() notification clicked ");
                    break;

                default:
                    break;
            }
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
        }
    }

    @Override
    public void onReceiveServicePid(Context context, int pid) {
        Log.d(TAG, "onReceiveServicePid -> " + pid);

    }

    @Override
    public void onReceiveClientId(Context context, String clientid) {
        Log.e(TAG, "onReceiveClientId -> " + "clientid = " + clientid);
        GetuiflutPlugin.transmitMessageReceive(clientid, "onReceiveClientId");
    }

    @Override
    public void onReceiveMessageData(Context context, GTTransmitMessage msg) {
        Log.d(TAG, "onReceiveMessageData -> " + "appid = " + msg.getAppid() + "\ntaskid = " + msg.getTaskId() + "\nmessageid = " + msg.getMessageId() + "\npkg = " + msg.getPkgName()
                + "\ncid = " + msg.getClientId() + "\npayload:" + new String(msg.getPayload()));
        Map<String, Object> payload = new HashMap<>();
        payload.put("messageId", msg.getMessageId());
        payload.put("payload", new String(msg.getPayload()));
        payload.put("payloadId", msg.getPayloadId());
        payload.put("taskId", msg.getTaskId());
        GetuiflutPlugin.transmitMessageReceive(payload, "onReceivePayload");
    }

    @Override
    public void onReceiveOnlineState(Context context, boolean b) {
        GetuiflutPlugin.transmitMessageReceive(String.valueOf(b), "onReceiveOnlineState");
    }

    @Override
    public void onReceiveCommandResult(Context context, GTCmdMessage gtCmdMessage) {
        int action = gtCmdMessage.getAction();
        if (action == PushConsts.SET_TAG_RESULT) {
            GetuiflutPlugin.transmitMessageReceive(getTagResult((SetTagCmdMessage) gtCmdMessage), "onSetTagResult");
        } else if (action == PushConsts.BIND_ALIAS_RESULT) {
            GetuiflutPlugin.transmitMessageReceive(bindAliasResult((BindAliasCmdMessage) gtCmdMessage),"onAliasResult");
        } else if (action == PushConsts.UNBIND_ALIAS_RESULT) {
            GetuiflutPlugin.transmitMessageReceive(unBindAliasResult((UnBindAliasCmdMessage) gtCmdMessage),"onAliasResult");
        } else if ((action == PushConsts.THIRDPART_FEEDBACK)) {
            GetuiflutPlugin.transmitMessageReceive(feedbackResult((FeedbackCmdMessage) gtCmdMessage),"thirdPartFeedback");
        }else if(action == PushConsts.QUERY_TAG_RESULT){
            GetuiflutPlugin.transmitMessageReceive(onQueryTagResult((QueryTagCmdMessage) gtCmdMessage), "onQueryTagResult");
        }


    }

    private Map<String, Object> onQueryTagResult(QueryTagCmdMessage gtCmdMessage) {
        String code = gtCmdMessage.getCode();
        String sn = gtCmdMessage.getSn();
        Tag[] tags = gtCmdMessage.getTags();
        HashMap<String, Object> map = new HashMap<>();
        map.put("sn",sn);
        map.put("result",Integer.parseInt(code)==0);
        map.put("code",Integer.parseInt(code));
        map.put("tags",tags);
        return map;
    }

    private Map<String, Object> feedbackResult(FeedbackCmdMessage feedbackCmdMsg) {
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
        return map;
    }

    private Map<String, Object> unBindAliasResult(UnBindAliasCmdMessage gtCmdMessage) {
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
        return map;
    }

    private Map<String, Object> bindAliasResult(BindAliasCmdMessage gtCmdMessage) {
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
        return map;
    }

    private Map<String, Object> getTagResult(SetTagCmdMessage gtCmdMessage) {
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
        return map;
    }

    @Override
    public void onNotificationMessageArrived(Context context, GTNotificationMessage message) {
        Log.d(TAG, "onNotificationMessageArrived -> " + "appid = " + message.getAppid() + "\ntaskid = " + message.getTaskId() + "\nmessageid = "
                + message.getMessageId() + "\npkg = " + message.getPkgName() + "\ncid = " + message.getClientId() + "\ntitle = "
                + message.getTitle() + "\ncontent = " + message.getContent());
        Map<String, Object> notification = new HashMap<String, Object>();
        notification.put("messageId",message.getMessageId());
        notification.put("taskId",message.getTaskId());
        notification.put("title",message.getTitle());
        notification.put("content",message.getContent());
        GetuiflutPlugin.transmitMessageReceive(notification, "onNotificationMessageArrived");
    }

    @Override
    public void onNotificationMessageClicked(Context context, GTNotificationMessage message) {
        Log.d(TAG, "onNotificationMessageClicked -> " + "appid = " + message.getAppid() + "\ntaskid = " + message.getTaskId() + "\nmessageid = "
                + message.getMessageId() + "\npkg = " + message.getPkgName() + "\ncid = " + message.getClientId() + "\ntitle = "
                + message.getTitle() + "\ncontent = " + message.getContent());
        Map<String, Object> notification = new HashMap<String, Object>();
        notification.put("messageId",message.getMessageId());
        notification.put("taskId",message.getTaskId());
        notification.put("title",message.getTitle());
        notification.put("content",message.getContent());
        GetuiflutPlugin.transmitMessageReceive(notification, "onNotificationMessageClicked");
    }
}
