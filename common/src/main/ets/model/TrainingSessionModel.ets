/**
 * 训练会话模型
 * 用于记录正在进行的训练过程
 */

/**
 * 训练组模型
 * 记录单组训练的详细信息
 */
export class TrainingSetModel {
  setType: string = '正式'           // 组类型：热身、正式、放松
  weight: number = 0                 // 重量（kg）
  reps: number = 0                   // 次数
  isCompleted: boolean = false       // 是否完成
  note: string = ''                  // 备注

  constructor(
    setType: string = '正式',
    weight: number = 0,
    reps: number = 0,
    isCompleted: boolean = false,
    note: string = ''
  ) {
    this.setType = setType;
    this.weight = weight;
    this.reps = reps;
    this.isCompleted = isCompleted;
    this.note = note;
  }
}

/**
 * 训练会话中的动作模型
 * 包含动作信息和多组训练记录
 */
export class SessionExerciseModel {
  actionId: string = ''              // 动作ID（关联到ActionModel）
  actionName: string = ''            // 动作名称
  muscleGroup: string = ''           // 肌群
  sets: TrainingSetModel[] = []      // 训练组列表
  rmBase: number = 0                 // RM基准重量
  targetSets: number = 4             // 目标组数
  targetReps: number = 8             // 目标次数
  note: string = ''                  // 动作备注
  thumbnailUrl: string = ''          // 动作缩略图

  constructor(
    actionId: string,
    actionName: string,
    muscleGroup: string,
    sets: TrainingSetModel[] = [],
    rmBase: number = 0,
    targetSets: number = 4,
    targetReps: number = 8,
    note: string = '',
    thumbnailUrl: string = ''
  ) {
    this.actionId = actionId;
    this.actionName = actionName;
    this.muscleGroup = muscleGroup;
    this.sets = sets;
    this.rmBase = rmBase;
    this.targetSets = targetSets;
    this.targetReps = targetReps;
    this.note = note;
    this.thumbnailUrl = thumbnailUrl;
  }

  /**
   * 添加新组
   */
  addSet(setType: string, weight: number, reps: number): void {
    const newSet: TrainingSetModel = new TrainingSetModel(setType, weight, reps, false, '');
    this.sets.push(newSet);
  }

  /**
   * 删除指定组
   */
  removeSet(index: number): void {
    if (index >= 0 && index < this.sets.length) {
      const newSets: TrainingSetModel[] = [];
      for (let i: number = 0; i < this.sets.length; i++) {
        if (i !== index) {
          newSets.push(this.sets[i]);
        }
      }
      this.sets = newSets;
    }
  }

  /**
   * 计算已完成组数
   */
  getCompletedSetsCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.sets.length; i++) {
      if (this.sets[i].isCompleted) {
        count++;
      }
    }
    return count;
  }

  /**
   * 计算总容量（重量×次数）
   */
  getTotalVolume(): number {
    let volume: number = 0;
    for (let i: number = 0; i < this.sets.length; i++) {
      if (this.sets[i].isCompleted) {
        volume += this.sets[i].weight * this.sets[i].reps;
      }
    }
    return volume;
  }
}

/**
 * 训练会话模型
 * 记录整个训练过程的状态
 */
export class TrainingSessionModel {
  title: string = '训练记录'          // 训练标题
  startTime: number = 0               // 开始时间戳（毫秒）
  pausedTime: number = 0              // 暂停累计时长（毫秒）
  exercises: SessionExerciseModel[] = [] // 训练动作列表
  difficulty: string = ''             // 训练难度：简单、正常、困难
  notes: string = ''                  // 训练心得
  isRunning: boolean = false          // 是否正在计时
  planId: number = 0                  // 关联的计划ID

  constructor(
    title: string = '训练记录',
    startTime: number = 0,
    pausedTime: number = 0,
    exercises: SessionExerciseModel[] = [],
    difficulty: string = '',
    notes: string = '',
    isRunning: boolean = false,
    planId: number = 0
  ) {
    this.title = title;
    this.startTime = startTime;
    this.pausedTime = pausedTime;
    this.exercises = exercises;
    this.difficulty = difficulty;
    this.notes = notes;
    this.isRunning = isRunning;
    this.planId = planId;
  }

  /**
   * 添加动作
   */
  addExercise(exercise: SessionExerciseModel): void {
    this.exercises.push(exercise);
  }

  /**
   * 删除动作
   */
  removeExercise(index: number): void {
    if (index >= 0 && index < this.exercises.length) {
      const newExercises: SessionExerciseModel[] = [];
      for (let i: number = 0; i < this.exercises.length; i++) {
        if (i !== index) {
          newExercises.push(this.exercises[i]);
        }
      }
      this.exercises = newExercises;
    }
  }

  /**
   * 获取训练时长（分钟）
   */
  getDuration(): number {
    if (this.startTime === 0) {
      return 0;
    }
    const now: number = Date.now();
    const elapsed: number = now - this.startTime - this.pausedTime;
    return Math.floor(elapsed / 1000 / 60);
  }

  /**
   * 获取训练时长（秒）
   */
  getDurationInSeconds(): number {
    if (this.startTime === 0) {
      return 0;
    }
    const now: number = Date.now();
    const elapsed: number = now - this.startTime - this.pausedTime;
    return Math.floor(elapsed / 1000);
  }

  /**
   * 获取已完成总组数
   */
  getTotalCompletedSets(): number {
    let total: number = 0;
    for (let i: number = 0; i < this.exercises.length; i++) {
      total += this.exercises[i].getCompletedSetsCount();
    }
    return total;
  }

  /**
   * 获取总容量
   */
  getTotalVolume(): number {
    let total: number = 0;
    for (let i: number = 0; i < this.exercises.length; i++) {
      total += this.exercises[i].getTotalVolume();
    }
    return total;
  }

  /**
   * 获取完成的动作数量
   */
  getCompletedExercisesCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.exercises.length; i++) {
      if (this.exercises[i].getCompletedSetsCount() > 0) {
        count++;
      }
    }
    return count;
  }
}

/**
 * 训练难度常量
 */
export class TrainingDifficultyConst {
  static readonly EASY: string = '简单'
  static readonly NORMAL: string = '正常'
  static readonly HARD: string = '困难'
}

/**
 * 训练组类型常量
 */
export class SetTypeConst {
  static readonly WARMUP: string = '热身'
  static readonly WORKING: string = '正式'
  static readonly COOLDOWN: string = '放松'
}
