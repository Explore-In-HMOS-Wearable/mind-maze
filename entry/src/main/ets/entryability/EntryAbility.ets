import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN: number = 0x1100;
const TAG: string = 'MindMaze';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext()
      .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);

    let wantStr: string = '';
    let launchStr: string = '';

    try {
      wantStr = JSON.stringify(want);
    } catch (e) {
      hilog.warn(DOMAIN, TAG, 'onCreate: want stringify failed %{public}s', String(e));
    }

    try {
      launchStr = JSON.stringify(launchParam);
    } catch (e) {
      hilog.warn(DOMAIN, TAG, 'onCreate: launchParam stringify failed %{public}s', String(e));
    }

    hilog.info(DOMAIN, TAG, 'onCreate want=%{public}s launch=%{public}s', wantStr, launchStr);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err?: Error): void => {
      if (err) {
        let errStr: string = '';
        try {
          errStr = JSON.stringify(err);
        } catch {
          errStr = String(err);
        }
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', errStr);
        return;
      }
      hilog.info(DOMAIN, TAG, 'loadContent success');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'onBackground');
  }
}