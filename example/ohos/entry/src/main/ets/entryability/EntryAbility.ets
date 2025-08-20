
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import GetuiflutPlugin from 'getuiflut';
import { AbilityConstant, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

class JsonUtils {
  static hasGttask(gtdata: object): boolean {
    return gtdata['gttask'] !== undefined;
  }
}

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
      hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onCreate');
      if (want && want.parameters && want.parameters['gtdata']) {
        //注意这里的判断条件，在线点击通知回执和离线报表补全有区别
        if (!JsonUtils.hasGttask(want.parameters['gtdata'])) {

          GetuiflutPlugin.setClickWant(want);
          hilog.info(0x0000, 'EntryAbility', 'onCreate PushManager.setClickWant');
        }
      }
    return super.onCreate(want,launchParam)
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'EntryAbility', 'onNewWant info = ' + JSON.stringify(want));
    if (want && want.parameters && want.parameters['gtdata']) {
      if (!JsonUtils.hasGttask(want.parameters['gtdata'])) {
        GetuiflutPlugin.setClickWant(want);
        hilog.info(0x0000, 'EntryAbility', 'onCreate PushManager.setClickWant');
      }
    }
    return super.onNewWant(want,launchParam)

  }
}

