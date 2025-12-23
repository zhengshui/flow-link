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
import { DashboardTodaySummaryCard } from './dashboard/DashboardTodaySummaryCard';
import { DashboardWeekTrendCard } from './dashboard/DashboardWeekTrendCard';
import { DashboardTodayPlanSection, DashboardPlanManagementCard } from './dashboard/DashboardPlanCards';
import { DashboardTemplateTabsSection } from './dashboard/DashboardTemplateTabsSection';
import { DashboardQuickAddButton } from './dashboard/DashboardQuickAddButton';

@Component
export struct DashboardPage {
  @State todayRecords: TrainingRecordModel[] = []
  @State currentRecordIndex: number = 0
  @State weekStats: DailyStatsModel[] = []
  @State weekTotalCount: number = 0
  @State weekTotalDuration: number = 0
  @State weekTotalWeight: number = 0
  @State myPlan: FitnessPlanModel | null = null
  @State officialTemplates: PlanTemplateModel[] = []
  @State personalTemplates: PlanTemplateModel[] = []
  @State templateTabIndex: number = 0
  @State creatingTemplateId: string = ''
  @State isLoading: boolean = false
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageLink('refreshDashboardTimestamp') @Watch('onRefreshTimestampChange') refreshTimestamp: number = 0

  aboutToAppear(): void {
    AppStorage.setOrCreate<number>('refreshDashboardTimestamp', 0);
    this.loadData();
  }

  onRefreshTimestampChange(): void {
    if (this.refreshTimestamp > 0) {
      console.info('[DashboardPage] 检测到刷新时间戳变化，刷新数据');
      this.loadData();
    }
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    this.todayRecords = [];
    this.weekStats = [];
    this.weekTotalCount = 0;
    this.weekTotalDuration = 0;
    this.weekTotalWeight = 0;
    console.info('[DashboardPage] loadData - 状态已重置，开始加载数据');
    try {
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

        const records: TrainingRecordModel[] = [];
        for (let i: number = 0; i < recordsArray.length; i++) {
          records.push(recordsArray[i] as TrainingRecordModel);
        }
        this.todayRecords = records;
      }
    } catch (err) {
      console.error('加载今日训练失败:', JSON.stringify(err));
    }
  }

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
        let activePlan: FitnessPlanModel | null = null;
        for (let j: number = 0; j < plans.length; j++) {
          if (plans[j].status === '进行中') {
            activePlan = plans[j];
            break;
          }
        }
        this.myPlan = activePlan ?? (plans.length > 0 ? plans[0] : null);
      } else {
        this.myPlan = null;
      }
    } catch (err) {
      console.error('加载训练计划失败:', JSON.stringify(err));
      this.myPlan = null;
    }
  }

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

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          DashboardTodaySummaryCard({
            todayRecords: this.todayRecords,
            currentRecordIndex: $currentRecordIndex
          })

          if (this.myPlan !== null) {
            DashboardTodayPlanSection({
              plan: this.myPlan as FitnessPlanModel,
              todayDay: this.getTodayTrainingDay(this.myPlan as FitnessPlanModel),
              onStartTraining: (selectedPlan: FitnessPlanModel, selectedDay: TrainingDayModel | null): void => {
                this.startPlanTraining(selectedPlan, selectedDay);
              }
            })

            DashboardPlanManagementCard({
              plan: this.myPlan as FitnessPlanModel,
              totalDays: this.getPlanTotalDays(this.myPlan as FitnessPlanModel),
              weekDays: this.getCurrentWeekDays(this.myPlan as FitnessPlanModel),
              currentDayNumber: this.getCurrentTrainingDayNumber(this.myPlan as FitnessPlanModel),
              onOpenPlanDetail: (selectedPlan: FitnessPlanModel): void => {
                this.openPlanDetail(selectedPlan);
              }
            })
          }

          if (this.officialTemplates.length > 0 || this.personalTemplates.length > 0) {
            DashboardTemplateTabsSection({
              officialTemplates: this.officialTemplates,
              personalTemplates: this.personalTemplates,
              templateTabIndex: this.templateTabIndex,
              onViewTemplateDetail: (template: PlanTemplateModel): void => {
                this.viewTemplateDetail(template);
              },
              onCreatePersonalTemplate: (): void => {
                RouterManager.pushPath(NavRoutes.TEMPLATE_EDITOR, { isEdit: false });
              }
            })
          }

          DashboardWeekTrendCard({
            weekStats: this.weekStats,
            weekTotalCount: this.weekTotalCount,
            weekTotalDuration: this.weekTotalDuration,
            weekTotalWeight: this.weekTotalWeight
          })

          DashboardQuickAddButton({
            onQuickAdd: (): void => {
              RouterManager.pushPath(NavRoutes.TRAINING_SESSION);
            }
          })
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
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }

  openPlanDetail(plan: FitnessPlanModel): void {
    RouterManager.pushPath(NavRoutes.PLAN_DETAIL, { planId: plan.id });
  }

  startPlanTraining(plan: FitnessPlanModel, day: TrainingDayModel | null = null): void {
    let dayNumber: number = 0;
    if (day !== null) {
      dayNumber = day.dayNumber;
    } else {
      dayNumber = this.getCurrentTrainingDayNumber(plan);
    }
    if (dayNumber > 0) {
      RouterManager.pushPath(NavRoutes.TRAINING_SESSION, { planId: plan.id, dayNumber: dayNumber });
      return;
    }
    RouterManager.pushPath(NavRoutes.TRAINING_SESSION, { planId: plan.id });
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
      this.creatingTemplateId = '';
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
}
