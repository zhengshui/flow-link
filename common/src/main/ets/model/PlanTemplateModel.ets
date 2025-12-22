import { ExerciseModel } from './ExerciseModel';

/**
 * 训练日程模型
 * 单个训练日的计划
 */
export class TrainingDayModel {
  dayNumber: number = 0               // 第几天（如：第1天、第2天）
  dayName: string = ''                // 训练日名称（如：胸肌日、腿部日、休息日）
  isRestDay: boolean = false          // 是否为休息日
  exercises: ExerciseModel[] = []     // 当日训练项目
  notes: string = ''                  // 当日备注
  intensityHint: string = ''          // 强度提示（如：RPE 7-8）
  warmupTips: string = ''             // 热身建议
  cooldownTips: string = ''           // 放松建议

  constructor(
    dayNumber?: number,
    dayName?: string,
    isRestDay?: boolean,
    exercises?: ExerciseModel[],
    notes?: string,
    intensityHint?: string,
    warmupTips?: string,
    cooldownTips?: string
  ) {
    if (dayNumber !== null && dayNumber !== undefined) this.dayNumber = dayNumber;
    if (dayName !== null && dayName !== undefined) this.dayName = dayName;
    if (isRestDay !== null && isRestDay !== undefined) this.isRestDay = isRestDay;
    if (exercises !== null && exercises !== undefined) this.exercises = exercises;
    if (notes !== null && notes !== undefined) this.notes = notes;
    if (intensityHint !== null && intensityHint !== undefined) this.intensityHint = intensityHint;
    if (warmupTips !== null && warmupTips !== undefined) this.warmupTips = warmupTips;
    if (cooldownTips !== null && cooldownTips !== undefined) this.cooldownTips = cooldownTips;
  }
}

/**
 * 计划模板模型
 * 预设的训练计划模板
 */
export class PlanTemplateModel {
  id: number = 0                      // 模板ID
  userId: number = 0                  // 用户ID（个人模板）
  name: string = ''                   // 模板名称（如：增肌计划、减脂计划）
  description: string = ''            // 模板描述
  goal: string = ''                   // 训练目标（增肌/减脂/力量提升/耐力提升）
  splitType: string = ''              // 分化方式（二分化/三分化/推拉腿/上下肢/四分化/五分化）
  level: string = ''                  // 难度等级（初级/中级/高级）
  equipment: string = ''              // 主要器械（徒手/哑铃/器械/混合）
  durationWeeks: number = 0           // 计划周期（周）
  trainingDaysPerWeek: number = 0     // 每周训练天数
  trainingDays: TrainingDayModel[] = []  // 训练日程列表
  imageUrl: string = ''               // 封面图片URL
  author: string = ''                 // 作者/来源
  tags: string[] = []                 // 标签（如：#增肌 #初级 #居家）
  recommendedIntensity: string = ''   // 推荐强度（如 RPE 7-8）
  isOfficial: boolean = true          // 是否官方模板
  createdAt: string = ''              // 创建时间

  constructor(
    id?: number,
    name?: string,
    description?: string,
    goal?: string,
    level?: string,
    durationWeeks?: number,
    trainingDaysPerWeek?: number,
    trainingDays?: TrainingDayModel[],
    imageUrl?: string,
    author?: string,
    tags?: string[],
    createdAt?: string,
    splitType?: string,
    equipment?: string,
    recommendedIntensity?: string,
    isOfficial?: boolean,
    userId?: number
  ) {
    if (id !== null && id !== undefined) this.id = id;
    if (name !== null && name !== undefined) this.name = name;
    if (description !== null && description !== undefined) this.description = description;
    if (goal !== null && goal !== undefined) this.goal = goal;
    if (level !== null && level !== undefined) this.level = level;
    if (durationWeeks !== null && durationWeeks !== undefined) this.durationWeeks = durationWeeks;
    if (trainingDaysPerWeek !== null && trainingDaysPerWeek !== undefined) {
      this.trainingDaysPerWeek = trainingDaysPerWeek;
    }
    if (trainingDays !== null && trainingDays !== undefined) this.trainingDays = trainingDays;
    if (imageUrl !== null && imageUrl !== undefined) this.imageUrl = imageUrl;
    if (author !== null && author !== undefined) this.author = author;
    if (tags !== null && tags !== undefined) this.tags = tags;
    if (createdAt !== null && createdAt !== undefined) this.createdAt = createdAt;
    if (splitType !== null && splitType !== undefined) this.splitType = splitType;
    if (equipment !== null && equipment !== undefined) this.equipment = equipment;
    if (recommendedIntensity !== null && recommendedIntensity !== undefined) {
      this.recommendedIntensity = recommendedIntensity;
    }
    if (isOfficial !== null && isOfficial !== undefined) this.isOfficial = isOfficial;
    if (userId !== null && userId !== undefined) this.userId = userId;
  }
}

/**
 * 训练目标常量
 */
export class TrainingGoalConst {
  static readonly MUSCLE_GAIN: string = '增肌'
  static readonly FAT_LOSS: string = '减脂'
  static readonly STRENGTH: string = '力量提升'
  static readonly ENDURANCE: string = '耐力提升'
  static readonly GENERAL_FITNESS: string = '综合健身'
}

/**
 * 难度等级常量
 */
export class DifficultyLevelConst {
  static readonly BEGINNER: string = '初级'
  static readonly INTERMEDIATE: string = '中级'
  static readonly ADVANCED: string = '高级'
}

/**
 * 分化方式常量
 */
export class SplitTypeConst {
  static readonly TWO_SPLIT: string = '二分化'
  static readonly THREE_SPLIT: string = '三分化'
  static readonly PUSH_PULL_LEG: string = '推拉腿'
  static readonly UPPER_LOWER: string = '上下肢'
  static readonly FOUR_SPLIT: string = '四分化'
  static readonly FIVE_SPLIT: string = '五分化'
}

/**
 * 器械类型常量
 */
export class EquipmentTypeConst {
  static readonly BODYWEIGHT: string = '徒手'
  static readonly DUMBBELL: string = '哑铃'
  static readonly MACHINE: string = '器械'
  static readonly MIXED: string = '混合'
}
