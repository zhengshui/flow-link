/**
 * 日历组件 - 显示月份日历视图
 */

import { TrainingRecordModel } from '@tbs/common';
import { CalendarDayModel } from './CalendarDayModel';

/**
 * 日历组件
 */
@Component
export struct CalendarComponent {
  @Link currentYear: number
  @Link currentMonth: number
  @Link calendarDays: CalendarDayModel[]
  @Prop isLoading: boolean = false
  onDayClick: (day: CalendarDayModel) => void = () => {}
  onPrevMonth: () => void = () => {}
  onNextMonth: () => void = () => {}
  onToday: () => void = () => {}

  // 星期标题
  private weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六']

  build() {
    Column() {
      // 年月选择器
      this.MonthSelector()

      // 日历视图
      if (this.isLoading) {
        Column({ space: 16 }) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color($r('app.color.brand_primary'))
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 星期标题行
            this.WeekHeader()

            // 日历格子
            this.CalendarGrid()
          }
          .width('100%')
          .padding({ left: 8, right: 8, bottom: 16 })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MonthSelector(): void {
    Row() {
      // 上月按钮
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(20)
        .fontColor([$r('app.color.text_primary')])
        .fontWeight(FontWeight.Medium)
        .width(40)
        .height(40)
        .onClick(() => {
          this.onPrevMonth();
        })

      // 年月显示
      Row({ space: 4 }) {
        Text(this.currentYear.toString() + '年' + this.currentMonth.toString() + '月')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.onToday();
      })

      // 下月按钮
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(20)
        .fontColor([$r('app.color.text_primary')])
        .fontWeight(FontWeight.Medium)
        .width(40)
        .height(40)
        .onClick(() => {
          this.onNextMonth();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  WeekHeader(): void {
    Row() {
      ForEach(this.weekDays, (day: string, index: number) => {
        Text(day)
          .fontSize(13)
          .fontColor(index === 0 || index === 6 ? $r('app.color.color_danger') : $r('app.color.text_secondary'))
          .width('14.28%')
          .textAlign(TextAlign.Center)
          .padding({ top: 12, bottom: 8 })
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  CalendarGrid(): void {
    Column() {
      // 6行日历格子
      ForEach([0, 1, 2, 3, 4, 5], (rowIndex: number) => {
        Row() {
          ForEach([0, 1, 2, 3, 4, 5, 6], (colIndex: number) => {
            this.DayCell(this.calendarDays[rowIndex * 7 + colIndex])
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  DayCell(day: CalendarDayModel): void {
    Column({ space: 2 }) {
      // 日期数字
      Text(day.day.toString())
        .fontSize(14)
        .fontColor(day.isCurrentMonth ? (day.isToday ? Color.White : $r('app.color.text_primary')) : $r('app.color.text_placeholder'))
        .fontWeight(day.isToday ? FontWeight.Medium : FontWeight.Normal)
        .width(28)
        .height(28)
        .textAlign(TextAlign.Center)
        .borderRadius(14)
        .backgroundColor(day.isToday ? $r('app.color.brand_primary') : Color.Transparent)

      // 训练信息
      if (day.records.length > 0 && day.isCurrentMonth) {
        Column({ space: 1 }) {
          ForEach(day.records.slice(0, 2), (record: TrainingRecordModel) => {
            Row({ space: 2 }) {
              Text(this.getTrainingAbbr(record))
                .fontSize(9)
                .fontColor(Color.White)
                .maxLines(1)
              Text(this.getTrainingVolume(record))
                .fontSize(8)
                .fontColor('rgba(255,255,255,0.8)')
                .maxLines(1)
            }
            .width('100%')
            .height(14)
            .padding({ left: 2, right: 2 })
            .backgroundColor($r('app.color.color_success'))
            .borderRadius(3)
            .justifyContent(FlexAlign.Center)
          })

          // 如果有更多记录
          if (day.records.length > 2) {
            Text('+' + (day.records.length - 2).toString())
              .fontSize(8)
              .fontColor($r('app.color.text_secondary'))
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('14.28%')
    .height(80)
    .padding(2)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      if (day.isCurrentMonth) {
        this.onDayClick(day);
      }
    })
  }

  /**
   * 获取训练名称缩写
   */
  private getTrainingAbbr(record: TrainingRecordModel): string {
    const title: string = record.title;
    if (title.length <= 2) {
      return title;
    }
    // 取前2个字符
    return title.substring(0, 2);
  }

  /**
   * 获取训练容量（总组数或总重量的简写）
   */
  private getTrainingVolume(record: TrainingRecordModel): string {
    if (record.totalWeight > 0) {
      if (record.totalWeight >= 1000) {
        return (record.totalWeight / 1000).toFixed(1) + 'T';
      }
      return record.totalWeight.toString() + 'kg';
    }
    return record.totalSets.toString() + '组';
  }
}

