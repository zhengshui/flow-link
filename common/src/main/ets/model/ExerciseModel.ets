/**
 * 训练项目模型
 * 单个训练动作的详细信息
 */
export class ExerciseModel {
  id: number = 0                      // 训练项目ID
  name: string = ''                   // 训练项目名称（如：深蹲、卧推、硬拉）
  sets: number = 0                    // 组数
  reps: number = 0                    // 每组次数
  weight: number = 0                  // 重量（kg）
  restTime: number = 0                // 组间休息时间（秒）
  muscleGroup: string = ''            // 目标肌群（如：胸、背、腿、肩、臂、核心）
  notes: string = ''                  // 备注
  duration: number = 0                // 训练时长（分钟）

  constructor(
    id?: number,
    name?: string,
    sets?: number,
    reps?: number,
    weight?: number,
    restTime?: number,
    muscleGroup?: string,
    notes?: string,
    duration?: number
  ) {
    if (id !== null && id !== undefined) this.id = id;
    if (name !== null && name !== undefined) this.name = name;
    if (sets !== null && sets !== undefined) this.sets = sets;
    if (reps !== null && reps !== undefined) this.reps = reps;
    if (weight !== null && weight !== undefined) this.weight = weight;
    if (restTime !== null && restTime !== undefined) this.restTime = restTime;
    if (muscleGroup !== null && muscleGroup !== undefined) this.muscleGroup = muscleGroup;
    if (notes !== null && notes !== undefined) this.notes = notes;
    if (duration !== null && duration !== undefined) this.duration = duration;
  }
}

/**
 * 肌群常量
 */
export class MuscleGroupConst {
  static readonly CHEST: string = '胸部'
  static readonly BACK: string = '背部'
  static readonly LEGS: string = '腿部'
  static readonly SHOULDERS: string = '肩部'
  static readonly ARMS: string = '手臂'
  static readonly CORE: string = '核心'
  static readonly CARDIO: string = '有氧'
}
