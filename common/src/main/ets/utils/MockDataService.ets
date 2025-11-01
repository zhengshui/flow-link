import { TrainingRecordModel, TrainingMoodConst } from '../model/TrainingRecordModel';
import { ExerciseModel, MuscleGroupConst } from '../model/ExerciseModel';
import { PlanTemplateModel, TrainingDayModel, TrainingGoalConst, DifficultyLevelConst } from '../model/PlanTemplateModel';
import { FitnessPlanModel, PlanStatusConst } from '../model/FitnessPlanModel';
import { TrainingStatsModel, DailyStatsModel, MuscleGroupStatsModel } from '../model/TrainingStatsModel';

/**
 * Mock数据服务
 * 提供模拟数据用于开发测试
 */
export class MockDataService {
  /**
   * 获取今天的日期字符串 (YYYY-MM-DD)
   */
  static getTodayString(): string {
    const date: Date = new Date();
    const year: number = date.getFullYear();
    const month: number = date.getMonth() + 1;
    const day: number = date.getDate();
    const monthStr: string = month < 10 ? '0' + month.toString() : month.toString();
    const dayStr: string = day < 10 ? '0' + day.toString() : day.toString();
    return year.toString() + '-' + monthStr + '-' + dayStr;
  }

  /**
   * 获取指定天数前的日期字符串
   */
  static getDaysAgo(daysAgo: number): string {
    const date: Date = new Date();
    date.setDate(date.getDate() - daysAgo);
    const year: number = date.getFullYear();
    const month: number = date.getMonth() + 1;
    const day: number = date.getDate();
    const monthStr: string = month < 10 ? '0' + month.toString() : month.toString();
    const dayStr: string = day < 10 ? '0' + day.toString() : day.toString();
    return year.toString() + '-' + monthStr + '-' + dayStr;
  }

  /**
   * 获取Mock训练项目列表
   */
  static getMockExercises(): ExerciseModel[] {
    const exercises: ExerciseModel[] = [];

    exercises.push(new ExerciseModel(1, '杠铃深蹲', 4, 10, 80, 90, MuscleGroupConst.LEGS, '保持核心稳定', 20));
    exercises.push(new ExerciseModel(2, '杠铃卧推', 4, 8, 60, 120, MuscleGroupConst.CHEST, '注意肩胛骨回收', 18));
    exercises.push(new ExerciseModel(3, '硬拉', 3, 6, 100, 180, MuscleGroupConst.BACK, '保持背部挺直', 15));
    exercises.push(new ExerciseModel(4, '杠铃推举', 4, 10, 40, 90, MuscleGroupConst.SHOULDERS, '控制动作速度', 16));
    exercises.push(new ExerciseModel(5, '引体向上', 3, 8, 0, 120, MuscleGroupConst.BACK, '自重训练', 12));
    exercises.push(new ExerciseModel(6, '哑铃弯举', 3, 12, 15, 60, MuscleGroupConst.ARMS, '避免借力', 10));
    exercises.push(new ExerciseModel(7, '平板支撑', 3, 60, 0, 60, MuscleGroupConst.CORE, '保持腹部紧张', 5));
    exercises.push(new ExerciseModel(8, '跑步', 1, 30, 0, 0, MuscleGroupConst.CARDIO, '有氧训练', 30));

    return exercises;
  }

  /**
   * 获取Mock训练记录列表
   */
  static getMockTrainingRecords(): TrainingRecordModel[] {
    const records: TrainingRecordModel[] = [];

    // 今天的训练记录
    const todayExercises: ExerciseModel[] = [];
    todayExercises.push(new ExerciseModel(1, '杠铃深蹲', 4, 10, 80, 90, MuscleGroupConst.LEGS, '', 20));
    todayExercises.push(new ExerciseModel(2, '腿举', 4, 12, 120, 90, MuscleGroupConst.LEGS, '', 18));
    todayExercises.push(new ExerciseModel(3, '腿弯举', 3, 15, 40, 60, MuscleGroupConst.LEGS, '', 12));

    const record1: TrainingRecordModel = new TrainingRecordModel(
      1, 1, '腿部训练日', MockDataService.getTodayString(), '09:00', '10:30', 90,
      todayExercises, 5600, 11, 450, '状态不错，完成所有计划', TrainingMoodConst.EXCELLENT, 1,
      MockDataService.getTodayString(), MockDataService.getTodayString()
    );
    record1.totalWeight = record1.calculateTotalWeight();
    record1.totalSets = record1.calculateTotalSets();
    records.push(record1);

    // 昨天的训练记录
    const yesterdayExercises: ExerciseModel[] = [];
    yesterdayExercises.push(new ExerciseModel(4, '杠铃卧推', 4, 8, 60, 120, MuscleGroupConst.CHEST, '', 18));
    yesterdayExercises.push(new ExerciseModel(5, '上斜哑铃推举', 4, 10, 25, 90, MuscleGroupConst.CHEST, '', 16));
    yesterdayExercises.push(new ExerciseModel(6, '双杠臂屈伸', 3, 12, 0, 90, MuscleGroupConst.CHEST, '', 10));

    const record2: TrainingRecordModel = new TrainingRecordModel(
      2, 1, '胸部训练日', MockDataService.getDaysAgo(1), '18:00', '19:20', 80,
      yesterdayExercises, 3920, 11, 400, '感觉有点疲劳', TrainingMoodConst.GOOD, 1,
      MockDataService.getDaysAgo(1), MockDataService.getDaysAgo(1)
    );
    record2.totalWeight = record2.calculateTotalWeight();
    record2.totalSets = record2.calculateTotalSets();
    records.push(record2);

    // 3天前的训练记录
    const day3Exercises: ExerciseModel[] = [];
    day3Exercises.push(new ExerciseModel(7, '硬拉', 3, 6, 100, 180, MuscleGroupConst.BACK, '', 15));
    day3Exercises.push(new ExerciseModel(8, '引体向上', 4, 8, 0, 120, MuscleGroupConst.BACK, '', 12));
    day3Exercises.push(new ExerciseModel(9, '杠铃划船', 4, 10, 70, 90, MuscleGroupConst.BACK, '', 16));

    const record3: TrainingRecordModel = new TrainingRecordModel(
      3, 1, '背部训练日', MockDataService.getDaysAgo(3), '10:00', '11:15', 75,
      day3Exercises, 4600, 11, 380, '', TrainingMoodConst.EXCELLENT, 1,
      MockDataService.getDaysAgo(3), MockDataService.getDaysAgo(3)
    );
    record3.totalWeight = record3.calculateTotalWeight();
    record3.totalSets = record3.calculateTotalSets();
    records.push(record3);

    // 5天前的训练记录
    const day5Exercises: ExerciseModel[] = [];
    day5Exercises.push(new ExerciseModel(10, '杠铃推举', 4, 10, 40, 90, MuscleGroupConst.SHOULDERS, '', 16));
    day5Exercises.push(new ExerciseModel(11, '哑铃侧平举', 4, 12, 10, 60, MuscleGroupConst.SHOULDERS, '', 12));
    day5Exercises.push(new ExerciseModel(12, '俯身飞鸟', 3, 15, 8, 60, MuscleGroupConst.SHOULDERS, '', 10));

    const record4: TrainingRecordModel = new TrainingRecordModel(
      4, 1, '肩部训练日', MockDataService.getDaysAgo(5), '16:00', '17:00', 60,
      day5Exercises, 2280, 11, 320, '训练量适中', TrainingMoodConst.GOOD, 1,
      MockDataService.getDaysAgo(5), MockDataService.getDaysAgo(5)
    );
    record4.totalWeight = record4.calculateTotalWeight();
    record4.totalSets = record4.calculateTotalSets();
    records.push(record4);

    // 7天前的训练记录
    const day7Exercises: ExerciseModel[] = [];
    day7Exercises.push(new ExerciseModel(13, '跑步', 1, 40, 0, 0, MuscleGroupConst.CARDIO, '有氧', 40));
    day7Exercises.push(new ExerciseModel(14, '平板支撑', 3, 60, 0, 60, MuscleGroupConst.CORE, '', 5));

    const record5: TrainingRecordModel = new TrainingRecordModel(
      5, 1, '有氧+核心训练', MockDataService.getDaysAgo(7), '07:00', '08:00', 60,
      day7Exercises, 0, 4, 500, '状态一般', TrainingMoodConst.NORMAL, 0,
      MockDataService.getDaysAgo(7), MockDataService.getDaysAgo(7)
    );
    record5.totalWeight = record5.calculateTotalWeight();
    record5.totalSets = record5.calculateTotalSets();
    records.push(record5);

    return records;
  }

  /**
   * 获取Mock计划模板列表
   */
  static getMockPlanTemplates(): PlanTemplateModel[] {
    const templates: PlanTemplateModel[] = [];

    // 增肌计划模板
    const muscleGainDays: TrainingDayModel[] = [];
    muscleGainDays.push(new TrainingDayModel(1, '胸肌+三头日', false, [
      new ExerciseModel(1, '杠铃卧推', 4, 8, 60, 120, MuscleGroupConst.CHEST, '', 18),
      new ExerciseModel(2, '上斜哑铃推举', 4, 10, 25, 90, MuscleGroupConst.CHEST, '', 16),
      new ExerciseModel(3, '双杠臂屈伸', 3, 12, 0, 90, MuscleGroupConst.ARMS, '', 10)
    ], '重点训练胸大肌中束和上束'));
    muscleGainDays.push(new TrainingDayModel(2, '背部+二头日', false, [
      new ExerciseModel(4, '硬拉', 3, 6, 100, 180, MuscleGroupConst.BACK, '', 15),
      new ExerciseModel(5, '引体向上', 4, 8, 0, 120, MuscleGroupConst.BACK, '', 12),
      new ExerciseModel(6, '哑铃弯举', 3, 12, 15, 60, MuscleGroupConst.ARMS, '', 10)
    ], '打造宽厚背部'));
    muscleGainDays.push(new TrainingDayModel(3, '休息日', true, [], '充分恢复'));
    muscleGainDays.push(new TrainingDayModel(4, '腿部训练日', false, [
      new ExerciseModel(7, '杠铃深蹲', 4, 10, 80, 90, MuscleGroupConst.LEGS, '', 20),
      new ExerciseModel(8, '腿举', 4, 12, 120, 90, MuscleGroupConst.LEGS, '', 18),
      new ExerciseModel(9, '腿弯举', 3, 15, 40, 60, MuscleGroupConst.LEGS, '', 12)
    ], '强化下肢力量'));
    muscleGainDays.push(new TrainingDayModel(5, '肩部+核心日', false, [
      new ExerciseModel(10, '杠铃推举', 4, 10, 40, 90, MuscleGroupConst.SHOULDERS, '', 16),
      new ExerciseModel(11, '哑铃侧平举', 4, 12, 10, 60, MuscleGroupConst.SHOULDERS, '', 12),
      new ExerciseModel(12, '平板支撑', 3, 60, 0, 60, MuscleGroupConst.CORE, '', 5)
    ], '塑造饱满肩膀'));
    muscleGainDays.push(new TrainingDayModel(6, '休息日', true, [], '恢复和生长'));
    muscleGainDays.push(new TrainingDayModel(7, '休息日', true, [], '准备新一周'));

    const template1: PlanTemplateModel = new PlanTemplateModel(
      1, '增肌计划', '系统化增肌训练，适合有一定基础的健身者', TrainingGoalConst.MUSCLE_GAIN,
      DifficultyLevelConst.INTERMEDIATE, 8, 4, muscleGainDays, '',
      'FitEasy官方', ['增肌', '中级', '器械训练'], MockDataService.getTodayString()
    );
    templates.push(template1);

    // 减脂计划模板
    const fatLossDays: TrainingDayModel[] = [];
    fatLossDays.push(new TrainingDayModel(1, 'HIIT有氧日', false, [
      new ExerciseModel(13, '波比跳', 4, 20, 0, 60, MuscleGroupConst.CARDIO, '', 15),
      new ExerciseModel(14, '开合跳', 4, 30, 0, 45, MuscleGroupConst.CARDIO, '', 10),
      new ExerciseModel(15, '登山跑', 4, 30, 0, 45, MuscleGroupConst.CARDIO, '', 10)
    ], '高强度间歇训练'));
    fatLossDays.push(new TrainingDayModel(2, '全身力量日', false, [
      new ExerciseModel(16, '深蹲', 3, 15, 40, 60, MuscleGroupConst.LEGS, '', 12),
      new ExerciseModel(17, '俯卧撑', 3, 15, 0, 60, MuscleGroupConst.CHEST, '', 8),
      new ExerciseModel(18, '卷腹', 3, 20, 0, 45, MuscleGroupConst.CORE, '', 6)
    ], '保持肌肉量'));
    fatLossDays.push(new TrainingDayModel(3, '有氧慢跑日', false, [
      new ExerciseModel(19, '慢跑', 1, 40, 0, 0, MuscleGroupConst.CARDIO, '', 40)
    ], '燃烧脂肪'));
    fatLossDays.push(new TrainingDayModel(4, '休息日', true, [], '主动恢复'));
    fatLossDays.push(new TrainingDayModel(5, 'HIIT有氧日', false, [
      new ExerciseModel(20, '波比跳', 4, 20, 0, 60, MuscleGroupConst.CARDIO, '', 15),
      new ExerciseModel(21, '跳绳', 4, 100, 0, 60, MuscleGroupConst.CARDIO, '', 12)
    ], '高强度燃脂'));
    fatLossDays.push(new TrainingDayModel(6, '全身循环训练', false, [
      new ExerciseModel(22, '深蹲跳', 3, 15, 0, 60, MuscleGroupConst.LEGS, '', 10),
      new ExerciseModel(23, '平板支撑', 3, 60, 0, 60, MuscleGroupConst.CORE, '', 5)
    ], '提高代谢'));
    fatLossDays.push(new TrainingDayModel(7, '休息日', true, [], '恢复体力'));

    const template2: PlanTemplateModel = new PlanTemplateModel(
      2, '减脂计划', '结合有氧和力量训练，高效燃烧脂肪', TrainingGoalConst.FAT_LOSS,
      DifficultyLevelConst.BEGINNER, 6, 5, fatLossDays, '',
      'FitEasy官方', ['减脂', '初级', '居家训练'], MockDataService.getTodayString()
    );
    templates.push(template2);

    // 力量提升计划模板
    const strengthDays: TrainingDayModel[] = [];
    strengthDays.push(new TrainingDayModel(1, '深蹲日', false, [
      new ExerciseModel(24, '杠铃深蹲', 5, 5, 100, 180, MuscleGroupConst.LEGS, '', 25),
      new ExerciseModel(25, '前蹲', 3, 8, 70, 120, MuscleGroupConst.LEGS, '', 15)
    ], '大重量深蹲'));
    strengthDays.push(new TrainingDayModel(2, '卧推日', false, [
      new ExerciseModel(26, '杠铃卧推', 5, 5, 80, 180, MuscleGroupConst.CHEST, '', 25),
      new ExerciseModel(27, '上斜卧推', 3, 8, 60, 120, MuscleGroupConst.CHEST, '', 15)
    ], '大重量卧推'));
    strengthDays.push(new TrainingDayModel(3, '休息日', true, [], '恢复'));
    strengthDays.push(new TrainingDayModel(4, '硬拉日', false, [
      new ExerciseModel(28, '硬拉', 5, 3, 120, 240, MuscleGroupConst.BACK, '', 20),
      new ExerciseModel(29, '罗马尼亚硬拉', 3, 6, 80, 150, MuscleGroupConst.BACK, '', 12)
    ], '大重量硬拉'));
    strengthDays.push(new TrainingDayModel(5, '推举日', false, [
      new ExerciseModel(30, '杠铃推举', 5, 5, 50, 150, MuscleGroupConst.SHOULDERS, '', 20),
      new ExerciseModel(31, '哑铃推举', 3, 8, 20, 90, MuscleGroupConst.SHOULDERS, '', 12)
    ], '强化肩部力量'));
    strengthDays.push(new TrainingDayModel(6, '休息日', true, [], '恢复'));
    strengthDays.push(new TrainingDayModel(7, '休息日', true, [], '准备新一周'));

    const template3: PlanTemplateModel = new PlanTemplateModel(
      3, '力量提升计划', '专注于三大项和辅助动作，提升绝对力量', TrainingGoalConst.STRENGTH,
      DifficultyLevelConst.ADVANCED, 12, 4, strengthDays, '',
      'FitEasy官方', ['力量', '高级', '器械训练'], MockDataService.getTodayString()
    );
    templates.push(template3);

    return templates;
  }

  /**
   * 获取Mock用户健身计划列表
   */
  static getMockUserPlans(): FitnessPlanModel[] {
    const plans: FitnessPlanModel[] = [];

    const templates: PlanTemplateModel[] = MockDataService.getMockPlanTemplates();
    const template1: PlanTemplateModel = templates[0];

    const plan1: FitnessPlanModel = new FitnessPlanModel(
      1, 1, 1, template1.name, template1.description, template1.goal,
      template1.durationWeeks, template1.trainingDaysPerWeek, template1.trainingDays,
      MockDataService.getDaysAgo(14), MockDataService.getDaysAgo(-42), PlanStatusConst.ACTIVE, 3, 2,
      [1, 2, 4, 5, 8, 9, 11, 12, 15, 16], 10, 0,
      MockDataService.getDaysAgo(14), MockDataService.getTodayString()
    );
    plan1.completionRate = plan1.calculateCompletionRate();
    plans.push(plan1);

    return plans;
  }

  /**
   * 获取Mock训练统计数据
   */
  static getMockTrainingStats(period: string): TrainingStatsModel {
    const dailyStats: DailyStatsModel[] = [];
    const daysCount: number = period === 'week' ? 7 : (period === 'month' ? 30 : 365);

    // 生成每日统计数据
    for (let i: number = daysCount - 1; i >= 0; i--) {
      const dateStr: string = MockDataService.getDaysAgo(i);
      // 模拟数据：不是每天都训练
      const hasTraining: boolean = (i % 2 === 0 || i % 3 === 0);
      if (hasTraining) {
        const daily: DailyStatsModel = new DailyStatsModel(
          dateStr,
          1,
          60 + Math.floor(Math.random() * 40),
          2000 + Math.floor(Math.random() * 3000),
          10 + Math.floor(Math.random() * 5),
          300 + Math.floor(Math.random() * 200)
        );
        dailyStats.push(daily);
      } else {
        dailyStats.push(new DailyStatsModel(dateStr, 0, 0, 0, 0, 0));
      }
    }

    // 计算总计数据
    let totalCount: number = 0;
    let totalDuration: number = 0;
    let totalWeight: number = 0;
    let totalSets: number = 0;
    let totalCalories: number = 0;

    for (let i: number = 0; i < dailyStats.length; i++) {
      const daily: DailyStatsModel = dailyStats[i];
      totalCount += daily.trainingCount;
      totalDuration += daily.duration;
      totalWeight += daily.weight;
      totalSets += daily.sets;
      totalCalories += daily.calories;
    }

    const avgDuration: number = totalCount > 0 ? Math.floor(totalDuration / totalCount) : 0;
    const avgWeight: number = totalCount > 0 ? Math.floor(totalWeight / totalCount) : 0;

    const stats: TrainingStatsModel = new TrainingStatsModel(
      1, period, MockDataService.getDaysAgo(daysCount - 1), MockDataService.getTodayString(),
      totalCount, totalDuration, totalWeight, totalSets, totalCalories,
      avgDuration, avgWeight, MuscleGroupConst.CHEST, '杠铃卧推',
      dailyStats
    );

    return stats;
  }

  /**
   * 获取Mock肌群训练统计
   */
  static getMockMuscleGroupStats(): MuscleGroupStatsModel[] {
    const stats: MuscleGroupStatsModel[] = [];

    stats.push(new MuscleGroupStatsModel(MuscleGroupConst.CHEST, 12, 15000, 25));
    stats.push(new MuscleGroupStatsModel(MuscleGroupConst.BACK, 10, 12000, 20));
    stats.push(new MuscleGroupStatsModel(MuscleGroupConst.LEGS, 14, 18000, 30));
    stats.push(new MuscleGroupStatsModel(MuscleGroupConst.SHOULDERS, 8, 8000, 13));
    stats.push(new MuscleGroupStatsModel(MuscleGroupConst.ARMS, 6, 4500, 7));
    stats.push(new MuscleGroupStatsModel(MuscleGroupConst.CORE, 5, 0, 0));
    stats.push(new MuscleGroupStatsModel(MuscleGroupConst.CARDIO, 3, 0, 5));

    return stats;
  }
}
