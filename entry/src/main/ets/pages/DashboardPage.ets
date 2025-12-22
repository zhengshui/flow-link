/**
 * 首页 - Dashboard
 * 显示训练概览、进度统计
 */

import {
  TrainingRecordModel,
  TrainingApiService,
  StatsApiService,
  PlanApiService,
  DailyStatsModel,
  FitnessPlanModel,
  PlanTemplateModel,
  TrainingDayModel,
  TrainingStatsModel,
  toast,
  RouterManager,
  NavRoutes
} from '@tbs/common';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

@Component
export struct DashboardPage {
  @State todayRecords: TrainingRecordModel[] = []
  @State currentRecordIndex: number = 0
  @State weekStats: DailyStatsModel[] = []
  @State weekTotalCount: number = 0
  @State weekTotalDuration: number = 0
  @State weekTotalWeight: number = 0
  @State myPlan: FitnessPlanModel | null = null
  @State myPlans: FitnessPlanModel[] = []
  @State officialTemplates: PlanTemplateModel[] = []
  @State personalTemplates: PlanTemplateModel[] = []
  @State templateTabIndex: number = 0
  @State creatingTemplateId: number = 0
  @State isLoading: boolean = false
  private readonly templateTabTitles: string[] = ['官方计划', '个人模板'];
  @StorageProp('topRectHeight') topRectHeight: number = 0
  // 使用时间戳监听刷新，确保每次变化都能触发
  @StorageLink('refreshDashboardTimestamp') @Watch('onRefreshTimestampChange') refreshTimestamp: number = 0

  aboutToAppear(): void {
    // 初始化刷新时间戳
    AppStorage.setOrCreate<number>('refreshDashboardTimestamp', 0);
    this.loadData();
  }

  /**
   * 监听刷新时间戳变化，当从训练页面返回时刷新数据
   */
  onRefreshTimestampChange(): void {
    // 时间戳大于0表示需要刷新
    if (this.refreshTimestamp > 0) {
      console.info('[DashboardPage] 检测到刷新时间戳变化，刷新数据');
      this.loadData();
    }
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    this.isLoading = true;
    // 重置所有状态为初始值，确保后续赋值能触发 UI 刷新
    this.todayRecords = [];
    this.weekStats = [];
    this.weekTotalCount = 0;
    this.weekTotalDuration = 0;
    this.weekTotalWeight = 0;
    console.info('[DashboardPage] loadData - 状态已重置，开始加载数据');
    try {
      // 并行加载所有数据
      await Promise.all([
        this.loadWeekStats(),
        this.loadTodayRecord(),
        this.loadPlans(),
        this.loadOfficialTemplates(),
        this.loadPersonalTemplates()
      ]);
      console.info('[DashboardPage] loadData - 数据加载完成');
    } catch (err) {
      console.error('加载数据失败:', JSON.stringify(err));
      toast('数据加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载本周统计数据
   */
  async loadWeekStats(): Promise<void> {
    try {
      const res: ResponseResult = await StatsApiService.getTrainingStats('week');
      if (res.code === 0 && res.data) {
        const stats: TrainingStatsModel = res.data as TrainingStatsModel;
        this.weekStats = stats.dailyStats;
        this.weekTotalCount = stats.totalTrainingCount;
        this.weekTotalDuration = stats.totalDuration;
        this.weekTotalWeight = stats.totalWeight;
      }
    } catch (err) {
      console.error('加载本周统计失败:', JSON.stringify(err));
    }
  }

  /**
   * 加载今天的训练记录（支持一天多练）
   */
  async loadTodayRecord(): Promise<void> {
    try {
      const today: Date = new Date();
      const todayStr: string = today.getFullYear() + '-' +
        (today.getMonth() + 1).toString().padStart(2, '0') + '-' +
        today.getDate().toString().padStart(2, '0');

      console.info('[DashboardPage] 加载今日训练记录, 日期:', todayStr);
      const res: ResponseResult = await TrainingApiService.getTrainingRecords(1, 10, todayStr, todayStr);
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const recordsArray: Object[] = apiData['records'] as Object[] ?? [];
        console.info('[DashboardPage] 获取到记录数量:', recordsArray.length);

        // 加载所有今日训练记录，支持一天多练
        const records: TrainingRecordModel[] = [];
        for (let i = 0; i < recordsArray.length; i++) {
          records.push(recordsArray[i] as TrainingRecordModel);
        }
        this.todayRecords = records;
      }
    } catch (err) {
      console.error('加载今日训练失败:', JSON.stringify(err));
    }
  }

  /**
   * 加载我的训练计划列表
   */
  async loadPlans(): Promise<void> {
    try {
      const res: ResponseResult = await PlanApiService.getFitnessPlans(1, 20, '');
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const plansArray: Object[] = apiData['plans'] as Object[] ?? [];
        const plans: FitnessPlanModel[] = [];
        for (let i: number = 0; i < plansArray.length; i++) {
          plans.push(plansArray[i] as FitnessPlanModel);
        }
        this.myPlans = plans;

        let activePlan: FitnessPlanModel | null = null;
        for (let j: number = 0; j < plans.length; j++) {
          if (plans[j].status === '进行中') {
            activePlan = plans[j];
            break;
          }
        }
        this.myPlan = activePlan ?? (plans.length > 0 ? plans[0] : null);
      } else {
        this.myPlans = [];
        this.myPlan = null;
      }
    } catch (err) {
      console.error('加载训练计划失败:', JSON.stringify(err));
      this.myPlans = [];
      this.myPlan = null;
    }
  }

  /**
   * 加载官方模板列表
   */
  async loadOfficialTemplates(): Promise<void> {
    try {
      const res: ResponseResult = await PlanApiService.getPlanTemplates(1, 20, '', '', '', '', 0, 0, true);
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const templatesArray: Object[] = apiData['templates'] as Object[] ?? [];
        const templates: PlanTemplateModel[] = [];
        for (let i: number = 0; i < templatesArray.length; i++) {
          templates.push(templatesArray[i] as PlanTemplateModel);
        }
        this.officialTemplates = templates;
      } else {
        this.officialTemplates = [];
      }
    } catch (err) {
      console.error('加载官方模板失败:', JSON.stringify(err));
      this.officialTemplates = [];
    }
  }

  /**
   * 加载个人模板列表
   */
  async loadPersonalTemplates(): Promise<void> {
    try {
      const res: ResponseResult = await PlanApiService.getPlanTemplates(1, 20, '', '', '', '', 0, 0, false);
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const templatesArray: Object[] = apiData['templates'] as Object[] ?? [];
        const templates: PlanTemplateModel[] = [];
        for (let i: number = 0; i < templatesArray.length; i++) {
          templates.push(templatesArray[i] as PlanTemplateModel);
        }
        this.personalTemplates = templates;
      } else {
        this.personalTemplates = [];
      }
    } catch (err) {
      console.error('加载个人模板失败:', JSON.stringify(err));
      this.personalTemplates = [];
    }
  }

  /**
   * 获取当前 Tab 对应的模板列表
   */
  private getTemplatesForCurrentTab(): PlanTemplateModel[] {
    if (this.templateTabIndex === 0) {
      return this.officialTemplates;
    }
    return this.personalTemplates;
  }

  /**
   * 获取模板数量显示文案
   */
  private getTemplateCountText(): string {
    if (this.templateTabIndex === 0) {
      return '官方模板 ' + this.officialTemplates.length.toString() + ' 个';
    }
    return '个人模板 ' + this.personalTemplates.length.toString() + ' 个';
  }

  build() {
    Column() {
      // 主内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 今日训练摘要
          this.TodaySummaryCard()

          // 今日计划安排与管理
          if (this.myPlan !== null) {
            this.TodayPlanSection(
              this.myPlan as FitnessPlanModel,
              this.getPlanTotalDays(this.myPlan as FitnessPlanModel),
              this.getTodayTrainingDay(this.myPlan as FitnessPlanModel),
              this.getUpcomingDays(this.myPlan as FitnessPlanModel, 3)
            )
            this.PlanManagementCard(
              this.myPlan as FitnessPlanModel,
              this.getPlanTotalDays(this.myPlan as FitnessPlanModel),
              this.getCurrentWeekDays(this.myPlan as FitnessPlanModel)
            )
          }

          // 我的全部计划
          if (this.myPlans.length > 0) {
            this.MyPlansSection()
          }

          // 官方/个人模板列表
          if (this.officialTemplates.length > 0 || this.personalTemplates.length > 0) {
            this.TemplateTabsSection()
          }

          // 本周训练趋势
          this.WeekTrendCard()

          // 快速添加按钮
          this.QuickAddButton()
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    // 顶部状态栏避让
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }

  @Builder
  TodaySummaryCard() {
    Column({ space: 12 }) {
      Row() {
        Text('今日训练')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        // 多条记录时显示当前索引
        if (this.todayRecords.length > 1) {
          Text((this.currentRecordIndex + 1).toString() + '/' + this.todayRecords.length.toString())
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
      }
      .width('100%')

      if (this.todayRecords.length > 0) {
        // 使用 Swiper 展示训练记录（支持一天多练滑动切换）
        Swiper() {
          ForEach(this.todayRecords, (record: TrainingRecordModel) => {
            this.TrainingRecordContent(record)
          })
        }
        .index(this.currentRecordIndex)
        .indicator(this.todayRecords.length > 1 ?
          new DotIndicator()
            .color($r('app.color.outline'))
            .selectedColor($r('app.color.brand_primary'))
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(6)
            .selectedItemHeight(6)
          : false)
        .loop(false)
        .onChange((index: number) => {
          this.currentRecordIndex = index;
        })
        .width('100%')
      } else {
        // 无训练记录
        Column({ space: 8 }) {
          Text('今天还没有训练记录')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))
          Text('点击下方按钮开始训练')
            .fontSize(12)
            .fontColor($r('app.color.text_placeholder'))
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 单条训练记录内容（Swiper 内部）
   */
  @Builder
  TrainingRecordContent(record: TrainingRecordModel) {
    Column({ space: 12 }) {
      // 训练标题和时间
      Row() {
        Text(record.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 6 }) {
          Text(this.formatTimeRange(record.startTime, record.endTime))
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))

          // 状态标签
          if (record.mood !== null && record.mood !== '') {
            Text(this.getMoodLabel(record.mood))
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor(this.getMoodColor(record.mood))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
          }
        }
        .flexShrink(0)
      }
      .width('100%')

      // 数据展示
      Row({ space: 12 }) {
        this.DataItem('时长', record.duration.toString() + '分钟', $r('app.color.color_success'))
        this.DataItem('组数', record.totalSets.toString() + '组', $r('app.color.color_warning'))
        this.DataItem('卡路里', record.caloriesBurned.toString(), $r('app.color.color_danger'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 继续训练按钮（简化样式）
      Text('继续训练 >')
        .fontSize(13)
        .fontColor($r('app.color.brand_primary'))
        .width('100%')
        .textAlign(TextAlign.End)
        .onClick(() => {
          RouterManager.pushPath(NavRoutes.TRAINING_SESSION, { recordId: record.id });
        })
    }
    .width('100%')
    .padding({ top: 4 })
  }

  /**
   * 格式化时间范围（只显示时分）
   */
  formatTimeRange(startTime: string, endTime: string): string {
    const startParts: string[] = startTime.split(' ');
    const endParts: string[] = endTime.split(' ');
    const startHHmmss: string = startParts.length > 1 ? startParts[1].substring(0, 8) : startTime;
    const endHHmmss: string = endParts.length > 1 ? endParts[1].substring(0, 8) : endTime;
    return startHHmmss + '-' + endHHmmss;
  }

  /**
   * 获取状态标签
   */
  getMoodLabel(mood: string): string {
    return mood || '';
  }

  /**
   * 获取状态颜色
   */
  getMoodColor(mood: string): Resource {
    if (mood === '优秀') {
      return $r('app.color.color_success');
    } else if (mood === '良好') {
      return $r('app.color.brand_primary');
    } else if (mood === '一般') {
      return $r('app.color.color_warning');
    } else if (mood === '疲劳') {
      return $r('app.color.color_danger');
    }
    return $r('app.color.text_hint');
  }

  @Builder
  DataItem(label: string, value: string, color: Resource) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor($r('app.color.card_background_secondary'))
    .borderRadius(8)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  WeekTrendCard() {
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
        // 本周统计概览
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

        // 简易柱状图
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
  WeekBarChart() {
    Column({ space: 8 }) {
      // 柱状图
      Row({ space: 4 }) {
        ForEach(this.weekStats, (dayStat: DailyStatsModel, index: number) => {
          this.BarItem(dayStat, index)
        })
      }
      .width('100%')
      .height(120)
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Bottom)

      // 日期标签
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
  BarItem(dayStat: DailyStatsModel, index: number) {
    Column() {
      // 柱子
      Column()
        .width(30)
        .height(dayStat.trainingCount > 0 ? (dayStat.duration > 0 ? Math.min(100, dayStat.duration) : 20) : 0)
        .backgroundColor(dayStat.trainingCount > 0 ? $r('app.color.brand_primary') : $r('app.color.outline'))
        .borderRadius(4)

      // 数值标签
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

  /**
   * 格式化日期标签（显示月/日）
   */
  formatDateLabel(dateStr: string): string {
    const parts: string[] = dateStr.split('-');
    if (parts.length === 3) {
      return parts[1] + '/' + parts[2];
    }
    return dateStr;
  }

  @Builder
  QuickAddButton() {
    Button('快速添加训练')
      .width('100%')
      .height(48)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .backgroundColor($r('app.color.brand_primary'))
      .borderRadius(10)
      .onClick(() => {
        RouterManager.pushPath(NavRoutes.TRAINING_SESSION);
      })
  }

  @Builder
  TodayPlanSection(
    plan: FitnessPlanModel,
    totalDays: number,
    todayDay: TrainingDayModel | null,
    upcomingDays: TrainingDayModel[]
  ) {
    Column({ space: 12 }) {
      Row() {
        Text('今日安排')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text('已完成 ' + plan.totalCompletedDays.toString() + ' | ' + totalDays.toString())
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      if (todayDay !== null) {
        Column({ space: 8 }) {
          Text(todayDay.dayName !== '' ? todayDay.dayName : '训练日')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Row({ space: 8 }) {
            this.PlanMetaTag('第' + todayDay.dayNumber.toString() + '天', true)
            if (todayDay.isRestDay) {
              this.PlanMetaTag('休息', false)
            } else {
              this.PlanMetaTag(todayDay.exercises.length.toString() + '个动作', false)
            }
            if (plan.goal) {
              this.PlanMetaTag('#' + plan.goal, false)
            }
          }

          if (todayDay.notes) {
            Text(todayDay.notes)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
      } else {
        Text('今天没有安排训练，休息一下或手动添加训练。')
          .fontSize(13)
          .fontColor($r('app.color.text_hint'))
      }

      if (upcomingDays.length > 0) {
        Column({ space: 6 }) {
          Text('即将到来')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_secondary'))

          ForEach(upcomingDays, (day: TrainingDayModel) => {
            Row() {
              Text('第' + day.dayNumber.toString() + '天 · ' + (day.dayName || '训练日'))
                .fontSize(12)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(day.isRestDay ? '休息' : '待训练')
                .fontSize(11)
                .fontColor(day.isRestDay ? $r('app.color.text_hint') : $r('app.color.brand_primary'))
            }
            .width('100%')
          }, (day: TrainingDayModel): string => day.dayNumber.toString())
        }
        .width('100%')
      }

      Row({ space: 10 }) {
        Button('开始训练')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(10)
          .onClick(() => {
            this.startPlanTraining(plan);
          })

        Button('计划介绍')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontColor($r('app.color.brand_primary'))
          .backgroundColor($r('app.color.brand_primary_light'))
          .borderRadius(10)
          .onClick(() => {
            this.openPlanDetail(plan);
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
  PlanManagementCard(
    plan: FitnessPlanModel,
    totalDays: number,
    weekDays: TrainingDayModel[]
  ) {
    Column({ space: 12 }) {
      Row() {
        Text('计划管理')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text('已完成 ' + plan.totalCompletedDays.toString() + ' | ' + totalDays.toString())
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      if (weekDays.length > 0) {
        this.WeeklyScheduleRow(plan, weekDays)
      } else {
        Text('当前计划暂未配置一周训练日。')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
      }

      Text('拖拽排序、设置撤销或整体延迟请进入计划详情中操作。')
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))

      Row({ space: 10 }) {
        Button('管理计划')
          .layoutWeight(1)
          .height(40)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(10)
          .onClick(() => {
            this.openPlanDetail(plan);
          })

        Button('延迟训练')
          .layoutWeight(1)
          .height(40)
          .fontSize(13)
          .fontColor($r('app.color.brand_primary'))
          .backgroundColor($r('app.color.brand_primary_light'))
          .borderRadius(10)
          .onClick(() => {
            this.delayPlan(plan);
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
  WeeklyScheduleRow(plan: FitnessPlanModel, weekDays: TrainingDayModel[]) {
    Scroll() {
      Row({ space: 12 }) {
        ForEach(weekDays, (day: TrainingDayModel) => {
          this.ScheduleDayItem(plan, day)
        }, (day: TrainingDayModel): string => day.dayNumber.toString())
      }
      .padding({ right: 8 })
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }

  @Builder
  ScheduleDayItem(plan: FitnessPlanModel, day: TrainingDayModel) {
    Column({ space: 6 }) {
      Column() {
        Text('D' + day.dayNumber.toString())
          .fontSize(11)
          .fontColor(this.getScheduleDayTextColor(plan, day))
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(this.getScheduleDayBgColor(plan, day))
      .borderRadius(12)

      Text(day.dayName || '训练日')
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(this.getPlanDayStatusLabel(
        this.isPlanDayCompleted(plan, day.dayNumber),
        this.isPlanDayToday(plan, day),
        day.isRestDay
      ))
        .fontSize(11)
        .fontColor(this.getScheduleDayStatusColor(plan, day))
    }
    .width(72)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MyPlansSection() {
    Column({ space: 12 }) {
      Row() {
        Text('全部计划')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(this.myPlans.length.toString() + ' 个')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      if (this.myPlans.length > 0) {
        Column({ space: 12 }) {
          ForEach(this.myPlans, (plan: FitnessPlanModel) => {
            this.PlanListItem(plan)
          }, (plan: FitnessPlanModel): string => plan.id.toString())
        }
        .width('100%')
      } else {
        Column({ space: 8 }) {
          Text('暂未创建任何计划')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
          Text('下方模板卡支持直接发起计划。')
            .fontSize(12)
            .fontColor($r('app.color.text_placeholder'))
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
      }
    }
    .width('100%')
  }

  @Builder
  PlanListItem(plan: FitnessPlanModel) {
    Column({ space: 8 }) {
      Row() {
        Text(plan.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(plan.status)
          .fontSize(11)
          .fontColor(Color.White)
          .backgroundColor(this.getStatusColor(plan.status))
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(6)
      }
      .width('100%')

      Row({ space: 12 }) {
        Text('完成 ' + plan.completionRate.toString() + '%')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        Text('周期 ' + plan.durationWeeks.toString() + '周')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        Text('每周 ' + plan.trainingDaysPerWeek.toString() + ' 天')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      if (plan.startDate && plan.endDate) {
        Text(plan.startDate + ' - ' + plan.endDate)
          .fontSize(11)
          .fontColor($r('app.color.text_hint'))
      }

      Row({ space: 10 }) {
        Button('今日训练')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(8)
          .onClick(() => {
            this.startPlanTraining(plan);
          })

        Button('计划详情')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .fontColor($r('app.color.brand_primary'))
          .backgroundColor($r('app.color.brand_primary_light'))
          .borderRadius(8)
          .onClick(() => {
            this.openPlanDetail(plan);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  TemplateTabsSection() {
    // this.getTemplateCountText(),
    // this.getTemplatesForCurrentTab(),
    // this.templateTabIndex === 1
    Column({ space: 12 }) {
      Row() {
        Text('训练模板')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(this.officialTemplates.length.toString() + ' 个')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      Row({ space: 8 }) {
        ForEach(this.templateTabTitles, (title: string, index: number) => {
          Text(title)
            .fontSize(13)
            .fontColor(this.templateTabIndex === index ? Color.White : $r('app.color.text_secondary'))
            .backgroundColor(this.templateTabIndex === index ?
              $r('app.color.brand_primary') : $r('app.color.card_background_secondary'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(18)
            .onClick(() => {
              this.templateTabIndex = index;
            })
        }, (title: string): string => title)
      }
      .width('100%')

      if (this.officialTemplates.length > 0) {
        Column({ space: 10 }) {
          ForEach(this.officialTemplates, (template: PlanTemplateModel) => {
            this.TemplateMiniCard(template, this.creatingTemplateId === template.id)
          }, (template: PlanTemplateModel): string => template.id.toString())
        }
        .width('100%')
      } else {
        Column({ space: 8 }) {
          Text(this.templateTabIndex === 1 ? '暂无个人模板' : '暂无官方模板')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
          if (this.templateTabIndex === 1) {
            Button('创建个人模板')
              .width('100%')
              .height(38)
              .fontSize(13)
              .backgroundColor($r('app.color.brand_primary'))
              .borderRadius(8)
              .onClick(() => {
                RouterManager.pushPath(NavRoutes.TEMPLATE_EDITOR, { isEdit: false });
              })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
      }
    }
    .width('100%')
  }

  @Builder
  TemplateMiniCard(template: PlanTemplateModel, isCreating: boolean) {
    Column({ space: 8 }) {
      Row() {
        Text(template.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 6 }) {
          Text(template.level)
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.getLevelColor(template.level))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
          if (template.isOfficial) {
            Text('官方')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.brand_primary'))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
          }
        }
      }
      .width('100%')

      if (template.description) {
        Text(template.description)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      Row({ space: 6 }) {
        this.PlanMetaTag('#' + template.goal, false)
        this.PlanMetaTag(template.durationWeeks.toString() + '周', false)
        this.PlanMetaTag('每周' + template.trainingDaysPerWeek.toString() + '天', false)
      }
      .width('100%')

      Row({ space: 10 }) {
        Button('查看介绍')
          .layoutWeight(1)
          .height(34)
          .fontSize(12)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(8)
          .onClick(() => {
            this.viewTemplateDetail(template);
          })

        Button(isCreating ? '发起中...' : '发起计划')
          .layoutWeight(1)
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(8)
          .enabled(!isCreating)
          .onClick(() => {
            this.quickStartPlanFromTemplate(template);
          })
      }
      .width('100%')

      Text('直接发起默认以今天为开始日期，可在计划详情中调整。')
        .fontSize(10)
        .fontColor($r('app.color.text_hint'))
    }
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .onClick(() => {
      this.viewTemplateDetail(template);
    })
  }

  @Builder
  PlanMetaTag(text: string, accent: boolean = false) {
    Text(text)
      .fontSize(11)
      .fontColor(accent ? Color.White : $r('app.color.text_secondary'))
      .backgroundColor(accent ? $r('app.color.brand_primary') : $r('app.color.card_background_secondary'))
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .borderRadius(12)
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

  /**
   * 获取难度等级颜色
   */
  getLevelColor(level: string): Resource {
    if (level === '初级') {
      return $r('app.color.color_success');
    } else if (level === '中级') {
      return $r('app.color.color_warning');
    } else if (level === '高级') {
      return $r('app.color.color_danger');
    }
    return $r('app.color.text_hint');
  }

  openPlanDetail(plan: FitnessPlanModel): void {
    RouterManager.pushPath(NavRoutes.PLAN_DETAIL, { planId: plan.id });
  }

  startPlanTraining(plan: FitnessPlanModel): void {
    RouterManager.pushPath(NavRoutes.TRAINING_SESSION, { planId: plan.id });
  }

  delayPlan(plan: FitnessPlanModel): void {
    this.openPlanDetail(plan);
  }

  viewTemplateDetail(template: PlanTemplateModel): void {
    RouterManager.pushPath(NavRoutes.TEMPLATE_DETAIL, { templateId: template.id });
  }

  async quickStartPlanFromTemplate(template: PlanTemplateModel): Promise<void> {
    if (this.creatingTemplateId === template.id) {
      return;
    }
    this.creatingTemplateId = template.id;
    try {
      const todayStr: string = this.formatDateString(new Date());
      const res: ResponseResult =
        await PlanApiService.createPlanFromTemplate(template.id, todayStr, template.name);
      if (res.code === 0) {
        toast('已根据模板发起计划');
        this.loadPlans();
      } else {
        toast(res.message ?? '创建失败');
      }
    } catch (err) {
      console.error('直接发起计划失败:', JSON.stringify(err));
      toast('创建失败');
    } finally {
      this.creatingTemplateId = 0;
    }
  }

  formatDateString(date: Date): string {
    const year: string = date.getFullYear().toString();
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    return year + '-' + month + '-' + day;
  }

  getPlanTotalDays(plan: FitnessPlanModel): number {
    if (plan.durationWeeks > 0 && plan.trainingDaysPerWeek > 0) {
      return plan.durationWeeks * plan.trainingDaysPerWeek;
    }
    if (plan.trainingDays.length > 0) {
      return plan.trainingDays.length;
    }
    if (plan.trainingDaysPerWeek > 0) {
      return plan.trainingDaysPerWeek;
    }
    return 1;
  }

  getCurrentTrainingDayNumber(plan: FitnessPlanModel): number {
    let dayNumber: number = plan.currentDay > 0 ? plan.currentDay : 1;
    if (dayNumber <= 0 && plan.completedDays.length > 0) {
      dayNumber = plan.completedDays[plan.completedDays.length - 1] + 1;
    }
    const totalDays: number = Math.max(this.getPlanTotalDays(plan), 1);
    if (dayNumber > totalDays) {
      return totalDays;
    }
    return dayNumber > 0 ? dayNumber : 1;
  }

  getTodayTrainingDay(plan: FitnessPlanModel): TrainingDayModel | null {
    const dayNumber: number = this.getCurrentTrainingDayNumber(plan);
    for (let i: number = 0; i < plan.trainingDays.length; i++) {
      if (plan.trainingDays[i].dayNumber === dayNumber) {
        return plan.trainingDays[i];
      }
    }
    return null;
  }

  getUpcomingDays(plan: FitnessPlanModel, count: number): TrainingDayModel[] {
    const dayNumber: number = this.getCurrentTrainingDayNumber(plan);
    const upcoming: TrainingDayModel[] = [];
    for (let i: number = 0; i < plan.trainingDays.length; i++) {
      const day: TrainingDayModel = plan.trainingDays[i];
      if (day.dayNumber > dayNumber) {
        upcoming.push(day);
      }
      if (upcoming.length >= count) {
        break;
      }
    }
    return upcoming;
  }

  getCurrentWeekDays(plan: FitnessPlanModel): TrainingDayModel[] {
    const daysPerWeek: number = plan.trainingDaysPerWeek > 0 ? plan.trainingDaysPerWeek : 7;
    if (plan.trainingDays.length === 0) {
      return [];
    }
    const currentWeek: number = plan.currentWeek > 0 ? plan.currentWeek : 1;
    const startIndex: number = (currentWeek - 1) * daysPerWeek;
    const endIndex: number = startIndex + daysPerWeek;
    let weekDays: TrainingDayModel[] =
      plan.trainingDays.slice(startIndex, Math.min(endIndex, plan.trainingDays.length));
    if (weekDays.length === 0) {
      weekDays = plan.trainingDays.slice(0, Math.min(daysPerWeek, plan.trainingDays.length));
    }
    return weekDays;
  }

  isPlanDayCompleted(plan: FitnessPlanModel, dayNumber: number): boolean {
    return plan.completedDays.indexOf(dayNumber) !== -1;
  }

  getPlanDayStatusLabel(isCompleted: boolean, isToday: boolean, isRest: boolean): string {
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

  private isPlanDayToday(plan: FitnessPlanModel, day: TrainingDayModel): boolean {
    return day.dayNumber === this.getCurrentTrainingDayNumber(plan);
  }

  private getScheduleDayBgColor(plan: FitnessPlanModel, day: TrainingDayModel): Resource {
    if (this.isPlanDayCompleted(plan, day.dayNumber)) {
      return $r('app.color.brand_primary');
    }
    if (this.isPlanDayToday(plan, day)) {
      return $r('app.color.color_warning');
    }
    if (day.isRestDay) {
      return $r('app.color.card_background_secondary');
    }
    return $r('app.color.outline');
  }

  private getScheduleDayTextColor(plan: FitnessPlanModel, day: TrainingDayModel): ResourceColor {
    if (this.isPlanDayCompleted(plan, day.dayNumber) || this.isPlanDayToday(plan, day)) {
      return Color.White;
    }
    return $r('app.color.text_primary');
  }

  private getScheduleDayStatusColor(plan: FitnessPlanModel, day: TrainingDayModel): Resource {
    if (this.isPlanDayCompleted(plan, day.dayNumber)) {
      return $r('app.color.color_success');
    }
    if (this.isPlanDayToday(plan, day)) {
      return $r('app.color.color_warning');
    }
    return $r('app.color.text_hint');
  }
}
