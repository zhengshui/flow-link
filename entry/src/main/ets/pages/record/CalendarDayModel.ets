/**
 * 日历相关数据模型
 */

import { TrainingRecordModel } from '@tbs/common';

/**
 * 日历格子数据模型
 */
@Observed
export class CalendarDayModel {
  day: number = 0                               // 日期（0表示空格子）
  isCurrentMonth: boolean = false               // 是否为当前显示月份
  isToday: boolean = false                      // 是否为今天
  dateStr: string = ''                          // 日期字符串（YYYY-MM-DD）
  records: TrainingRecordModel[] = []           // 当天的训练记录

  constructor(day: number, isCurrentMonth: boolean, isToday: boolean, dateStr: string) {
    this.day = day;
    this.isCurrentMonth = isCurrentMonth;
    this.isToday = isToday;
    this.dateStr = dateStr;
  }
}

/**
 * 复制动作数据模型
 */
export class CopyActionData {
  id: string = '';
  name: string = '';
  muscleGroup: string = '';
  thumbnailUrl: string = '';
  sets: number = 0;
  reps: number = 0;
  weight: number = 0;

  constructor(id: string, name: string, muscleGroup: string, sets: number, reps: number, weight: number) {
    this.id = id;
    this.name = name;
    this.muscleGroup = muscleGroup;
    this.thumbnailUrl = '';
    this.sets = sets;
    this.reps = reps;
    this.weight = weight;
  }
}

