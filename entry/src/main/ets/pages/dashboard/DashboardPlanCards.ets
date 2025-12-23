/**
 * Dashboard 训练计划相关卡片
 */

import { FitnessPlanModel, TrainingDayModel } from '@tbs/common';

@Component
export struct DashboardTodayPlanSection {
  @Prop plan: FitnessPlanModel = new FitnessPlanModel()
  @Prop todayDay: TrainingDayModel | null = null
  onStartTraining: (plan: FitnessPlanModel, day: TrainingDayModel | null) => void = () => {}

  build(): void {
    Column({ space: 10 }) {
      Text('今日安排')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      if (this.hasTodayDay()) {
        Column({ space: 6 }) {
          Row() {
            Text('今日计划')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
            Blank()
            Text(this.getTodaySummaryText())
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')

          Row() {
            Text(this.getTodayDayName())
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.brand_primary'))
          }
          .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(10)
        .onClick(() => {
          this.onStartTraining(this.plan, this.todayDay);
        })
      } else {
        Text('今天没有安排训练。')
          .fontSize(13)
          .fontColor($r('app.color.text_hint'))
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  private hasTodayDay(): boolean {
    return this.todayDay !== null;
  }

  private getTodayDayName(): string {
    if (this.todayDay === null) {
      return '训练日';
    }
    return this.todayDay.dayName !== '' ? this.todayDay.dayName : '训练日';
  }

  private getTodayExerciseCount(): number {
    if (this.todayDay === null || this.todayDay.exercises === null || this.todayDay.exercises === undefined) {
      return 0;
    }
    return this.todayDay.exercises.length;
  }

  private getTodaySummaryText(): string {
    if (this.todayDay === null) {
      return '';
    }
    const dayText: string = '第' + this.todayDay.dayNumber.toString() + '天';
    if (this.todayDay.isRestDay) {
      return dayText + ' · 休息';
    }
    const exerciseCount: number = this.getTodayExerciseCount();
    if (exerciseCount > 0) {
      return dayText + ' · ' + exerciseCount.toString() + '个动作';
    }
    return dayText + ' · 训练';
  }
}

@Component
export struct DashboardPlanManagementCard {
  @Prop plan: FitnessPlanModel = new FitnessPlanModel()
  @Prop totalDays: number = 0
  @Prop weekDays: TrainingDayModel[] = []
  @Prop currentDayNumber: number = 1
  onOpenPlanDetail: (plan: FitnessPlanModel) => void = () => {}

  build(): void {
    Column({ space: 12 }) {
      Row() {
        Text('计划管理')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text('已完成 ' + this.plan.totalCompletedDays.toString() + ' | ' + this.totalDays.toString())
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      if (this.weekDays.length > 0) {
        this.WeeklyScheduleRow()
      } else {
        Text('当前计划暂未配置一周训练日。')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
      }

      Row() {
        Blank()
        Button('>> 管理计划')
          .height(28)
          .fontSize(12)
          .fontColor($r('app.color.brand_primary'))
          .backgroundColor(Color.Transparent)
          .borderRadius(8)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .onClick(() => {
            this.onOpenPlanDetail(this.plan);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  private WeeklyScheduleRow(): void {
    Scroll() {
      Row({ space: 12 }) {
        ForEach(this.weekDays, (day: TrainingDayModel) => {
          this.ScheduleDayItem(day)
        }, (day: TrainingDayModel): string => day.dayNumber.toString())
      }
      .padding({ right: 8 })
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }

  @Builder
  private ScheduleDayItem(day: TrainingDayModel): void {
    Column({ space: 6 }) {
      Column() {
        Text('D' + day.dayNumber.toString())
          .fontSize(11)
          .fontColor(this.getScheduleDayTextColor(day))
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(this.getScheduleDayBgColor(day))
      .borderRadius(12)

      Text(day.dayName || '训练日')
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(this.getPlanDayStatusLabel(
        this.isPlanDayCompleted(day.dayNumber),
        this.isPlanDayToday(day),
        day.isRestDay
      ))
        .fontSize(11)
        .fontColor(this.getScheduleDayStatusColor(day))
    }
    .width(72)
    .alignItems(HorizontalAlign.Center)
  }

  private isPlanDayCompleted(dayNumber: number): boolean {
    return this.plan.completedDays.indexOf(dayNumber) !== -1;
  }

  private isPlanDayToday(day: TrainingDayModel): boolean {
    return day.dayNumber === this.currentDayNumber;
  }

  private getPlanDayStatusLabel(isCompleted: boolean, isToday: boolean, isRest: boolean): string {
    if (isCompleted) {
      return '已完成';
    }
    if (isRest) {
      return '休息';
    }
    if (isToday) {
      return '今日';
    }
    return '待训练';
  }

  private getScheduleDayBgColor(day: TrainingDayModel): Resource {
    if (this.isPlanDayCompleted(day.dayNumber)) {
      return $r('app.color.brand_primary');
    }
    if (this.isPlanDayToday(day)) {
      return $r('app.color.color_warning');
    }
    if (day.isRestDay) {
      return $r('app.color.card_background_secondary');
    }
    return $r('app.color.outline');
  }

  private getScheduleDayTextColor(day: TrainingDayModel): ResourceColor {
    if (this.isPlanDayCompleted(day.dayNumber) || this.isPlanDayToday(day)) {
      return Color.White;
    }
    return $r('app.color.text_primary');
  }

  private getScheduleDayStatusColor(day: TrainingDayModel): Resource {
    if (this.isPlanDayCompleted(day.dayNumber)) {
      return $r('app.color.color_success');
    }
    if (this.isPlanDayToday(day)) {
      return $r('app.color.color_warning');
    }
    return $r('app.color.text_hint');
  }
}
