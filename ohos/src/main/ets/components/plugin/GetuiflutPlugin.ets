import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  FlutterManager
} from '@ohos/flutter_ohos';
import { BusinessError } from '@ohos.base';
import notificationManager from '@ohos.notificationManager';
import hilog from '@ohos.hilog';
import PushManager, { GTTransmitMessage, GTCmdMessage, Tag, GTNotificationMessage, PushConst } from "@getui/push"
import common from '@ohos.app.ability.common';
import { ArrayList } from '@kit.ArkTS';
import Want from '@ohos.app.ability.Want';


let TAG = "ohos_getuiflut"

/** FlutterHarmonyPlugin **/
export default class GetuiflutPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private binding: FlutterPluginBinding | null = null;
  private context: common.UIAbilityContext | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "getuiflut"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "getuiflut");
    this.channel.setMethodCallHandler(this)
    this.binding = binding
    // this.context =  binding.getApplicationContext() as  common.UIAbilityContext
    this.context = FlutterManager.getInstance().getUIAbility()?.context as common.UIAbilityContext

  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  static setClickWant(want: Want) {
    PushManager.setClickWant(want)
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    hilog.debug(0x0000, TAG, '%{public}s', "method = " + call.method + "  argument = " + JSON.stringify(call.args));
    if (call.method == "getPlatformVersion") {
      result.success("OpenHarmony ^ ^ ")
    } else if (call.method == "initGetuiPush") {
      this.initSDK();
    } else if (call.method == "getClientId") {
      result.success(PushManager.getClientId());
    } else if (call.method == "sdkVersion") {
      result.success(PushManager.getSDKVersion());
    } else if (call.method == "resume") {
      PushManager.turnOnPush()
    } else if (call.method == "stopPush") {
      PushManager.turnOffPush()
    } else if (call.method == "bindAlias") {
      hilog.debug(0x0000, TAG, '%{public}s',
        "bindAlias:" + call.argument("alias").toString() + call.argument("aSn").toString());
      PushManager.bindAlias(call.argument("alias").toString(), call.argument("aSn").toString())
    } else if (call.method == "unbindAlias") {
      hilog.debug(0x0000, TAG, '%{public}s',
        "unbindAlias:" + call.argument("alias").toString() + call.argument("aSn").toString() +
        call.argument("isSelf").toString());
      PushManager.unBindAlias(call.argument("alias").toString(), call.argument("isSelf").toString() === 'true',
        call.argument("aSn").toString())
    } else if (call.method == "setTag") {
      let tags = call.argument("tags") as ArrayList<String>
      const tagArray: Tag[] = [];
      // 将ArrayList中的每个字符串转换为Tag对象
      for (let i = 0; i < tags.length; i++) {
        const tag = new Tag();
        tag.setName(tags[i].toString());
        tagArray.push(tag);
      }
      PushManager.setTag(tagArray, call.argument("sn"))
    } else if (call.method == "queryTag") {
      PushManager.queryTag(TAG)
    } else if (call.method == "onActivityCreate") {
      result.notImplemented()
    } else if (call.method == "setBadge") {
      PushManager.setBadgeNum(call.argument("badge"))
    } else if (call.method == "runBackgroundEnable") {
      //enable 取反
      const  offline = !call.argument("enable") as boolean
      PushManager.setBackgroundOffLine(offline)
    } else if (call.method == "setSilentTime") {
      PushManager.setSilentTime(call.argument("beginHour"), call.argument("duration"))
    } else if (call.method == "sendFeedbackMessage") {
      PushManager.sendFeedbackMessage(call.argument("taskId"), call.argument("messageId"), call.argument("actionId"))
    } else {
      result.notImplemented()
    }
  }

  initSDK() {
    notificationManager.requestEnableNotification().then(() => {
      hilog.debug(0x0000, "notify", '%{public}s', 'requestEnableNotification success');
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, "notify", '%{public}s', "error = " + err.message);
    })

    PushManager.setPushCallback({
      onReceiveClientId: (clientId: string) => {
        hilog.debug(0x0000, TAG, '%{public}s', "clientId = " + clientId);
        this.channel?.invokeMethod("onReceiveClientId", clientId);
      },
      onReceiveDeviceToken: (token: string) => {
        hilog.debug(0x0000, TAG, '%{public}s', "token = " + token);
        this.channel?.invokeMethod("onRegisterDeviceToken", token);
      },
      onReceiveOnlineState: (onLine: boolean) => {
        hilog.debug(0x0000, TAG, '%{public}s', "onLine = " + onLine);
        this.channel?.invokeMethod("onReceiveOnlineState", String(onLine));
      },
      onReceiveCommandResult: (result: GTCmdMessage) => {
        hilog.debug(0x0000, TAG, '%{public}s', "cmd = " + JSON.stringify(result));

        if (result.action == PushConst.SET_TAG_RESULT) {
          this.channel?.invokeMethod("onSetTagResult", JSON.stringify(result))
        } else if (result.action == PushConst.BIND_ALIAS_RESULT) {
          this.channel?.invokeMethod("onAliasResult", JSON.stringify(result))
        } else if (result.action == PushConst.UNBIND_ALIAS_RESULT) {
          this.channel?.invokeMethod("onAliasResult", JSON.stringify(result))
        } else if ((result.action == PushConst.THIRDPART_FEEDBACK)) {
          this.channel?.invokeMethod("thirdPartFeedback", JSON.stringify(result))
        } else if (result.action == PushConst.QUERY_TAG_RESULT) {
          this.channel?.invokeMethod("onQueryTagResult", JSON.stringify(result))
        }
      },
      onReceiveMessageData: (message: GTTransmitMessage) => {
        hilog.debug(0x0000, TAG, '%{public}s', "message = " + JSON.stringify(message));
        this.channel?.invokeMethod("onReceivePayload", JSON.stringify(message));
      },
      onNotificationMessageArrived: (message: GTNotificationMessage) => {
        hilog.debug(0x0000, TAG, '%{public}s', "MessageArrived = " + JSON.stringify(message));
        this.channel?.invokeMethod("onNotificationMessageArrived", JSON.stringify(message));
      },
      onNotificationMessageClicked: (message: GTNotificationMessage) => {
        hilog.debug(0x0000, TAG, '%{public}s', "MessageClicked = " + JSON.stringify(message));
        this.channel?.invokeMethod("onNotificationMessageClicked", JSON.stringify(message));
      }
    })


    if (undefined == this.context) {
      this.context = this.binding?.getApplicationContext() as common.UIAbilityContext
    }
    PushManager.initialize({
      context: this.context,
      onSuccess: (cid: string) => {
        hilog.debug(0x0000, TAG, '%{public}s', "cid = " + cid);
        hilog.info(0x0000, TAG, '%{public}s', "cid = " + cid);
      },
      onFailed: (error: string) => {
        hilog.debug(0x0000, TAG, '%{public}s', "error = " + error);
      }
    })
  }
}

