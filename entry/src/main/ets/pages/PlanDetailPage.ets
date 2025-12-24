/**
 * 计划详情页面
 * 展示计划进度、周视图/日视图、支持完成/跳过/调整
 */
import {
  FitnessPlanModel,
  PlanApiService,
  TrainingDayModel,
  ExerciseModel,
  toast,
  RouterManager,
  NavRoutes,
  NavRouteParams
} from '@tbs/common';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

interface WeekStats {
  totalDays: number;
  restDays: number;
  trainingDays: number;
  completedDays: number;
  skippedDays: number;
}

@Builder
export function PlanDetailPageBuilder() {
  PlanDetailPage()
}

@Component
struct PlanDetailPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State plan: FitnessPlanModel | null = null;
  @State isLoading: boolean = true;
  @State weekDays: Array<TrainingDayModel> = [];
  @State currentWeekNumber: number = 0;
  @State weekOrder: number[] = [];
  @State weekStats: WeekStats = {
    totalDays: 0,
    restDays: 0,
    trainingDays: 0,
    completedDays: 0,
    skippedDays: 0
  };
  private planId: string = '';

  aboutToAppear(): void {
    // 获取路由参数
    const params: NavRouteParams | undefined = RouterManager.getLatestParamByName(NavRoutes.PLAN_DETAIL);
    const resolvedPlanId: string = this.resolvePlanId(params);
    if (resolvedPlanId) {
      this.planId = resolvedPlanId;
    } else {
      this.isLoading = false;
    }
  }

  /**
   * 加载计划详情
   */
  async loadPlanDetail(showLoading: boolean = true): Promise<void> {
    if (this.planId === '') {
      this.isLoading = false;
      return;
    }
    if (showLoading) {
      this.isLoading = true;
      this.plan = null;
      this.weekDays = [];
      this.weekStats = this.getEmptyWeekStats();
    }
    try {
      const res: ResponseResult = await PlanApiService.getFitnessPlan(this.planId.toString());
      if (res.code === 0 && res.data) {
        this.plan = res.data as FitnessPlanModel;
        this.updateWeekDays();
      }
    } catch (err) {
      console.error('加载计划详情失败:', JSON.stringify(err));
      toast('加载失败');
    } finally {
      if (showLoading) {
        this.isLoading = false;
      }
    }
  }

  /**
   * 判断是否是今天
   */
  private isToday(dayNumber: number): boolean {
    if (this.plan === null || !this.plan.startDate) {
      return false;
    }
    const parts = this.plan.startDate.split('-');
    if (parts.length !== 3) {
      return false;
    }
    const startYear = parseInt(parts[0]);
    const startMonth = parseInt(parts[1]) - 1;
    const startDay = parseInt(parts[2]);
    const start = new Date(startYear, startMonth, startDay);

    const now = new Date();
    const current = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const diffTime = current.getTime() - start.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    return dayNumber === (diffDays + 1);
  }

  private resolvePlanId(params?: NavRouteParams): string {
    if (params === undefined) {
      return '';
    }
    const rawPlanId: string | undefined = params.planId as string | '';
    return rawPlanId;
  }

  /**
   * 完成训练日
   */
  async completePlanDay(dayNumber: number): Promise<void> {
    try {
      const res: ResponseResult =
        await PlanApiService.completePlanDay(this.planId.toString(), dayNumber);
      if (res.code === 0) {
        toast('已标记完成');
        this.loadPlanDetail();
      } else {
        toast('操作失败');
      }
    } catch (err) {
      console.error('完成训练日失败:', JSON.stringify(err));
      toast('操作失败');
    }
  }

  /**
   * 跳过训练日
   */
  async skipPlanDay(dayNumber: number): Promise<void> {
    try {
      const res: ResponseResult = await PlanApiService.skipPlanDay(this.planId.toString(), dayNumber);
      if (res.code === 0) {
        toast('已跳过');
        this.loadPlanDetail();
      } else {
        toast('操作失败');
      }
    } catch (err) {
      console.error('跳过训练日失败:', JSON.stringify(err));
      toast('操作失败');
    }
  }

  /**
   * 开始训练（跳转到训练页面）
   */
  startTraining(day: TrainingDayModel): void {
    RouterManager.pushPath(NavRoutes.TRAINING_SESSION, {
      planId: this.planId,
      dayNumber: day.dayNumber
    });
  }

  /**
   * 获取当前周的训练日
   */
  private updateWeekDays(): void {
    const weekNumber: number = this.getCurrentWeekNumber();
    if (this.currentWeekNumber !== weekNumber) {
      this.weekOrder = [];
      this.currentWeekNumber = weekNumber;
    }
    const days: Array<TrainingDayModel> = this.getCurrentWeekDaysFromPlan();
    const orderedDays: Array<TrainingDayModel> = this.applyWeekOrder(days);
    this.weekDays = orderedDays;
    this.weekStats = this.calculateWeekStats(orderedDays);
  }

  private getCurrentWeekDaysFromPlan(): Array<TrainingDayModel> {
    if (this.plan === null) {
      return [];
    }
    const daysPerWeek: number = this.getDaysPerWeek();
    const weekIndex: number = this.getCurrentWeekNumber() - 1;
    const startIndex: number = weekIndex * daysPerWeek;
    const endIndex: number = startIndex + daysPerWeek;
    return this.plan.trainingDays.slice(startIndex, Math.min(endIndex, this.plan.trainingDays.length));
  }

  private getDaysPerWeek(): number {
    if (this.plan === null) {
      return 7;
    }
    return this.plan.trainingDaysPerWeek > 0 ? this.plan.trainingDaysPerWeek : 7;
  }

  private getCurrentWeekNumber(): number {
    if (this.plan === null) {
      return 1;
    }
    return this.plan.currentWeek > 0 ? this.plan.currentWeek : 1;
  }

  private applyWeekOrder(days: Array<TrainingDayModel>): Array<TrainingDayModel> {
    if (this.weekOrder.length === 0 || this.weekOrder.length !== days.length) {
      return days;
    }
    const ordered: Array<TrainingDayModel> = [];
    for (let i: number = 0; i < this.weekOrder.length; i++) {
      const targetDayNumber: number = this.weekOrder[i];
      let matched: TrainingDayModel | null = null;
      for (let j: number = 0; j < days.length; j++) {
        if (days[j].dayNumber === targetDayNumber) {
          matched = days[j];
          break;
        }
      }
      if (matched === null) {
        return days;
      }
      ordered.push(matched);
    }
    return ordered;
  }

  private moveWeekDay(fromIndex: number, toIndex: number): void {
    const maxIndex: number = this.weekDays.length - 1;
    if (fromIndex < 0 || toIndex < 0 || fromIndex > maxIndex || toIndex > maxIndex) {
      return;
    }
    const nextDays: Array<TrainingDayModel> = [];
    for (let i: number = 0; i < this.weekDays.length; i++) {
      nextDays.push(this.weekDays[i]);
    }
    const moved: TrainingDayModel = nextDays.splice(fromIndex, 1)[0];
    nextDays.splice(toIndex, 0, moved);
    this.weekDays = nextDays;
    this.updateWeekOrderFromDays();
    this.weekStats = this.calculateWeekStats(nextDays);
  }

  private updateWeekOrderFromDays(): void {
    const nextOrder: number[] = [];
    for (let i: number = 0; i < this.weekDays.length; i++) {
      nextOrder.push(this.weekDays[i].dayNumber);
    }
    this.weekOrder = nextOrder;
  }

  private getEmptyWeekStats(): WeekStats {
    return {
      totalDays: 0,
      restDays: 0,
      trainingDays: 0,
      completedDays: 0,
      skippedDays: 0
    };
  }

  /**
   * 判断训练日是否已完成
   */
  isDayCompleted(dayNumber: number): boolean {
    if (this.plan === null) {
      return false;
    }
    return this.plan.completedDays.indexOf(dayNumber) !== -1;
  }

  /**
   * 判断训练日是否已跳过
   */
  isDaySkipped(dayNumber: number): boolean {
    if (this.plan === null) {
      return false;
    }
    return this.plan.skippedDays.indexOf(dayNumber) !== -1;
  }

  build() {
    NavDestination() {
      Column() {
        this.HeaderBar()

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('app.color.brand_primary'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.plan !== null) {
          Scroll() {
            Column({ space: 16 }) {
              // 本周概览
              this.WeekSummaryCard()

              // 总体进度
              this.ProgressCard()

              // 训练日程
              this.TrainingDaysList()
            }
            .width('100%')
            .padding({
              bottom: 16 + this.getUIContext().px2vp(this.bottomRectHeight),
              left: 16,
              right: 16,
              top: 16
            })
          }
          .width('100%')
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
        } else {
          // 空状态
          Column({ space: 12 }) {
            Text('计划不存在')
              .fontSize(15)
              .fontColor($r('app.color.text_hint'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_background'))
    .onBackPressed(() => {
      RouterManager.pop();
      return true;
    })
    .onShown(() => {
      if (this.planId) {
        this.loadPlanDetail(this.plan === null);
      }
    })
  }

  @Builder
  ProgressCard() {
    Column({ space: 12 }) {
      // 标题和状态
      Row() {
        Text('训练进度')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(this.plan?.status ?? '')
          .fontSize(11)
          .fontColor(Color.White)
          .backgroundColor(this.getStatusColor(this.plan?.status ?? ''))
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(4)
      }
      .width('100%')

      // 进度条
      Column({ space: 6 }) {
        Row() {
          Text('完成率')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
          Blank()
          Text((this.plan?.completionRate ?? 0).toString() + '%')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_primary'))
        }
        .width('100%')

        Row() {
          Row()
            .width((this.plan?.completionRate ?? 0).toString() + '%')
            .height('100%')
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(3)
        }
        .width('100%')
        .height(8)
        .backgroundColor($r('app.color.outline'))
        .borderRadius(4)
      }
      .width('100%')

      // 统计数据
      Row({ space: 12 }) {
        this.StatBox(this.plan?.totalCompletedDays.toString() ?? '0', '已完成',
          $r('app.color.color_success'))
        this.StatBox((this.plan?.skippedDays.length ?? 0).toString(), '已跳过',
          $r('app.color.color_warning'))
        this.StatBox('第' + (this.plan?.currentWeek ?? 0).toString() + '周', '当前周',
          $r('app.color.brand_primary'))
        this.StatBox(this.plan?.goal ?? '', '目标', $r('app.color.color_accent'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  HeaderBar() {
    Row({ space: 12 }) {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([$r('app.color.text_primary')])
        .onClick(() => {
          RouterManager.pop();
        })

      Column({ space: 4 }) {
        Text(this.plan?.name ?? '计划详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('第' + this.getCurrentWeekNumber().toString() + '周')
        .fontSize(11)
        .fontColor($r('app.color.brand_primary'))
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor($r('app.color.brand_primary_light'))
        .borderRadius(12)
    }
    .width('100%')
    .height(70)
    .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  WeekSummaryCard() {
    Column({ space: 10 }) {
      Row() {
        Text('本周概览')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(this.getWeekCompletionRateText() + ' 完成')
          .fontSize(12)
          .fontColor($r('app.color.brand_primary'))
      }
      .width('100%')

      Row({ space: 12 }) {
        Text('训练日 ' + this.weekStats.trainingDays.toString())
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        Text('休息日 ' + this.weekStats.restDays.toString())
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        if (this.weekStats.skippedDays > 0) {
          Text('已跳过 ' + this.weekStats.skippedDays.toString())
            .fontSize(12)
            .fontColor($r('app.color.color_warning'))
        }
      }
      .width('100%')

      Row() {
        Row()
          .width(this.getWeekCompletionRateText())
          .height('100%')
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(3)
      }
      .width('100%')
      .height(8)
      .backgroundColor($r('app.color.outline'))
      .borderRadius(4)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  StatBox(value: string, label: string, color: Resource) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(10)
        .fontColor($r('app.color.text_hint'))
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  TrainingDaysList() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text('本周训练日')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Text('点击卡片开始训练，上下箭头调整顺序')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.weekStats.completedDays.toString() + '/' + this.weekStats.trainingDays.toString() + ' 完成')
          .fontSize(11)
          .fontColor($r('app.color.text_placeholder'))
      }
      .width('100%')

      if (this.weekDays.length === 0) {
        Column() {
          Text('本周暂无训练安排')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
        }
        .width('100%')
        .padding({ top: 20, bottom: 20 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(10)
        .alignItems(HorizontalAlign.Center)
      } else {
        ForEach(this.weekDays, (day: TrainingDayModel, index: number) => {
          this.TrainingDayCard(day, index)
        }, (day: TrainingDayModel): string => day.dayNumber.toString())
      }
    }
    .width('100%')
  }

  @Builder
  TrainingDayCard(day: TrainingDayModel, index: number) {
    Column({ space: 10 }) {
      // 标题行
      Row() {
        Column({ space: 4 }) {
          Text('第' + (index + 1).toString() + '天')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.brand_primary'))
          Text(day.dayName.length > 0 ? day.dayName : '训练日')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .layoutWeight(1)

        Row({ space: 6 }) {
          // 状态标签
          if (this.isDayCompleted(day.dayNumber)) {
            Text('已完成')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.color_success'))
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(4)
          } else if (this.isDaySkipped(day.dayNumber)) {
            Text('已跳过')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.color_warning'))
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(4)
          } else if (day.isRestDay) {
            Text('休息日')
              .fontSize(10)
              .fontColor($r('app.color.text_hint'))
              .backgroundColor($r('app.color.card_background_secondary'))
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(4)
          }

          if (this.weekDays.length > 1 && !this.isDayCompleted(day.dayNumber)) {
            Row({ space: 4 }) {
              Column() {
                SymbolGlyph($r('sys.symbol.chevron_up'))
                  .fontSize(14)
                  .fontColor([index > 0 ? $r('app.color.text_primary') : $r('app.color.text_placeholder')])
              }
              .width(22)
              .height(22)
              .borderRadius(6)
              .backgroundColor($r('app.color.card_background_secondary'))
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .opacity(index > 0 ? 1 : 0.4)
              .onClick(() => {
                if (index > 0) {
                  this.moveWeekDay(index, index - 1);
                }
              })

              Column() {
                SymbolGlyph($r('sys.symbol.chevron_down'))
                  .fontSize(14)
                  .fontColor([index < this.weekDays.length - 1 ?
                    $r('app.color.text_primary') : $r('app.color.text_placeholder')])
              }
              .width(22)
              .height(22)
              .borderRadius(6)
              .backgroundColor($r('app.color.card_background_secondary'))
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .opacity(index < this.weekDays.length - 1 ? 1 : 0.4)
              .onClick(() => {
                if (index < this.weekDays.length - 1) {
                  this.moveWeekDay(index, index + 1);
                }
              })
            }
          }
        }
      }
      .width('100%')

      // 训练项目
      if (!day.isRestDay && day.exercises.length > 0) {
        Column({ space: 6 }) {
          ForEach(day.exercises.slice(0, 3), (exercise: ExerciseModel, index: number) => {
            Row() {
              Text(exercise.name)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .layoutWeight(1)
              Text(exercise.sets.toString() + '组×' + exercise.reps.toString() + '次')
                .fontSize(12)
                .fontColor($r('app.color.text_hint'))
            }
            .width('100%')
          }, (exercise: ExerciseModel, index: number): string => index.toString())

          if (day.exercises.length > 3) {
            Text('...共' + day.exercises.length.toString() + '个动作')
              .fontSize(11)
              .fontColor($r('app.color.text_placeholder'))
          }
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(8)
      }

    }
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(10)
    .onClick(() => {
      if (!day.isRestDay) {
        if (this.isToday(day.dayNumber)) {
          this.startTraining(day);
        } else {
          toast('只能进入今天的训练计划');
        }
      }
    })
  }

  /**
   * 获取本周统计
   */
  private calculateWeekStats(days: Array<TrainingDayModel>): WeekStats {
    const stats: WeekStats = this.getEmptyWeekStats();
    stats.totalDays = days.length;
    for (let i: number = 0; i < days.length; i++) {
      const day: TrainingDayModel = days[i];
      if (day.isRestDay) {
        stats.restDays += 1;
      } else {
        stats.trainingDays += 1;
      }
      if (this.isDayCompleted(day.dayNumber)) {
        stats.completedDays += 1;
      }
      if (this.isDaySkipped(day.dayNumber)) {
        stats.skippedDays += 1;
      }
    }
    return stats;
  }

  private getWeekCompletionRateValue(): number {
    if (this.weekStats.trainingDays === 0) {
      return 0;
    }
    return Math.round((this.weekStats.completedDays / this.weekStats.trainingDays) * 100);
  }

  private getWeekCompletionRateText(): string {
    return this.getWeekCompletionRateValue().toString() + '%';
  }

  /**
   * 获取计划状态颜色
   */
  getStatusColor(status: string): Resource {
    if (status === '进行中') {
      return $r('app.color.color_success');
    } else if (status === '已完成') {
      return $r('app.color.brand_primary');
    } else if (status === '已暂停') {
      return $r('app.color.color_warning');
    }
    return $r('app.color.text_hint');
  }
}
