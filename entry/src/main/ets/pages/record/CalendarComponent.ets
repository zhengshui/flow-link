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
            .width(36)
            .height(36)
            .color($r('app.color.brand_primary'))
          Text('加载中...')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          // 星期标题行
          this.WeekHeader()

          // 日历格子
          this.CalendarGrid()
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MonthSelector(): void {
    Row() {
      // 上月按钮
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(18)
          .fontColor([$r('app.color.text_secondary')])
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .borderRadius(20)
      .backgroundColor($r('app.color.card_background_secondary'))
      .onClick(() => {
        this.onPrevMonth();
      })

      Blank()

      // 年月显示
      Row({ space: 4 }) {
        Text(this.currentYear.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('年')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Text(this.currentMonth.toString().padStart(2, '0'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('月')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .onClick(() => {
        this.onToday();
      })

      Blank()

      // 下月按钮
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(18)
          .fontColor([$r('app.color.text_secondary')])
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .borderRadius(20)
      .backgroundColor($r('app.color.card_background_secondary'))
      .onClick(() => {
        this.onNextMonth();
      })
    }
    .width('100%')
    .height(64)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  WeekHeader(): void {
    Row() {
      ForEach(this.weekDays, (day: string, index: number) => {
        Text(day)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(index === 0 || index === 6 ? $r('app.color.color_danger') : $r('app.color.text_hint'))
          .width('14.28%')
          .textAlign(TextAlign.Center)
          .padding({ top: 8, bottom: 12 })
      })
    }
    .width('100%')
  }

  @Builder
  CalendarGrid(): void {
    Column({ space: 4 }) {
      // 6行日历格子
      ForEach([0, 1, 2, 3, 4, 5], (rowIndex: number) => {
        Row({ space: 4 }) {
          ForEach([0, 1, 2, 3, 4, 5, 6], (colIndex: number) => {
            this.DayCell(this.calendarDays[rowIndex * 7 + colIndex])
          })
        }
        .width('100%')
      })
    }
    .width('100%')
  }

  @Builder
  DayCell(day: CalendarDayModel): void {
    Column({ space: 4 }) {
      // 日期数字
      Stack() {
        if (day.isToday) {
          // 今日背景圆圈
          Circle()
            .width(32)
            .height(32)
            .fill($r('app.color.brand_primary'))
        }
        Text(day.day.toString())
          .fontSize(15)
          .fontColor(this.getDayTextColor(day))
          .fontWeight(day.isToday ? FontWeight.Medium : FontWeight.Normal)
      }
      .width(32)
      .height(32)
      .alignContent(Alignment.Center)

      // 训练标记点
      if (day.records.length > 0 && day.isCurrentMonth) {
        this.TrainingIndicator(day)
      }
    }
    .width('13.5%')
    .height(72)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 4 })
    .borderRadius(8)
    .backgroundColor(day.isCurrentMonth && day.records.length > 0 ? $r('app.color.card_background') : Color.Transparent)
    .onClick(() => {
      if (day.isCurrentMonth) {
        this.onDayClick(day);
      }
    })
  }

  @Builder
  TrainingIndicator(day: CalendarDayModel): void {
    if (day.records.length === 1) {
      // 单条记录 - 显示单个圆点
      Circle()
        .width(6)
        .height(6)
        .fill($r('app.color.color_success'))
    } else if (day.records.length === 2) {
      // 两条记录 - 显示两个圆点
      Row({ space: 3 }) {
        Circle()
          .width(5)
          .height(5)
          .fill($r('app.color.color_success'))
        Circle()
          .width(5)
          .height(5)
          .fill($r('app.color.brand_primary'))
      }
    } else {
      // 多条记录 - 显示圆点和数字
      Row({ space: 2 }) {
        Circle()
          .width(5)
          .height(5)
          .fill($r('app.color.color_success'))
        Text('+' + (day.records.length - 1).toString())
          .fontSize(9)
          .fontColor($r('app.color.text_hint'))
          .fontWeight(FontWeight.Medium)
      }
    }
  }

  /**
   * 获取日期文字颜色
   */
  private getDayTextColor(day: CalendarDayModel): ResourceColor {
    if (!day.isCurrentMonth) {
      return $r('app.color.text_placeholder');
    }
    if (day.isToday) {
      return Color.White;
    }
    return $r('app.color.text_primary');
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
