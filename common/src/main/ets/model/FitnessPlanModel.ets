import { TrainingDayModel } from './PlanTemplateModel';

/**
 * 用户健身计划模型
 * 用户基于模板创建或自定义的训练计划
 */
export class FitnessPlanModel {
  id: number = 0                      // 计划ID
  userId: number = 0                  // 用户ID
  templateId: number = 0              // 关联的模板ID（0表示自定义计划）
  name: string = ''                   // 计划名称
  description: string = ''            // 计划描述
  goal: string = ''                   // 训练目标
  durationWeeks: number = 0           // 计划周期（周）
  durationWeeksOverride: number = 0   // 覆盖模板周期
  trainingDaysPerWeek: number = 0     // 每周训练天数
  trainingDays: TrainingDayModel[] = []  // 训练日程
  trainingDaysOverride: TrainingDayModel[] = [] // 覆盖后的日程
  startDate: string = ''              // 开始日期（YYYY-MM-DD）
  endDate: string = ''                // 结束日期（YYYY-MM-DD）
  status: string = ''                 // 计划状态（进行中/已完成/已暂停）
  currentWeek: number = 0             // 当前第几周
  currentDay: number = 0              // 当前第几天
  completedDays: number[] = []        // 已完成的训练日（dayNumber数组）
  skippedDays: number[] = []          // 跳过的训练日
  totalCompletedDays: number = 0      // 累计完成天数
  completionRate: number = 0          // 完成率（百分比）
  totalWeight: number = 0             // 计划累计重量
  totalDuration: number = 0           // 计划累计时长
  totalCalories: number = 0           // 计划累计消耗卡路里
  createdAt: string = ''              // 创建时间
  updatedAt: string = ''              // 更新时间

  constructor(
    id?: number,
    userId?: number,
    templateId?: number,
    name?: string,
    description?: string,
    goal?: string,
    durationWeeks?: number,
    trainingDaysPerWeek?: number,
    trainingDays?: TrainingDayModel[],
    startDate?: string,
    endDate?: string,
    status?: string,
    currentWeek?: number,
    currentDay?: number,
    completedDays?: number[],
    totalCompletedDays?: number,
    completionRate?: number,
    createdAt?: string,
    updatedAt?: string,
    durationWeeksOverride?: number,
    trainingDaysOverride?: TrainingDayModel[],
    skippedDays?: number[],
    totalWeight?: number,
    totalDuration?: number,
    totalCalories?: number
  ) {
    if (id !== null && id !== undefined) this.id = id;
    if (userId !== null && userId !== undefined) this.userId = userId;
    if (templateId !== null && templateId !== undefined) this.templateId = templateId;
    if (name !== null && name !== undefined) this.name = name;
    if (description !== null && description !== undefined) this.description = description;
    if (goal !== null && goal !== undefined) this.goal = goal;
    if (durationWeeks !== null && durationWeeks !== undefined) this.durationWeeks = durationWeeks;
    if (trainingDaysPerWeek !== null && trainingDaysPerWeek !== undefined) {
      this.trainingDaysPerWeek = trainingDaysPerWeek;
    }
    if (trainingDays !== null && trainingDays !== undefined) this.trainingDays = trainingDays;
    if (startDate !== null && startDate !== undefined) this.startDate = startDate;
    if (endDate !== null && endDate !== undefined) this.endDate = endDate;
    if (status !== null && status !== undefined) this.status = status;
    if (currentWeek !== null && currentWeek !== undefined) this.currentWeek = currentWeek;
    if (currentDay !== null && currentDay !== undefined) this.currentDay = currentDay;
    if (completedDays !== null && completedDays !== undefined) this.completedDays = completedDays;
    if (totalCompletedDays !== null && totalCompletedDays !== undefined) {
      this.totalCompletedDays = totalCompletedDays;
    }
    if (completionRate !== null && completionRate !== undefined) this.completionRate = completionRate;
    if (createdAt !== null && createdAt !== undefined) this.createdAt = createdAt;
    if (updatedAt !== null && updatedAt !== undefined) this.updatedAt = updatedAt;
    if (durationWeeksOverride !== null && durationWeeksOverride !== undefined) {
      this.durationWeeksOverride = durationWeeksOverride;
    }
    if (trainingDaysOverride !== null && trainingDaysOverride !== undefined) {
      this.trainingDaysOverride = trainingDaysOverride;
    }
    if (skippedDays !== null && skippedDays !== undefined) this.skippedDays = skippedDays;
    if (totalWeight !== null && totalWeight !== undefined) this.totalWeight = totalWeight;
    if (totalDuration !== null && totalDuration !== undefined) this.totalDuration = totalDuration;
    if (totalCalories !== null && totalCalories !== undefined) this.totalCalories = totalCalories;
  }

  /**
   * 计算完成率
   */
  calculateCompletionRate(): number {
    const totalDays: number = this.durationWeeks * this.trainingDaysPerWeek;
    if (totalDays === 0) return 0;
    return Math.round((this.totalCompletedDays / totalDays) * 100);
  }

  /**
   * 标记某一天为已完成
   */
  markDayCompleted(dayNumber: number): void {
    if (this.completedDays.indexOf(dayNumber) === -1) {
      this.completedDays.push(dayNumber);
      this.totalCompletedDays++;
      this.completionRate = this.calculateCompletionRate();
    }
  }

  /**
   * 检查某一天是否已完成
   */
  isDayCompleted(dayNumber: number): boolean {
    return this.completedDays.indexOf(dayNumber) !== -1;
  }
}

/**
 * 计划状态常量
 */
export class PlanStatusConst {
  static readonly ACTIVE: string = '进行中'
  static readonly COMPLETED: string = '已完成'
  static readonly PAUSED: string = '已暂停'
  static readonly ARCHIVED: string = '已归档'
}

/**
 * 计划进度摘要模型
 */
export class PlanProgressModel {
  planId: number = 0
  totalDays: number = 0
  completedDays: number = 0
  skippedDays: number = 0
  completionRate: number = 0
  currentWeek: number = 0
  currentDay: number = 0
  nextTrainingDate: string = ''
  totalDuration: number = 0
  totalWeight: number = 0
  totalCalories: number = 0

  constructor(
    planId?: number,
    totalDays?: number,
    completedDays?: number,
    skippedDays?: number,
    completionRate?: number,
    currentWeek?: number,
    currentDay?: number,
    nextTrainingDate?: string,
    totalDuration?: number,
    totalWeight?: number,
    totalCalories?: number
  ) {
    if (planId !== null && planId !== undefined) this.planId = planId;
    if (totalDays !== null && totalDays !== undefined) this.totalDays = totalDays;
    if (completedDays !== null && completedDays !== undefined) this.completedDays = completedDays;
    if (skippedDays !== null && skippedDays !== undefined) this.skippedDays = skippedDays;
    if (completionRate !== null && completionRate !== undefined) this.completionRate = completionRate;
    if (currentWeek !== null && currentWeek !== undefined) this.currentWeek = currentWeek;
    if (currentDay !== null && currentDay !== undefined) this.currentDay = currentDay;
    if (nextTrainingDate !== null && nextTrainingDate !== undefined) {
      this.nextTrainingDate = nextTrainingDate;
    }
    if (totalDuration !== null && totalDuration !== undefined) this.totalDuration = totalDuration;
    if (totalWeight !== null && totalWeight !== undefined) this.totalWeight = totalWeight;
    if (totalCalories !== null && totalCalories !== undefined) this.totalCalories = totalCalories;
  }
}

/**
 * 计划进度列表项模型
 */
export class PlanProgressItemModel {
  planId: number = 0
  name: string = ''
  status: string = ''
  completionRate: number = 0
  currentWeek: number = 0
  currentDay: number = 0
  endDate: string = ''

  constructor(
    planId?: number,
    name?: string,
    status?: string,
    completionRate?: number,
    currentWeek?: number,
    currentDay?: number,
    endDate?: string
  ) {
    if (planId !== null && planId !== undefined) this.planId = planId;
    if (name !== null && name !== undefined) this.name = name;
    if (status !== null && status !== undefined) this.status = status;
    if (completionRate !== null && completionRate !== undefined) this.completionRate = completionRate;
    if (currentWeek !== null && currentWeek !== undefined) this.currentWeek = currentWeek;
    if (currentDay !== null && currentDay !== undefined) this.currentDay = currentDay;
    if (endDate !== null && endDate !== undefined) this.endDate = endDate;
  }
}
