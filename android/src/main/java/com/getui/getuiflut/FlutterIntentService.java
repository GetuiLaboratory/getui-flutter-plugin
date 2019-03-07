package com.getui.getuiflut;

import android.content.Context;
import android.util.Log;

import com.igexin.sdk.GTIntentService;
import com.igexin.sdk.message.GTCmdMessage;
import com.igexin.sdk.message.GTNotificationMessage;
import com.igexin.sdk.message.GTTransmitMessage;

import java.util.HashMap;
import java.util.Map;

public class FlutterIntentService extends GTIntentService {

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
        GetuiflutPlugin.transmitMessageReceive(payload, "onReceiveMessageData");
    }

    @Override
    public void onReceiveOnlineState(Context context, boolean b) {
        GetuiflutPlugin.transmitMessageReceive(String.valueOf(b), "onReceiveOnlineState");
    }

    @Override
    public void onReceiveCommandResult(Context context, GTCmdMessage gtCmdMessage) {
        GetuiflutPlugin.transmitMessageReceive(gtCmdMessage.toString(), "onReceiveCommandResult");
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
