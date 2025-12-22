import { ExerciseModel } from './ExerciseModel';

/**
 * 训练记录模型
 * 记录每次完整的训练会话
 */
export class TrainingRecordModel {
  id: string = ''                     // 训练记录ID（MongoDB ObjectId）
  userId: number = 0                  // 用户ID
  title: string = ''                  // 训练标题（如：胸肌训练日、有氧跑步）
  date: string = ''                   // 训练日期（YYYY-MM-DD）- 从 startTime 提取
  startTime: string = ''              // 开始时间（YYYY-MM-DD HH:mm:ss）完整日期时间
  endTime: string = ''                // 结束时间（YYYY-MM-DD HH:mm:ss）完整日期时间
  duration: number = 0                // 总时长（分钟）- 由后端根据 startTime 和 endTime 计算
  exercises: ExerciseModel[] = []     // 训练项目列表
  totalWeight: number = 0             // 总重量（kg = sum(sets * reps * weight)）
  totalSets: number = 0               // 总组数
  caloriesBurned: number = 0          // 消耗卡路里（估算值）
  notes: string = ''                  // 训练备注
  mood: string = ''                   // 训练状态（优秀/良好/一般/疲劳）
  planId: number = 0                  // 关联的计划ID（0表示无计划）
  planDayId: number = 0               // 关联计划日ID
  completionStatus: string = ''       // 完成状态（完成/部分/跳过）
  createdAt: string = ''              // 创建时间戳
  updatedAt: string = ''              // 更新时间戳

  constructor(
    id?: string,
    userId?: number,
    title?: string,
    date?: string,
    startTime?: string,
    endTime?: string,
    duration?: number,
    exercises?: ExerciseModel[],
    totalWeight?: number,
    totalSets?: number,
    caloriesBurned?: number,
    notes?: string,
    mood?: string,
    planId?: number,
    createdAt?: string,
    updatedAt?: string,
    planDayId?: number,
    completionStatus?: string
  ) {
    if (id !== null && id !== undefined) this.id = id;
    if (userId !== null && userId !== undefined) this.userId = userId;
    if (title !== null && title !== undefined) this.title = title;
    if (date !== null && date !== undefined) this.date = date;
    if (startTime !== null && startTime !== undefined) this.startTime = startTime;
    if (endTime !== null && endTime !== undefined) this.endTime = endTime;
    if (duration !== null && duration !== undefined) this.duration = duration;
    if (exercises !== null && exercises !== undefined) this.exercises = exercises;
    if (totalWeight !== null && totalWeight !== undefined) this.totalWeight = totalWeight;
    if (totalSets !== null && totalSets !== undefined) this.totalSets = totalSets;
    if (caloriesBurned !== null && caloriesBurned !== undefined) this.caloriesBurned = caloriesBurned;
    if (notes !== null && notes !== undefined) this.notes = notes;
    if (mood !== null && mood !== undefined) this.mood = mood;
    if (planId !== null && planId !== undefined) this.planId = planId;
    if (createdAt !== null && createdAt !== undefined) this.createdAt = createdAt;
    if (updatedAt !== null && updatedAt !== undefined) this.updatedAt = updatedAt;
    if (planDayId !== null && planDayId !== undefined) this.planDayId = planDayId;
    if (completionStatus !== null && completionStatus !== undefined) {
      this.completionStatus = completionStatus;
    }
  }

  /**
   * 计算总重量
   */
  calculateTotalWeight(): number {
    let total: number = 0;
    for (let i: number = 0; i < this.exercises.length; i++) {
      const exercise: ExerciseModel = this.exercises[i];
      total += exercise.sets * exercise.reps * exercise.weight;
    }
    return total;
  }

  /**
   * 计算总组数
   */
  calculateTotalSets(): number {
    let total: number = 0;
    for (let i: number = 0; i < this.exercises.length; i++) {
      total += this.exercises[i].sets;
    }
    return total;
  }
}

/**
 * 训练状态常量
 */
export class TrainingMoodConst {
  static readonly EXCELLENT: string = '优秀'
  static readonly GOOD: string = '良好'
  static readonly NORMAL: string = '一般'
  static readonly TIRED: string = '疲劳'
}

/**
 * 完成状态常量
 */
export class CompletionStatusConst {
  static readonly COMPLETED: string = '完成'
  static readonly PARTIAL: string = '部分'
  static readonly SKIPPED: string = '跳过'
}
