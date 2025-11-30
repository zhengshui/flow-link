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

    // 直接加载主页面
    windowStage.loadContent('home/HomePage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');

      // 设置沉浸式窗口
      this.setMainWindowImmersive(windowStage);
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

      // 1. 设置窗口全屏布局
      mainWindow.setWindowLayoutFullScreen(true);

      // 2. 获取状态栏避让区域高度
      const systemAvoidArea: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const topRectHeight: number = systemAvoidArea.topRect.height;
      AppStorage.setOrCreate<number>('topRectHeight', topRectHeight);
      hilog.info(DOMAIN, TAG, 'Status bar height: %{public}d', topRectHeight);

      // 3. 获取导航区域避让高度
      const navigationAvoidArea: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      const bottomRectHeight: number = navigationAvoidArea.bottomRect.height;
      AppStorage.setOrCreate<number>('bottomRectHeight', bottomRectHeight);
      hilog.info(DOMAIN, TAG, 'Navigation bar height: %{public}d', bottomRectHeight);

      // 4. 注册监听函数，动态获取避让区域数据
      mainWindow.on('avoidAreaChange', (data: window.AvoidAreaOptions) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          const newTopHeight: number = data.area.topRect.height;
          AppStorage.setOrCreate<number>('topRectHeight', newTopHeight);
          hilog.info(DOMAIN, TAG, 'Status bar height changed: %{public}d', newTopHeight);
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          const newBottomHeight: number = data.area.bottomRect.height;
          AppStorage.setOrCreate<number>('bottomRectHeight', newBottomHeight);
          hilog.info(DOMAIN, TAG, 'Navigation bar height changed: %{public}d', newBottomHeight);
        }
      });

      // 5. 设置状态栏和导航栏透明
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        statusBarContentColor: '#000000'
      });

      mainWindow.setWindowTouchable(true);

      hilog.info(DOMAIN, TAG, 'Set immersive window successfully');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set immersive window. Cause: %{public}s', JSON.stringify(err));
    }
  }
}