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
    // 确保 calendarDays 有数据才渲染
    if (this.calendarDays.length === 42) {
      Column({ space: 4 }) {
        // 6行日历格子
        ForEach([0, 1, 2, 3, 4, 5], (rowIndex: number) => {
          Row({ space: 4 }) {
            ForEach([0, 1, 2, 3, 4, 5, 6], (colIndex: number) => {
              this.DayCell(this.calendarDays[rowIndex * 7 + colIndex])
            }, (colIndex: number): string => {
              // 使用日期字符串作为 key，确保月份切换时重新渲染
              const dayIndex: number = rowIndex * 7 + colIndex;
              return this.calendarDays[dayIndex].dateStr;
            })
          }
          .width('100%')
        }, (rowIndex: number): string => {
          // 使用年月+行号作为 key
          return `${this.currentYear}-${this.currentMonth}-row${rowIndex}`;
        })
      }
      .width('100%')
    }
  }

  @Builder
  DayCell(day: CalendarDayModel): void {
    Column({ space: 2 }) {
      // 日期数字
      Stack() {
        if (day.isToday) {
          // 今日背景圆圈
          Circle()
            .width(28)
            .height(28)
            .fill($r('app.color.brand_primary'))
        }
        Text(day.day.toString())
          .fontSize(14)
          .fontColor(this.getDayTextColor(day))
          .fontWeight(day.isToday ? FontWeight.Medium : FontWeight.Normal)
      }
      .width(28)
      .height(28)
      .alignContent(Alignment.Center)

      // 训练标记
      if (day.records.length > 0 && day.isCurrentMonth) {
        this.TrainingIndicator(day)
      }
    }
    .width('13.5%')
    .height(68)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 4 })
    .borderRadius(8)
    .backgroundColor(day.isCurrentMonth && day.records.length > 0 && !this.isFutureDate(day.dateStr) ? $r('app.color.card_background') : Color.Transparent)
    .opacity(this.isFutureDate(day.dateStr) ? 0.4 : 1.0)
    .onClick(() => {
      if (day.isCurrentMonth && !this.isFutureDate(day.dateStr)) {
        this.onDayClick(day);
      }
    })
  }

  @Builder
  TrainingIndicator(day: CalendarDayModel): void {
    Column({ space: 1 }) {
      if (day.records.length === 1) {
        // 单条记录 - 显示训练名称和容量
        Text(this.getTrainingAbbr(day.records[0]))
          .fontSize(9)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.color_success'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip })
        Text(this.getTrainingVolume(day.records[0]))
          .fontSize(8)
          .fontColor($r('app.color.text_hint'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip })
      } else {
        // 多条记录 - 显示记录数和合计容量
        Text(day.records.length.toString() + '次')
          .fontSize(9)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.brand_primary'))
        Text(this.getTotalVolume(day.records))
          .fontSize(8)
          .fontColor($r('app.color.text_hint'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip })
      }
    }
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 判断日期是否为未来日期
   */
  private isFutureDate(dateStr: string): boolean {
    const today: Date = new Date();
    const todayYear: number = today.getFullYear();
    const todayMonth: number = today.getMonth() + 1;
    const todayDay: number = today.getDate();
    const todayStr: string = `${todayYear}-${todayMonth.toString().padStart(2, '0')}-${todayDay.toString().padStart(2, '0')}`;
    return dateStr > todayStr;
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
    // 未来日期使用更淡的颜色
    if (this.isFutureDate(day.dateStr)) {
      return $r('app.color.text_hint');
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

  /**
   * 获取多条记录的总容量
   */
  private getTotalVolume(records: TrainingRecordModel[]): string {
    let totalWeight: number = 0;
    let totalSets: number = 0;
    for (let i: number = 0; i < records.length; i++) {
      totalWeight += records[i].totalWeight;
      totalSets += records[i].totalSets;
    }
    if (totalWeight > 0) {
      if (totalWeight >= 1000) {
        return (totalWeight / 1000).toFixed(1) + 'T';
      }
      return totalWeight.toString() + 'kg';
    }
    return totalSets.toString() + '组';
  }
}
