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
  TrainingStatsModel,
  toast,
  RouterManager,
  NavRoutes
} from '@tbs/common';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

@Component
export struct DashboardPage {
  @State todayRecord: TrainingRecordModel | null = null
  @State weekStats: DailyStatsModel[] = []
  @State weekTotalCount: number = 0
  @State weekTotalDuration: number = 0
  @State weekTotalWeight: number = 0
  @State myPlan: FitnessPlanModel | null = null
  @State recommendedTemplates: PlanTemplateModel[] = []
  @State isLoading: boolean = false
  @StorageProp('topRectHeight') topRectHeight: number = 0

  aboutToAppear(): void {
    this.loadData();
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // 并行加载所有数据
      await Promise.all([
        this.loadWeekStats(),
        this.loadTodayRecord(),
        this.loadMyPlan(),
        this.loadRecommendedTemplates()
      ]);
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
   * 加载今天的训练记录
   */
  async loadTodayRecord(): Promise<void> {
    try {
      const today: Date = new Date();
      const todayStr: string = today.getFullYear() + '-' +
        (today.getMonth() + 1).toString().padStart(2, '0') + '-' +
        today.getDate().toString().padStart(2, '0');

      const res: ResponseResult = await TrainingApiService.getTrainingRecords(1, 10, todayStr, todayStr);
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const recordsArray: Object[] = apiData['records'] as Object[] ?? [];
        if (recordsArray.length > 0) {
          this.todayRecord = recordsArray[0] as TrainingRecordModel;
        }
      }
    } catch (err) {
      console.error('加载今日训练失败:', JSON.stringify(err));
    }
  }

  /**
   * 加载我的训练计划
   */
  async loadMyPlan(): Promise<void> {
    try {
      const res: ResponseResult = await PlanApiService.getFitnessPlans(1, 10, '进行中');
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const plansArray: Object[] = apiData['plans'] as Object[] ?? [];
        if (plansArray.length > 0) {
          this.myPlan = plansArray[0] as FitnessPlanModel;
        }
      }
    } catch (err) {
      console.error('加载训练计划失败:', JSON.stringify(err));
    }
  }

  /**
   * 加载推荐模板
   */
  async loadRecommendedTemplates(): Promise<void> {
    try {
      const res: ResponseResult = await PlanApiService.getPlanTemplates(1, 2);
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const templatesArray: Object[] = apiData['templates'] as Object[] ?? [];
        this.recommendedTemplates = templatesArray as PlanTemplateModel[];
      }
    } catch (err) {
      console.error('加载推荐模板失败:', JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 主内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 今日训练摘要
          this.TodaySummaryCard()

          // 我的训练计划
          if (this.myPlan !== null) {
            this.MyPlanCard()
          }

          // 推荐训练模板
          if (this.recommendedTemplates.length > 0) {
            this.RecommendedTemplatesCard()
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
      Text('今日训练')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      if (this.todayRecord !== null) {
        // 显示今日训练数据
        Column({ space: 16 }) {
          // 训练标题
          Text(this.todayRecord.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          // 数据卡片
          Row({ space: 12 }) {
            this.DataItem('时长', this.todayRecord.duration.toString() + '分钟', $r('app.color.color_success'))
            this.DataItem('组数', this.todayRecord.totalSets.toString() + '组', $r('app.color.color_warning'))
            this.DataItem('卡路里', this.todayRecord.caloriesBurned.toString(), $r('app.color.color_danger'))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          // 状态和时间
          Row({ space: 8 }) {
            Text('状态: ' + this.todayRecord.mood)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
            Text('|')
              .fontSize(13)
              .fontColor($r('app.color.text_placeholder'))
            Text(this.todayRecord.startTime + ' - ' + this.todayRecord.endTime)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
        }
        .width('100%')
        .padding({ top: 12 })
      } else {
        // 无训练记录
        Text('暂无训练记录')
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
  MyPlanCard() {
    Column({ space: 12 }) {
      Row() {
        Text('我的训练计划')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(this.myPlan?.status ?? '')
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(this.getStatusColor(this.myPlan?.status ?? ''))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')

      // 计划名称
      Text(this.myPlan?.name ?? '')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      // 进度条
      Column({ space: 6 }) {
        Row() {
          Text('完成进度')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
          Blank()
          Text((this.myPlan?.completionRate ?? 0).toString() + '%')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.brand_primary'))
        }
        .width('100%')

        // 进度条
        Row() {
          Row()
            .width((this.myPlan?.completionRate ?? 0).toString() + '%')
            .height('100%')
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(2)
        }
        .width('100%')
        .height(6)
        .backgroundColor($r('app.color.outline'))
        .borderRadius(3)
      }
      .width('100%')

      // 统计信息
      Row({ space: 12 }) {
        Column({ space: 2 }) {
          Text((this.myPlan?.totalCompletedDays ?? 0).toString() + '天')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_primary'))
          Text('已完成')
            .fontSize(10)
            .fontColor($r('app.color.text_hint'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 2 }) {
          Text('第' + (this.myPlan?.currentWeek ?? 0).toString() + '周')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_primary'))
          Text('本周')
            .fontSize(10)
            .fontColor($r('app.color.text_hint'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 2 }) {
          Text(this.myPlan?.goal ?? '')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_primary'))
          Text('目标')
            .fontSize(10)
            .fontColor($r('app.color.text_hint'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      // 按钮
      Button('继续训练')
        .width('100%')
        .height(38)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.color_success'))
        .borderRadius(8)
        .margin({ top: 4 })
        .onClick(() => {
          toast('继续训练计划');
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RecommendedTemplatesCard() {
    Column({ space: 12 }) {
      Row() {
        Text('推荐训练模板')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text('查看更多 >')
          .fontSize(13)
          .fontColor($r('app.color.brand_primary'))
          .onClick(() => {
            toast('查看更多模板');
          })
      }
      .width('100%')

      // 模板列表
      Column({ space: 8 }) {
        ForEach(this.recommendedTemplates, (template: PlanTemplateModel) => {
          this.TemplateCard(template)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TemplateCard(template: PlanTemplateModel) {
    Column({ space: 8 }) {
      Row() {
        Text(template.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        Text(template.level)
          .fontSize(11)
          .fontColor(Color.White)
          .backgroundColor(this.getLevelColor(template.level))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(3)
      }
      .width('100%')

      Text(template.description)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: 8 }) {
        Text('#' + template.goal)
          .fontSize(10)
          .fontColor($r('app.color.text_hint'))
        Text('|')
          .fontSize(10)
          .fontColor($r('app.color.text_placeholder'))
        Text(template.durationWeeks.toString() + '周')
          .fontSize(10)
          .fontColor($r('app.color.text_hint'))
        Text('|')
          .fontSize(10)
          .fontColor($r('app.color.text_placeholder'))
        Text('每周' + template.trainingDaysPerWeek.toString() + '天')
          .fontSize(10)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background_secondary'))
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      toast('使用模板: ' + template.name);
    })
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
}
