/**
 * 关于页面
 * 显示应用信息、版本号等
 */

import { TbsTitleBar } from '@tbs/common';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct AboutPage {
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
    Column() {
      // 标题栏
      TbsTitleBar({
        title: '关于',
        showBackIcon: true
      })
        .margin({ top: 0 })

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
            .backgroundColor('#007AFF')
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .margin({ top: 40 })

            Text(this.appName)
              .fontSize(24)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)

            Text('v' + this.appVersion)
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

          // 应用描述
          Text(this.appDescription)
            .fontSize(14)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
            .width('80%')
            .margin({ left: '10%' })

          // 核心功能
          Column({ space: 12 }) {
            Text('核心功能')
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .padding({ left: 16 })

            Column({ space: 0 }) {
              ForEach(this.features, (feature: string, index: number) => {
                this.FeatureItem(feature, index === this.features.length - 1)
              })
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ left: 16, right: 16 })
          }
          .width('100%')
          .margin({ top: 16 })

          // 项目信息
          Column({ space: 0 }) {
            this.InfoItem('开发者', 'FitEasy Team')
            this.Divider()
            this.InfoItem('发布日期', '2025-11-03')
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 版权信息
          Column({ space: 8 }) {
            Text('© 2025 FitEasy')
              .fontSize(12)
              .fontColor('#999999')

            Text('让健身成为一种生活方式')
              .fontSize(12)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 24, bottom: 40 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  FeatureItem(feature: string, isLast: boolean) {
    Column({ space: 0 }) {
      Row() {
        Text('•')
          .fontSize(16)
          .fontColor('#007AFF')
          .margin({ right: 8 })

        Text(feature)
          .fontSize(15)
          .fontColor('#333333')
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      if (!isLast) {
        Divider()
          .strokeWidth(0.5)
          .color('#E0E0E0')
          .margin({ left: 16, right: 16 })
      }
    }
  }

  @Builder
  InfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#666666')

      Blank()

      Text(value)
        .fontSize(15)
        .fontColor('#333333')
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  Divider() {
    Divider()
      .strokeWidth(0.5)
      .color('#E0E0E0')
      .margin({ left: 16, right: 16 })
  }
}
