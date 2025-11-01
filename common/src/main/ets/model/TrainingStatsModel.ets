/**
 * 训练统计模型
 * 用于数据分析页面展示
 */
export class TrainingStatsModel {
  userId: number = 0                  // 用户ID
  period: string = ''                 // 统计周期（week/month/year）
  startDate: string = ''              // 统计开始日期
  endDate: string = ''                // 统计结束日期
  totalTrainingCount: number = 0      // 总训练次数
  totalDuration: number = 0           // 总训练时长（分钟）
  totalWeight: number = 0             // 总重量（kg）
  totalSets: number = 0               // 总组数
  totalCalories: number = 0           // 总消耗卡路里
  avgDuration: number = 0             // 平均训练时长
  avgWeight: number = 0               // 平均单次重量
  mostTrainedMuscle: string = ''      // 训练最多的肌群
  favoriteExercise: string = ''       // 最常做的训练项目
  dailyStats: DailyStatsModel[] = []  // 每日统计数据（用于趋势图）

  constructor(
    userId?: number,
    period?: string,
    startDate?: string,
    endDate?: string,
    totalTrainingCount?: number,
    totalDuration?: number,
    totalWeight?: number,
    totalSets?: number,
    totalCalories?: number,
    avgDuration?: number,
    avgWeight?: number,
    mostTrainedMuscle?: string,
    favoriteExercise?: string,
    dailyStats?: DailyStatsModel[]
  ) {
    if (userId !== null && userId !== undefined) this.userId = userId;
    if (period !== null && period !== undefined) this.period = period;
    if (startDate !== null && startDate !== undefined) this.startDate = startDate;
    if (endDate !== null && endDate !== undefined) this.endDate = endDate;
    if (totalTrainingCount !== null && totalTrainingCount !== undefined) {
      this.totalTrainingCount = totalTrainingCount;
    }
    if (totalDuration !== null && totalDuration !== undefined) this.totalDuration = totalDuration;
    if (totalWeight !== null && totalWeight !== undefined) this.totalWeight = totalWeight;
    if (totalSets !== null && totalSets !== undefined) this.totalSets = totalSets;
    if (totalCalories !== null && totalCalories !== undefined) this.totalCalories = totalCalories;
    if (avgDuration !== null && avgDuration !== undefined) this.avgDuration = avgDuration;
    if (avgWeight !== null && avgWeight !== undefined) this.avgWeight = avgWeight;
    if (mostTrainedMuscle !== null && mostTrainedMuscle !== undefined) {
      this.mostTrainedMuscle = mostTrainedMuscle;
    }
    if (favoriteExercise !== null && favoriteExercise !== undefined) {
      this.favoriteExercise = favoriteExercise;
    }
    if (dailyStats !== null && dailyStats !== undefined) this.dailyStats = dailyStats;
  }
}

/**
 * 每日统计模型
 * 用于趋势图数据点
 */
export class DailyStatsModel {
  date: string = ''                   // 日期（YYYY-MM-DD）
  trainingCount: number = 0           // 当日训练次数
  duration: number = 0                // 当日训练时长
  weight: number = 0                  // 当日总重量
  sets: number = 0                    // 当日总组数
  calories: number = 0                // 当日消耗卡路里

  constructor(
    date?: string,
    trainingCount?: number,
    duration?: number,
    weight?: number,
    sets?: number,
    calories?: number
  ) {
    if (date !== null && date !== undefined) this.date = date;
    if (trainingCount !== null && trainingCount !== undefined) this.trainingCount = trainingCount;
    if (duration !== null && duration !== undefined) this.duration = duration;
    if (weight !== null && weight !== undefined) this.weight = weight;
    if (sets !== null && sets !== undefined) this.sets = sets;
    if (calories !== null && calories !== undefined) this.calories = calories;
  }
}

/**
 * 肌群训练统计模型
 */
export class MuscleGroupStatsModel {
  muscleGroup: string = ''            // 肌群名称
  trainingCount: number = 0           // 训练次数
  totalWeight: number = 0             // 总重量
  percentage: number = 0              // 占比（百分比）

  constructor(
    muscleGroup?: string,
    trainingCount?: number,
    totalWeight?: number,
    percentage?: number
  ) {
    if (muscleGroup !== null && muscleGroup !== undefined) this.muscleGroup = muscleGroup;
    if (trainingCount !== null && trainingCount !== undefined) this.trainingCount = trainingCount;
    if (totalWeight !== null && totalWeight !== undefined) this.totalWeight = totalWeight;
    if (percentage !== null && percentage !== undefined) this.percentage = percentage;
  }
}

/**
 * 统计周期常量
 */
export class StatsPeriodConst {
  static readonly WEEK: string = 'week'
  static readonly MONTH: string = 'month'
  static readonly YEAR: string = 'year'
}
