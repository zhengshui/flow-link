/**
 * 主题设置页面
 * 设置应用的主题（浅色/深色）
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
  @State currentTheme: string = 'light'
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentColorMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
  private pathStack: NavPathStack = new NavPathStack()

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
    this.currentTheme = StorageUtils.getStringValueSync('app_theme', 'light');
  }

  /**
   * 保存主题设置
   */
  saveTheme(theme: string): void {
    if (this.currentTheme === theme) {
      return;
    }
    this.currentTheme = theme;
    StorageUtils.saveValueSync('app_theme', theme);

    // 应用主题切换
    this.applyTheme(theme);

    toast('已切换为' + this.getThemeName(theme));
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
    if (theme === 'dark') {
      return '深色模式';
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

        // 内容区域
        Scroll() {
          Column({ space: 20 }) {
            // 主题选择卡片
            Column({ space: 16 }) {
              Text('选择外观')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .width('100%')

              // 主题选项
              Row({ space: 16 }) {
                // 浅色模式
                this.ThemeCard('light', '浅色', '#F7F8FA', '#1A1A1A')

                // 深色模式
                this.ThemeCard('dark', '深色', '#1A1A1A', '#FFFFFF')
              }
              .width('100%')
            }
            .width('100%')
            .padding(20)
            .margin({ left: 20, right: 20 })
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(20)
            .alignItems(HorizontalAlign.Start)

            // 当前主题信息卡片
            Column({ space: 0 }) {
              Row() {
                Column({ space: 4 }) {
                  Text('当前主题')
                    .fontSize(14)
                    .fontColor($r('app.color.text_hint'))

                  Text(this.getThemeName(this.currentTheme))
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                // 主题图标
                Column() {
                  SymbolGlyph(this.currentTheme === 'dark' ? $r('sys.symbol.moon_fill') : $r('sys.symbol.sun_max_fill'))
                    .fontSize(28)
                    .fontColor([$r('app.color.brand_primary')])
                }
                .width(56)
                .height(56)
                .backgroundColor($r('app.color.brand_primary_light'))
                .borderRadius(28)
                .justifyContent(FlexAlign.Center)
              }
              .width('100%')
              .padding(20)
            }
            .width('100%')
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(20)
            .margin({ left: 20, right: 20 })

            // 提示说明
            Column({ space: 8 }) {
              Text('说明')
                .fontSize(13)
                .fontColor($r('app.color.text_hint'))
                .width('100%')

              Text('• 切换主题后立即生效')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')

              Text('• 浅色模式适合白天使用')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')

              Text('• 深色模式适合夜间使用，更护眼')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 8 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ top: 20, bottom: 40 })
        }
        .layoutWeight(1)
        .backgroundColor($r('app.color.page_background'))
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
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
  ThemeCard(theme: string, label: string, bgColor: string, textColor: string) {
    Column({ space: 12 }) {
      // 预览区域
      Column({ space: 8 }) {
        // 模拟标题栏
        Row({ space: 6 }) {
          Column()
            .width(8)
            .height(8)
            .backgroundColor(textColor)
            .borderRadius(4)
            .opacity(0.3)
          Column()
            .width(40)
            .height(6)
            .backgroundColor(textColor)
            .borderRadius(3)
            .opacity(0.4)
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 8 })

        // 模拟卡片内容
        Column({ space: 4 }) {
          Column()
            .width('80%')
            .height(6)
            .backgroundColor(textColor)
            .borderRadius(3)
            .opacity(0.3)
          Column()
            .width('60%')
            .height(6)
            .backgroundColor(textColor)
            .borderRadius(3)
            .opacity(0.2)
        }
        .width('100%')
        .padding({ left: 8, right: 8 })
        .alignItems(HorizontalAlign.Start)

        // 模拟按钮
        Row({ space: 6 }) {
          Column()
            .width(32)
            .height(10)
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(5)
          Column()
            .width(32)
            .height(10)
            .backgroundColor(textColor)
            .borderRadius(5)
            .opacity(0.2)
        }
        .width('100%')
        .padding({ left: 8, right: 8, bottom: 8 })
      }
      .width('100%')
      .height(90)
      .backgroundColor(bgColor)
      .borderRadius(12)

      // 标签
      Text(label)
        .fontSize(15)
        .fontWeight(this.currentTheme === theme ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentTheme === theme ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(this.currentTheme === theme ? $r('app.color.brand_primary_light') : $r('app.color.card_background_secondary'))
    .borderRadius(16)
    .border({
      width: this.currentTheme === theme ? 2 : 0,
      color: $r('app.color.brand_primary')
    })
    .onClick((): void => {
      this.saveTheme(theme);
    })
  }
}
