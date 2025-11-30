import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { GlobalContext, initDataPreference, StorageUtils } from '@tbs/common';

const DOMAIN: number = 0x0000;
const TAG: string = 'FitEasy';

/**
 * FitEasy 应用入口 Ability
 */
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化全局上下文
    GlobalContext.getContext().setObject('context', this.context);

    // 初始化数据存储
    initDataPreference();

    // 初始化主题设置
    this.initColorMode();

    // 保存当前颜色模式到 AppStorage
    AppStorage.setOrCreate<number>('currentColorMode', this.context.config.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);

    hilog.info(DOMAIN, TAG, 'Ability onCreate - Storage initialized');
  }

  /**
   * 初始化颜色模式
   */
  private initColorMode(): void {
    // 读取保存的主题设置
    const savedTheme: string = StorageUtils.getStringValueSync('app_theme', 'auto');

    if (savedTheme === 'light') {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      hilog.info(DOMAIN, TAG, 'Set color mode to LIGHT');
    } else if (savedTheme === 'dark') {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      hilog.info(DOMAIN, TAG, 'Set color mode to DARK');
    } else {
      // auto - 跟随系统
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      hilog.info(DOMAIN, TAG, 'Set color mode to AUTO (follow system)');
    }
  }

  /**
   * 监听配置变化（包括深浅色模式切换）
   */
  onConfigurationUpdate(newConfig: Configuration): void {
    // 更新 AppStorage 中的颜色模式
    AppStorage.setOrCreate<number>('currentColorMode', newConfig.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    hilog.info(DOMAIN, TAG, 'Color mode changed to: %{public}d', newConfig.colorMode ?? 0);

    // 更新状态栏颜色
    this.updateStatusBarStyle(newConfig.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }

  /**
   * 更新状态栏样式
   */
  private updateStatusBarStyle(colorMode: number): void {
    try {
      const windowStage: window.WindowStage | undefined = GlobalContext.getContext().getObject('windowStage') as window.WindowStage | undefined;
      if (windowStage !== undefined) {
        const mainWindow: window.Window = windowStage.getMainWindowSync();
        const isDark: boolean = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;

        mainWindow.setWindowSystemBarProperties({
          statusBarColor: '#00000000',
          navigationBarColor: '#00000000',
          statusBarContentColor: isDark ? '#FFFFFF' : '#000000'
        });

        hilog.info(DOMAIN, TAG, 'Updated status bar style for %{public}s mode', isDark ? 'dark' : 'light');
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to update status bar style: %{public}s', JSON.stringify(err));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');

    // 保存 windowStage 引用到全局上下文
    GlobalContext.getContext().setObject('windowStage', windowStage);

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

      // 5. 根据当前颜色模式设置状态栏和导航栏透明
      const currentColorMode: number = this.context.config.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      const isDark: boolean = currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;

      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        statusBarContentColor: isDark ? '#FFFFFF' : '#000000'
      });

      mainWindow.setWindowTouchable(true);

      hilog.info(DOMAIN, TAG, 'Set immersive window successfully');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set immersive window. Cause: %{public}s', JSON.stringify(err));
    }
  }
}
