import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { GlobalContext, initDataPreference } from '@tbs/common';

const DOMAIN: number = 0x0000;
const TAG: string = 'FitEasy';

/**
 * FitEasy 应用入口 Ability
 */
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 设置颜色模式
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);

    // 初始化全局上下文
    GlobalContext.getContext().setObject('context', this.context);

    // 初始化数据存储
    initDataPreference();

    hilog.info(DOMAIN, TAG, 'Ability onCreate - Storage initialized');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');

    // 设置沉浸式窗口
    this.setMainWindowImmersive(windowStage);

    // 直接加载主页面
    windowStage.loadContent('home/HomePage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }

  /**
   * 设置沉浸式状态栏
   */
  private setMainWindowImmersive(windowStage: window.WindowStage): void {
    try {
      const mainWindow: window.Window = windowStage.getMainWindowSync();

      // 设置窗口全屏
      mainWindow.setWindowLayoutFullScreen(true);

      // 设置状态栏和导航栏透明
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        statusBarContentColor: '#000000'
      });

      mainWindow.setWindowTouchable(true)

      hilog.info(DOMAIN, TAG, 'Set immersive window successfully');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set immersive window. Cause: %{public}s', JSON.stringify(err));
    }
  }
}