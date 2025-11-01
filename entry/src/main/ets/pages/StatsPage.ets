/**
 * 数据分析页面 - Stats
 * 图表展示训练趋势、周/月汇总
 */

@Component
export struct StatsPage {
  build() {
    Column() {
      // 主内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 时间范围选择
          Row({ space: 8 }) {
            Button('周')
              .fontSize(14)
              .backgroundColor('#007AFF')
              .height(32)
              .layoutWeight(1)

            Button('月')
              .fontSize(14)
              .backgroundColor('#E0E0E0')
              .fontColor('#333333')
              .height(32)
              .layoutWeight(1)

            Button('年')
              .fontSize(14)
              .backgroundColor('#E0E0E0')
              .fontColor('#333333')
              .height(32)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })

          // 数据概览卡片
          this.StatsOverviewCard()

          // 图表区域
          this.ChartPlaceholder('训练次数趋势')
          this.ChartPlaceholder('训练重量趋势')
          this.ChartPlaceholder('运动时长统计')
        }
        .width('100%')
        .padding({ bottom: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StatsOverviewCard() {
    Column({ space: 12 }) {
      Text('本周数据概览')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      Row({ space: 20 }) {
        Column({ space: 4 }) {
          Text('0')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          Text('训练次数')
            .fontSize(12)
            .fontColor('#666666')
        }

        Column({ space: 4 }) {
          Text('0')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#34C759')
          Text('训练时长(分钟)')
            .fontSize(12)
            .fontColor('#666666')
        }

        Column({ space: 4 }) {
          Text('0')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9500')
          Text('总重量(kg)')
            .fontSize(12)
            .fontColor('#666666')
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ top: 8 })
    }
    .width('90%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ChartPlaceholder(title: string) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)

      Column() {
        Text('📊')
          .fontSize(32)
          .margin({ top: 20, bottom: 8 })

        Text('开始训练后查看数据图表')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ bottom: 20 })
      }
      .width('100%')
      .height(150)
      .backgroundColor('#F9F9F9')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
    }
    .width('90%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }
}
