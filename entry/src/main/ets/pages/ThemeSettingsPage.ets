/**
 * 主题设置页面
 * 设置应用的主题（浅色/深色）
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { StorageUtils, toast } from '@tbs/common';

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
  private pathStack: NavPathStack = new NavPathStack()
  private themeOptions: ThemeOption[] = [
    { name: '浅色模式', value: 'light', description: '适合白天使用，保护视力' },
    { name: '深色模式', value: 'dark', description: '适合夜间使用，减少眼睛疲劳' },
    { name: '跟随系统', value: 'auto', description: '自动跟随系统主题设置' }
  ]

  aboutToAppear(): void {
    this.loadTheme();
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
    this.currentTheme = theme;
    StorageUtils.saveValueSync('app_theme', theme);
    toast('主题已切换为' + this.getThemeName(theme));

    // 实际应用中，这里应该触发主题切换逻辑
    // 例如：通知全局状态管理器更新主题
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

  build() {
    NavDestination() {
      Column() {
        // 主题选项列表
        Column({ space: 0 }) {
          ForEach(this.themeOptions, (option: ThemeOption, index: number) => {
            this.ThemeOptionItem(option, index === this.themeOptions.length - 1)
          })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        // 提示信息
        Text('注意：深色模式和跟随系统功能暂未完全实现，敬请期待')
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')
          .padding({ left: 24, right: 24, top: 16 })
          .textAlign(TextAlign.Center)

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('主题设置')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }

  @Builder
  ThemeOptionItem(option: ThemeOption, isLast: boolean) {
    Column({ space: 0 }) {
      Row() {
        Column({ space: 4 }) {
          Text(option.name)
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)

          Text(option.description)
            .fontSize(13)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 选中标记
        if (this.currentTheme === option.value) {
          Text('✓')
            .fontSize(20)
            .fontColor('#007AFF')
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
          .color('#E0E0E0')
          .margin({ left: 16, right: 16 })
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
}
