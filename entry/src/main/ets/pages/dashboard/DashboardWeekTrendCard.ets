/**
 * Dashboard 本周趋势卡片
 */

import { DailyStatsModel } from '@tbs/common';

@Component
export struct DashboardWeekTrendCard {
  @Prop weekStats: DailyStatsModel[] = []
  @Prop weekTotalCount: number = 0
  @Prop weekTotalDuration: number = 0
  @Prop weekTotalWeight: number = 0

  build(): void {
    Column({ space: 12 }) {
      Row() {
        Text('本周趋势')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(this.weekTotalCount.toString() + '次训练')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      if (this.weekTotalCount > 0) {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(this.weekTotalDuration.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_primary'))
            Text('时长(分钟)')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column({ space: 4 }) {
            Text(this.weekTotalWeight.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.color_warning'))
            Text('重量(kg)')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column({ space: 4 }) {
            Text(this.weekTotalCount.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.color_success'))
            Text('训练次数')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })

        this.WeekBarChart()
      } else {
        Text('开始记录训练，查看进度趋势')
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
          .margin({ top: 20, bottom: 20 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private WeekBarChart(): void {
    Column({ space: 8 }) {
      Row({ space: 4 }) {
        ForEach(this.weekStats, (dayStat: DailyStatsModel, index: number) => {
          this.BarItem(dayStat, index)
        })
      }
      .width('100%')
      .height(120)
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Bottom)

      Row({ space: 4 }) {
        ForEach(this.weekStats, (dayStat: DailyStatsModel) => {
          Text(this.formatDateLabel(dayStat.date))
            .fontSize(10)
            .fontColor($r('app.color.text_hint'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 8 })
  }

  @Builder
  private BarItem(dayStat: DailyStatsModel, index: number): void {
    Column() {
      Column()
        .width(30)
        .height(dayStat.trainingCount > 0 ? (dayStat.duration > 0 ? Math.min(100, dayStat.duration) : 20) : 0)
        .backgroundColor(dayStat.trainingCount > 0 ? $r('app.color.brand_primary') : $r('app.color.outline'))
        .borderRadius(4)

      if (dayStat.trainingCount > 0) {
        Text(dayStat.duration.toString())
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  private formatDateLabel(dateStr: string): string {
    const parts: string[] = dateStr.split('-');
    if (parts.length === 3) {
      return parts[1] + '/' + parts[2];
    }
    return dateStr;
  }
}
