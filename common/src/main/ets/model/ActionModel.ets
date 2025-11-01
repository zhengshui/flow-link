/**
 * 动作模型 - Action
 * 训练动作的详细信息，包括名称、部位、视频等
 */

export class ActionModel {
  id: string = ''
  name: string = ''
  englishName: string = ''
  muscleGroup: string = ''
  thumbnailUrl: string = ''
  videoUrl: string = ''
  description: string = ''
  steps: string[] = []
  difficulty: string = ''
  equipment: string = ''
  tips: string[] = []

  constructor(
    id: string,
    name: string,
    englishName: string,
    muscleGroup: string,
    thumbnailUrl: string = '',
    videoUrl: string = '',
    description: string = '',
    steps: string[] = [],
    difficulty: string = '中级',
    equipment: string = '',
    tips: string[] = []
  ) {
    this.id = id;
    this.name = name;
    this.englishName = englishName;
    this.muscleGroup = muscleGroup;
    this.thumbnailUrl = thumbnailUrl;
    this.videoUrl = videoUrl;
    this.description = description;
    this.steps = steps;
    this.difficulty = difficulty;
    this.equipment = equipment;
    this.tips = tips;
  }
}

/**
 * 肌肉部位分组模型
 */
export class MuscleGroupModel {
  id: string = ''
  name: string = ''
  englishName: string = ''
  icon: string = ''
  actions: ActionModel[] = []

  constructor(
    id: string,
    name: string,
    englishName: string,
    icon: string,
    actions: ActionModel[] = []
  ) {
    this.id = id;
    this.name = name;
    this.englishName = englishName;
    this.icon = icon;
    this.actions = actions;
  }
}

/**
 * 肌肉部位常量
 */
export class MuscleGroupConst {
  static readonly CHEST: string = 'chest'
  static readonly BACK: string = 'back'
  static readonly LEGS: string = 'legs'
  static readonly SHOULDERS: string = 'shoulders'
  static readonly BICEPS: string = 'biceps'
  static readonly TRICEPS: string = 'triceps'
  static readonly CALVES: string = 'calves'
  static readonly GLUTES: string = 'glutes'
  static readonly ABS: string = 'abs'

  /**
   * 获取肌肉部位中文名称
   */
  static getChineseName(id: string): string {
    if (id === MuscleGroupConst.CHEST) {
      return '胸肌';
    } else if (id === MuscleGroupConst.BACK) {
      return '背肌';
    } else if (id === MuscleGroupConst.LEGS) {
      return '腿部';
    } else if (id === MuscleGroupConst.SHOULDERS) {
      return '肩部';
    } else if (id === MuscleGroupConst.BICEPS) {
      return '二头肌';
    } else if (id === MuscleGroupConst.TRICEPS) {
      return '三头肌';
    } else if (id === MuscleGroupConst.CALVES) {
      return '小腿';
    } else if (id === MuscleGroupConst.GLUTES) {
      return '臀部';
    } else if (id === MuscleGroupConst.ABS) {
      return '腹肌';
    }
    return '';
  }

  /**
   * 获取肌肉部位图标
   */
  static getIcon(id: string): string {
    if (id === MuscleGroupConst.CHEST) {
      return '💪';
    } else if (id === MuscleGroupConst.BACK) {
      return '🦾';
    } else if (id === MuscleGroupConst.LEGS) {
      return '🦵';
    } else if (id === MuscleGroupConst.SHOULDERS) {
      return '🤸';
    } else if (id === MuscleGroupConst.BICEPS) {
      return '💪';
    } else if (id === MuscleGroupConst.TRICEPS) {
      return '💪';
    } else if (id === MuscleGroupConst.CALVES) {
      return '🦿';
    } else if (id === MuscleGroupConst.GLUTES) {
      return '🍑';
    } else if (id === MuscleGroupConst.ABS) {
      return '🎯';
    }
    return '💪';
  }
}

/**
 * 动作难度常量
 */
export class ActionDifficultyConst {
  static readonly BEGINNER: string = '初级'
  static readonly INTERMEDIATE: string = '中级'
  static readonly ADVANCED: string = '高级'
}
