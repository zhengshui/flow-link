/**
 * 关于页面
 * 显示应用信息、版本号等
 * 使用 NavDestination 作为 Navigation 子页面
 */

/**
 * 系统路由表构建函数
 */
@Builder
export function AboutPageBuilder(): void {
  AboutPage()
}

@Component
export struct AboutPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()
  private appVersion: string = '1.0.0'
  private appName: string = 'FitEasy (健身易)'
  private appDescription: string = '让健身更简单，记录每一次进步'
  private features: string[] = [
    '训练记录管理',
    '健身计划制定',
    '数据统计分析',
    '个性化设置'
  ]

  build() {
    NavDestination() {
      // 内容区域
      Scroll() {
        Column({ space: 24 }) {
          // 应用图标和名称
          Column({ space: 12 }) {
            // 应用图标 (使用文字代替实际图标)
            Column() {
              Text('FE')
                .fontSize(48)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .width(100)
            .height(100)
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .margin({ top: 40 })

            Text(this.appName)
              .fontSize(24)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)

            Text('v' + this.appVersion)
              .fontSize(16)
              .fontColor($r('app.color.text_hint'))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

          // 应用描述
          Text(this.appDescription)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .width('80%')
            .margin({ left: '10%' })

          // 核心功能
          Column({ space: 12 }) {
            Text('核心功能')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .padding({ left: 16 })

            Column({ space: 0 }) {
              ForEach(this.features, (feature: string, index: number) => {
                this.FeatureItem(feature, index === this.features.length - 1)
              })
            }
            .width('100%')
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(12)
            .margin({ left: 16, right: 16 })
          }
          .width('100%')
          .margin({ top: 16 })

          // 项目信息
          Column({ space: 0 }) {
            this.InfoItem('开发者', 'FitEasy Team')
            this.ItemDivider()
            this.InfoItem('发布日期', '2025-11-03')
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 版权信息
          Column({ space: 8 }) {
            Text('© 2025 FitEasy')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))

            Text('让健身成为一种生活方式')
              .fontSize(12)
              .fontColor($r('app.color.text_placeholder'))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 24, bottom: 40 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.page_background'))
    }
    .title('关于')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }

  @Builder
  FeatureItem(feature: string, isLast: boolean) {
    Column({ space: 0 }) {
      Row() {
        Text('•')
          .fontSize(16)
          .fontColor($r('app.color.brand_primary'))
          .margin({ right: 8 })

        Text(feature)
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      if (!isLast) {
        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.outline'))
          .margin({ left: 16, right: 16 })
      }
    }
  }

  @Builder
  InfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor($r('app.color.text_secondary'))

      Blank()

      Text(value)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  ItemDivider() {
    Divider()
      .strokeWidth(0.5)
      .color($r('app.color.outline'))
      .margin({ left: 16, right: 16 })
  }
}
