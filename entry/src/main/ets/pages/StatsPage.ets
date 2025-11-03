/**
 * 数据分析页面 - Stats
 * 图表展示训练趋势、周/月汇总
 */

import {
  MockDataService,
  TrainingStatsModel,
  DailyStatsModel,
  MuscleGroupStatsModel,
  StatsPeriodConst
} from '@tbs/common';

@Component
export struct StatsPage {
  @State currentPeriod: string = StatsPeriodConst.WEEK
  @State stats: TrainingStatsModel | null = null
  @State muscleGroupStats: MuscleGroupStatsModel[] = []

  aboutToAppear(): void {
    this.loadData();
  }

  /**
   * 加载数据
   */
  loadData(): void {
    this.stats = MockDataService.getMockTrainingStats(this.currentPeriod);
    this.muscleGroupStats = MockDataService.getMockMuscleGroupStats();
  }

  /**
   * 切换时间周期
   */
  switchPeriod(period: string): void {
    this.currentPeriod = period;
    this.loadData();
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('数据分析')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 主内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 时间范围选择
          Row({ space: 8 }) {
            Button('周')
              .fontSize(14)
              .backgroundColor(this.currentPeriod === StatsPeriodConst.WEEK ? '#007AFF' : '#E0E0E0')
              .fontColor(this.currentPeriod === StatsPeriodConst.WEEK ? Color.White : '#333333')
              .height(32)
              .layoutWeight(1)
              .onClick(() => {
                this.switchPeriod(StatsPeriodConst.WEEK);
              })

            Button('月')
              .fontSize(14)
              .backgroundColor(this.currentPeriod === StatsPeriodConst.MONTH ? '#007AFF' : '#E0E0E0')
              .fontColor(this.currentPeriod === StatsPeriodConst.MONTH ? Color.White : '#333333')
              .height(32)
              .layoutWeight(1)
              .onClick(() => {
                this.switchPeriod(StatsPeriodConst.MONTH);
              })

            Button('年')
              .fontSize(14)
              .backgroundColor(this.currentPeriod === StatsPeriodConst.YEAR ? '#007AFF' : '#E0E0E0')
              .fontColor(this.currentPeriod === StatsPeriodConst.YEAR ? Color.White : '#333333')
              .height(32)
              .layoutWeight(1)
              .onClick(() => {
                this.switchPeriod(StatsPeriodConst.YEAR);
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })

          // 数据概览卡片
          if (this.stats !== null) {
            this.StatsOverviewCard()
          }

          // 训练次数趋势图
          if (this.stats !== null && this.stats.dailyStats.length > 0) {
            this.TrainingCountChart()
          }

          // 肌肉部位训练分布
          if (this.muscleGroupStats.length > 0) {
            this.MuscleGroupChart()
          }

          // 底部间距
          Column()
            .height(20)
        }
        .width('100%')
        .padding({ bottom: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StatsOverviewCard() {
    Column({ space: 12 }) {
      Text(this.getPeriodTitle() + '数据概览')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      Row({ space: 20 }) {
        Column({ space: 4 }) {
          Text((this.stats?.totalTrainingCount ?? 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          Text('训练次数')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text((this.stats?.totalDuration ?? 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#34C759')
          Text('训练时长(分钟)')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text((this.stats?.totalWeight ?? 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9500')
          Text('总重量(kg)')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ top: 8 })

      // 卡路里
      Row() {
        Column({ space: 4 }) {
          Text((this.stats?.totalCalories ?? 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF3B30')
          Text('消耗卡路里')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text((this.stats?.avgDuration ?? 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5AC8FA')
          Text('平均时长(分钟)')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text((this.stats?.totalSets ?? 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#AF52DE')
          Text('总组数')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TrainingCountChart() {
    Column({ space: 12 }) {
      Text('训练次数趋势')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)

      // 简易柱状图
      Column({ space: 8 }) {
        // 柱状图
        Row({ space: 4 }) {
          ForEach(this.stats?.dailyStats ?? [], (dayStat: DailyStatsModel, index: number) => {
            this.BarItem(dayStat, index)
          })
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Bottom)

        // 日期标签
        Row({ space: 4 }) {
          ForEach(this.stats?.dailyStats ?? [], (dayStat: DailyStatsModel) => {
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
      .padding(12)
      .backgroundColor('#F9F9F9')
      .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  BarItem(dayStat: DailyStatsModel, index: number) {
    Column() {
      // 柱子
      Column()
        .width(30)
        .height(dayStat.trainingCount > 0 ?
          (dayStat.duration > 0 ? Math.min(100, dayStat.duration) : 20) : 0)
        .backgroundColor(dayStat.trainingCount > 0 ? '#007AFF' : '#E0E0E0')
        .borderRadius(4)

      // 数值标签
      if (dayStat.trainingCount > 0) {
        Text(dayStat.trainingCount.toString())
          .fontSize(10)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MuscleGroupChart() {
    Column({ space: 12 }) {
      Text('肌肉部位训练分布')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)

      Column({ space: 8 }) {
        ForEach(this.muscleGroupStats, (muscleGroupStat: MuscleGroupStatsModel) => {
          this.MuscleGroupItem(muscleGroupStat)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  MuscleGroupItem(muscleGroupStat: MuscleGroupStatsModel) {
    Row({ space: 12 }) {
      Text(muscleGroupStat.muscleGroup)
        .fontSize(14)
        .fontColor('#333333')
        .width(60)

      // 进度条
      Row() {
        Row()
          .width(muscleGroupStat.percentage.toString() + '%')
          .height('100%')
          .backgroundColor(this.getMuscleGroupColor(muscleGroupStat.muscleGroup))
          .borderRadius(2)
      }
      .layoutWeight(1)
      .height(8)
      .backgroundColor('#E0E0E0')
      .borderRadius(4)

      Text(muscleGroupStat.trainingCount.toString() + '次')
        .fontSize(12)
        .fontColor('#666666')
        .width(40)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 获取肌肉部位颜色
   */
  getMuscleGroupColor(name: string): string {
    const colors: string[] = [
      '#007AFF', '#34C759', '#FF9500', '#FF3B30',
      '#5AC8FA', '#AF52DE', '#FFCC00'
    ];
    const index: number = name.charCodeAt(0) % colors.length;
    return colors[index];
  }

  /**
   * 获取周期标题
   */
  getPeriodTitle(): string {
    if (this.currentPeriod === StatsPeriodConst.WEEK) {
      return '本周';
    } else if (this.currentPeriod === StatsPeriodConst.MONTH) {
      return '本月';
    } else if (this.currentPeriod === StatsPeriodConst.YEAR) {
      return '本年';
    }
    return '';
  }

  /**
   * 格式化日期标签
   */
  formatDateLabel(dateStr: string): string {
    const parts: string[] = dateStr.split('-');
    if (parts.length === 3) {
      return parts[1] + '/' + parts[2];
    }
    return dateStr;
  }
}
