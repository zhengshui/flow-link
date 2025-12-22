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

@Builder
export function PlanDetailPageBuilder() {
  PlanDetailPage()
}

@Component
struct PlanDetailPage {
  @State plan: FitnessPlanModel | null = null;
  @State isLoading: boolean = true;
  @State viewMode: 'week' | 'day' = 'week';
  @State selectedWeek: number = 1;
  @State selectedDayIndex: number = 0;
  private planId: number = 0;

  aboutToAppear(): void {
    // 获取路由参数
    const params: NavRouteParams | undefined = RouterManager.getNavPathStack()?.getParamByName('PlanDetailPage') as
      NavRouteParams | undefined;
    if (params?.planId) {
      this.planId = params.planId;
    }
    this.loadPlanDetail();
  }

  /**
   * 加载计划详情
   */
  async loadPlanDetail(): Promise<void> {
    this.isLoading = true;
    this.plan = null;
    try {
      const res: ResponseResult = await PlanApiService.getFitnessPlan(this.planId.toString());
      if (res.code === 0 && res.data) {
        this.plan = res.data as FitnessPlanModel;
        this.selectedWeek = this.plan.currentWeek > 0 ? this.plan.currentWeek : 1;
      }
    } catch (err) {
      console.error('加载计划详情失败:', JSON.stringify(err));
      toast('加载失败');
    } finally {
      this.isLoading = false;
    }
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
  getWeekDays(): TrainingDayModel[] {
    if (this.plan === null) {
      return [];
    }
    const daysPerWeek: number = this.plan.trainingDaysPerWeek > 0 ? this.plan.trainingDaysPerWeek : 7;
    const startIndex: number = (this.selectedWeek - 1) * daysPerWeek;
    const endIndex: number = startIndex + daysPerWeek;
    return this.plan.trainingDays.slice(startIndex, Math.min(endIndex, this.plan.trainingDays.length));
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
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color($r('app.color.brand_primary'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.plan !== null) {
        Scroll() {
          Column({ space: 16 }) {
            // 进度卡片
            this.ProgressCard()

            // 视图切换
            this.ViewModeSwitch()

            // 周选择器（周视图时显示）
            if (this.viewMode === 'week') {
              this.WeekSelector()
            }

            // 训练日程
            this.TrainingDaysList()
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .height('100%')
        .align(Alignment.Top)
      } else {
        // 空状态
        Column({ space: 12 }) {
          Text('计划不存在')
            .fontSize(15)
            .fontColor($r('app.color.text_hint'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .title(this.plan?.name ?? '计划详情')
    .backgroundColor($r('app.color.page_background'))
    .onBackPressed(() => {
      RouterManager.pop();
      return true;
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
  ViewModeSwitch() {
    Row() {
      Row() {
        Text('周视图')
          .fontSize(13)
          .fontColor(this.viewMode === 'week' ? Color.White : $r('app.color.text_secondary'))
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.viewMode === 'week' ?
            $r('app.color.brand_primary') : Color.Transparent)
          .borderRadius(16)
          .onClick(() => {
            this.viewMode = 'week';
          })

        Text('全部')
          .fontSize(13)
          .fontColor(this.viewMode === 'day' ? Color.White : $r('app.color.text_secondary'))
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.viewMode === 'day' ?
            $r('app.color.brand_primary') : Color.Transparent)
          .borderRadius(16)
          .onClick(() => {
            this.viewMode = 'day';
          })
      }
      .backgroundColor($r('app.color.card_background_secondary'))
      .borderRadius(20)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  WeekSelector() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.getWeekNumbers(), (week: number) => {
          Text('第' + week.toString() + '周')
            .fontSize(12)
            .fontColor(this.selectedWeek === week ? Color.White : $r('app.color.text_secondary'))
            .backgroundColor(this.selectedWeek === week ?
              $r('app.color.brand_primary') : $r('app.color.card_background'))
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .borderRadius(16)
            .onClick(() => {
              this.selectedWeek = week;
            })
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  TrainingDaysList() {
    Column({ space: 10 }) {
      ForEach(this.viewMode === 'week' ? this.getWeekDays() : (this.plan?.trainingDays ?? []),
        (day: TrainingDayModel) => {
          this.TrainingDayCard(day)
        }, (day: TrainingDayModel): string => day.dayNumber.toString())
    }
    .width('100%')
  }

  @Builder
  TrainingDayCard(day: TrainingDayModel) {
    Column({ space: 10 }) {
      // 标题行
      Row() {
        Row({ space: 8 }) {
          Text('Day ' + day.dayNumber.toString())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.brand_primary'))
          Text(day.dayName)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .layoutWeight(1)

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

      // 操作按钮（未完成且非休息日时显示）
      if (!this.isDayCompleted(day.dayNumber) && !this.isDaySkipped(day.dayNumber) && !day.isRestDay) {
        Row({ space: 10 }) {
          Button('开始训练')
            .layoutWeight(2)
            .height(36)
            .fontSize(13)
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(8)
            .onClick(() => {
              this.startTraining(day);
            })

          Button('跳过')
            .layoutWeight(1)
            .height(36)
            .fontSize(13)
            .fontColor($r('app.color.color_warning'))
            .backgroundColor($r('app.color.color_warning_light'))
            .borderRadius(8)
            .onClick(() => {
              this.skipPlanDay(day.dayNumber);
            })

          Button('完成')
            .layoutWeight(1)
            .height(36)
            .fontSize(13)
            .fontColor($r('app.color.color_success'))
            .backgroundColor($r('app.color.color_success_light'))
            .borderRadius(8)
            .onClick(() => {
              this.completePlanDay(day.dayNumber);
            })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(10)
  }

  /**
   * 获取周数数组
   */
  getWeekNumbers(): number[] {
    if (this.plan === null) {
      return [];
    }
    const weeks: number[] = [];
    for (let i: number = 1; i <= this.plan.durationWeeks; i++) {
      weeks.push(i);
    }
    return weeks;
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

