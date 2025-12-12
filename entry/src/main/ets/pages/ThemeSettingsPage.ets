/**
 * 主题设置页面
 * 设置应用的主题（浅色/深色/跟随系统）
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { StorageUtils, toast, GlobalContext } from '@tbs/common';
import { ConfigurationConstant, common } from '@kit.AbilityKit';

/**
 * 系统路由表构建函数
 */
@Builder
export function ThemeSettingsPageBuilder(): void {
  ThemeSettingsPage()
}

@Component
export struct ThemeSettingsPage {
  @State currentTheme: string = 'auto'
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentColorMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
  private pathStack: NavPathStack = new NavPathStack()
  private themeOptions: ThemeOption[] = [
    { name: '浅色模式', value: 'light', description: '明亮清爽，适合白天使用', icon: '☀️' },
    { name: '深色模式', value: 'dark', description: '舒适护眼，适合夜间使用', icon: '🌙' },
  ]

  aboutToAppear(): void {
    this.loadTheme();
  }

  /**
   * 颜色模式变化回调
   */
  onColorModeChange(): void {
    // 触发 UI 刷新
  }

  /**
   * 加载主题设置
   */
  loadTheme(): void {
    this.currentTheme = StorageUtils.getStringValueSync('app_theme', 'auto');
  }

  /**
   * 保存主题设置
   */
  saveTheme(theme: string): void {
    this.currentTheme = theme;
    StorageUtils.saveValueSync('app_theme', theme);

    // 应用主题切换
    this.applyTheme(theme);

    toast('主题已切换为' + this.getThemeName(theme));
  }

  /**
   * 应用主题切换
   */
  applyTheme(theme: string): void {
    try {
      const context: common.UIAbilityContext = GlobalContext.getContext().getObject('context') as common.UIAbilityContext;
      if (context !== undefined) {
        if (theme === 'light') {
          context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        } else if (theme === 'dark') {
          context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        } else {
          // auto - 跟随系统
          context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
        }
      }
    } catch (err) {
      console.error('应用主题切换失败:', JSON.stringify(err));
    }
  }

  /**
   * 获取主题名称
   */
  getThemeName(theme: string): string {
    for (let i: number = 0; i < this.themeOptions.length; i++) {
      if (this.themeOptions[i].value === theme) {
        return this.themeOptions[i].name;
      }
    }
    return '浅色模式';
  }

  /**
   * 判断当前是否为深色模式
   */
  isDarkMode(): boolean {
    return this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  build() {
    NavDestination() {
      Column() {
        // 自定义标题栏
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([$r('app.color.text_primary')])
            .onClick(() => {
              this.pathStack.pop();
            })

          Text('主题设置')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          // 占位，保持标题居中
          Column().width(24)
        }
        .width('100%')
        .height(70)
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topRectHeight) })
        .backgroundColor($r('app.color.card_background'))

        // 主题预览卡片
        Column({ space: 16 }) {
          Text('当前预览')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))

          Row({ space: 16 }) {
            // 浅色预览
            Column({ space: 8 }) {
              Column()
                .width(80)
                .height(60)
                .backgroundColor('#F7F8FA')
                .borderRadius(8)
                .border({ width: this.currentTheme === 'light' || (this.currentTheme === 'auto' && !this.isDarkMode()) ? 2 : 1,
                  color: this.currentTheme === 'light' || (this.currentTheme === 'auto' && !this.isDarkMode()) ? $r('app.color.brand_primary') : $r('app.color.outline') })
              Text('浅色')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }

            // 深色预览
            Column({ space: 8 }) {
              Column()
                .width(80)
                .height(60)
                .backgroundColor('#1A1A1A')
                .borderRadius(8)
                .border({ width: this.currentTheme === 'dark' || (this.currentTheme === 'auto' && this.isDarkMode()) ? 2 : 1,
                  color: this.currentTheme === 'dark' || (this.currentTheme === 'auto' && this.isDarkMode()) ? $r('app.color.brand_primary') : $r('app.color.outline') })
              Text('深色')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
          }
        }
        .width('100%')
        .padding(20)
        .margin({ left: 16, right: 16, top: 16 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)

        // 主题选项列表
        Column({ space: 0 }) {
          ForEach(this.themeOptions, (option: ThemeOption, index: number) => {
            this.ThemeOptionItem(option, index === this.themeOptions.length - 1)
          })
        }
        .width('100%')
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        // 提示信息
        Text('切换主题后会立即生效，所有页面的配色将同步更新。')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
          .width('100%')
          .padding({ left: 24, right: 24, top: 16 })
          .textAlign(TextAlign.Center)

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }

  @Builder
  ThemeOptionItem(option: ThemeOption, isLast: boolean) {
    Column({ space: 0 }) {
      Row() {
        // 图标
        Text(option.icon)
          .fontSize(24)
          .width(40)

        // 文字内容
        Column({ space: 4 }) {
          Text(option.name)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Medium)

          Text(option.description)
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 选中标记
        if (this.currentTheme === option.value) {
          Text('✓')
            .fontSize(20)
            .fontColor($r('app.color.brand_primary'))
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('100%')
      .height(72)
      .padding({ left: 16, right: 16 })
      .onClick((): void => {
        this.saveTheme(option.value);
      })

      if (!isLast) {
        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.outline'))
          .margin({ left: 56, right: 16 })
      }
    }
  }
}

/**
 * 主题选项类型
 */
class ThemeOption {
  name: string = ''
  value: string = ''
  description: string = ''
  icon: string = ''
}
