/**
 * 首页 - Dashboard
 * 显示训练概览、进度统计
 */

import {
  TrainingRecordModel,
  MockDataService,
  DailyStatsModel,
  FitnessPlanModel,
  PlanTemplateModel,
  toast
} from '@tbs/common';
import { router } from '@kit.ArkUI';

@Component
export struct DashboardPage {
  @State todayRecord: TrainingRecordModel | null = null
  @State weekStats: DailyStatsModel[] = []
  @State weekTotalCount: number = 0
  @State weekTotalDuration: number = 0
  @State weekTotalWeight: number = 0
  @State myPlan: FitnessPlanModel | null = null
  @State recommendedTemplates: PlanTemplateModel[] = []

  aboutToAppear(): void {
    this.loadData();
  }

  /**
   * 加载数据
   */
  loadData(): void {
    // 获取所有训练记录
    const allRecords: TrainingRecordModel[] = MockDataService.getMockTrainingRecords();

    // 获取今天的训练记录
    const today: string = MockDataService.getTodayString();
    for (let i: number = 0; i < allRecords.length; i++) {
      if (allRecords[i].date === today) {
        this.todayRecord = allRecords[i];
        break;
      }
    }

    // 获取本周统计数据
    const weekStatsData: DailyStatsModel[] = [];
    let totalCount: number = 0;
    let totalDuration: number = 0;
    let totalWeight: number = 0;

    for (let i: number = 6; i >= 0; i--) {
      const dateStr: string = MockDataService.getDaysAgo(i);
      let found: boolean = false;

      for (let j: number = 0; j < allRecords.length; j++) {
        const record: TrainingRecordModel = allRecords[j];
        if (record.date === dateStr) {
          weekStatsData.push(new DailyStatsModel(
            dateStr,
            1,
            record.duration,
            record.totalWeight,
            record.totalSets,
            record.caloriesBurned
          ));
          totalCount++;
          totalDuration += record.duration;
          totalWeight += record.totalWeight;
          found = true;
          break;
        }
      }

      if (!found) {
        weekStatsData.push(new DailyStatsModel(dateStr, 0, 0, 0, 0, 0));
      }
    }

    this.weekStats = weekStatsData;
    this.weekTotalCount = totalCount;
    this.weekTotalDuration = totalDuration;
    this.weekTotalWeight = totalWeight;

    // 获取我的训练计划（进行中的）
    const allPlans: FitnessPlanModel[] = MockDataService.getMockUserPlans();
    for (let i: number = 0; i < allPlans.length; i++) {
      if (allPlans[i].status === '进行中') {
        this.myPlan = allPlans[i];
        break;
      }
    }

    // 获取推荐的训练模板（取前2个）
    const allTemplates: PlanTemplateModel[] = MockDataService.getMockPlanTemplates();
    const recommended: PlanTemplateModel[] = [];
    for (let i: number = 0; i < allTemplates.length && i < 2; i++) {
      recommended.push(allTemplates[i]);
    }
    this.recommendedTemplates = recommended;
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
    .backgroundColor('#F5F5F5')
  }

  @Builder
  TodaySummaryCard() {
    Column({ space: 12 }) {
      Text('今日训练')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      if (this.todayRecord !== null) {
        // 显示今日训练数据
        Column({ space: 16 }) {
          // 训练标题
          Text(this.todayRecord.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          // 数据卡片
          Row({ space: 12 }) {
            this.DataItem('时长', this.todayRecord.duration.toString() + '分钟', '#4CAF50')
            this.DataItem('组数', this.todayRecord.totalSets.toString() + '组', '#FF9800')
            this.DataItem('卡路里', this.todayRecord.caloriesBurned.toString(), '#F44336')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          // 状态和时间
          Row({ space: 8 }) {
            Text('状态: ' + this.todayRecord.mood)
              .fontSize(13)
              .fontColor('#666666')
            Text('|')
              .fontSize(13)
              .fontColor('#CCCCCC')
            Text(this.todayRecord.startTime + ' - ' + this.todayRecord.endTime)
              .fontSize(13)
              .fontColor('#666666')
          }
          .width('100%')
        }
        .width('100%')
        .padding({ top: 12 })
      } else {
        // 无训练记录
        Text('暂无训练记录')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 20, bottom: 20 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DataItem(label: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor('#999999')
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor('#F9F9F9')
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
        Blank()
        Text(this.weekTotalCount.toString() + '次训练')
          .fontSize(13)
          .fontColor('#666666')
      }
      .width('100%')

      if (this.weekTotalCount > 0) {
        // 本周统计概览
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(this.weekTotalDuration.toString())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#007AFF')
            Text('总时长(分钟)')
              .fontSize(11)
              .fontColor('#999999')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text(this.weekTotalWeight.toString())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9800')
            Text('总重量(kg)')
              .fontSize(11)
              .fontColor('#999999')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text(this.weekTotalCount.toString())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')
            Text('训练次数')
              .fontSize(11)
              .fontColor('#999999')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })

        // 简易柱状图
        this.WeekBarChart()
      } else {
        Text('开始记录训练，查看进度趋势')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 20, bottom: 20 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
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
            .fontColor('#999999')
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
        .backgroundColor(dayStat.trainingCount > 0 ? '#007AFF' : '#E0E0E0')
        .borderRadius(4)

      // 数值标签
      if (dayStat.trainingCount > 0) {
        Text(dayStat.duration.toString())
          .fontSize(10)
          .fontColor('#666666')
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
      .fontSize(16)
      .backgroundColor('#007AFF')
      .borderRadius(8)
      .onClick(() => {
        // TODO: 跳转到添加训练页面
        console.info('点击快速添加训练')
      })
  }

  @Builder
  MyPlanCard() {
    Column({ space: 12 }) {
      Row() {
        Text('我的训练计划')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
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
        .fontColor('#333333')

      // 进度条
      Column({ space: 6 }) {
        Row() {
          Text('完成进度')
            .fontSize(12)
            .fontColor('#666666')
          Blank()
          Text((this.myPlan?.completionRate ?? 0).toString() + '%')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#007AFF')
        }
        .width('100%')

        // 进度条
        Row() {
          Row()
            .width((this.myPlan?.completionRate ?? 0).toString() + '%')
            .height('100%')
            .backgroundColor('#007AFF')
            .borderRadius(2)
        }
        .width('100%')
        .height(6)
        .backgroundColor('#E0E0E0')
        .borderRadius(3)
      }
      .width('100%')

      // 统计信息
      Row({ space: 12 }) {
        Column({ space: 2 }) {
          Text((this.myPlan?.totalCompletedDays ?? 0).toString() + '天')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          Text('已完成')
            .fontSize(10)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 2 }) {
          Text('第' + (this.myPlan?.currentWeek ?? 0).toString() + '周')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          Text('本周')
            .fontSize(10)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 2 }) {
          Text(this.myPlan?.goal ?? '')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          Text('目标')
            .fontSize(10)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      // 按钮
      Button('继续训练')
        .width('100%')
        .height(36)
        .fontSize(14)
        .backgroundColor('#4CAF50')
        .borderRadius(6)
        .margin({ top: 4 })
        .onClick(() => {
          toast('继续训练计划');
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
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
        Blank()
        Text('查看更多 >')
          .fontSize(13)
          .fontColor('#007AFF')
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
    .backgroundColor(Color.White)
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
          .fontColor('#333333')
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
        .fontColor('#666666')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: 8 }) {
        Text('#' + template.goal)
          .fontSize(10)
          .fontColor('#999999')
        Text('|')
          .fontSize(10)
          .fontColor('#CCCCCC')
        Text(template.durationWeeks.toString() + '周')
          .fontSize(10)
          .fontColor('#999999')
        Text('|')
          .fontSize(10)
          .fontColor('#CCCCCC')
        Text('每周' + template.trainingDaysPerWeek.toString() + '天')
          .fontSize(10)
          .fontColor('#999999')
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F9F9F9')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      toast('使用模板: ' + template.name);
    })
  }

  /**
   * 获取计划状态颜色
   */
  getStatusColor(status: string): string {
    if (status === '进行中') {
      return '#4CAF50';
    } else if (status === '已完成') {
      return '#2196F3';
    } else if (status === '已暂停') {
      return '#FF9800';
    }
    return '#999999';
  }

  /**
   * 获取难度等级颜色
   */
  getLevelColor(level: string): string {
    if (level === '初级') {
      return '#4CAF50';
    } else if (level === '中级') {
      return '#FF9800';
    } else if (level === '高级') {
      return '#F44336';
    }
    return '#999999';
  }
}
