/**
 * 统计数据 API 服务
 * 处理训练统计相关的后端接口调用
 */

import http from '@ohos.net.http';
import { requestApiCall } from '../http/httpUtils';
import { ResponseResult } from '../http/response';
import { TrainingStatsModel, DailyStatsModel, MuscleGroupStatsModel } from '../model/TrainingStatsModel';

/**
 * 个人记录模型
 */
export class PersonalRecordModel {
  exerciseName: string = ''
  maxWeight: number = 0
  date: string = ''
  recordId: number = 0

  constructor(exerciseName?: string, maxWeight?: number, date?: string, recordId?: number) {
    if (exerciseName !== null && exerciseName !== undefined) this.exerciseName = exerciseName;
    if (maxWeight !== null && maxWeight !== undefined) this.maxWeight = maxWeight;
    if (date !== null && date !== undefined) this.date = date;
    if (recordId !== null && recordId !== undefined) this.recordId = recordId;
  }
}

/**
 * 日历数据模型
 */
export class CalendarDayModel {
  date: string = ''
  hasTraining: boolean = false
  trainingCount: number = 0
  totalDuration: number = 0

  constructor(date?: string, hasTraining?: boolean, trainingCount?: number, totalDuration?: number) {
    if (date !== null && date !== undefined) this.date = date;
    if (hasTraining !== null && hasTraining !== undefined) this.hasTraining = hasTraining;
    if (trainingCount !== null && trainingCount !== undefined) this.trainingCount = trainingCount;
    if (totalDuration !== null && totalDuration !== undefined) this.totalDuration = totalDuration;
  }
}

export class StatsApiService {
  /**
   * 创建错误响应
   */
  private static createErrorResponse(code: number, message: string): ResponseResult {
    const response: ResponseResult = new ResponseResult();
    response.code = code;
    response.message = message;
    response.data = null;
    return response;
  }

  /**
   * 获取训练统计数据
   * GET /stats/training?period=week&startDate=xxx&endDate=xxx
   */
  static async getTrainingStats(
    period: string = 'week',
    startDate: string = '',
    endDate: string = ''
  ): Promise<ResponseResult> {
    try {
      let url: string = `/stats/training?period=${period}`;

      if (startDate) {
        url += `&startDate=${startDate}`;
      }
      if (endDate) {
        url += `&endDate=${endDate}`;
      }

      const response: ResponseResult = await requestApiCall(
        url,
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const statsData: Record<string, Object> = response.data as Record<string, Object>;

        // 解析每日统计数据
        const dailyStatsArray: Object[] = statsData['dailyStats'] as Object[] ?? [];
        const dailyStats: DailyStatsModel[] = [];

        for (let i: number = 0; i < dailyStatsArray.length; i++) {
          const dailyData: Record<string, Object> = dailyStatsArray[i] as Record<string, Object>;
          const daily: DailyStatsModel = new DailyStatsModel(
            dailyData['date'] as string ?? '',
            dailyData['trainingCount'] as number ?? 0,
            dailyData['duration'] as number ?? 0,
            dailyData['weight'] as number ?? 0,
            dailyData['sets'] as number ?? 0,
            dailyData['calories'] as number ?? 0
          );
          dailyStats.push(daily);
        }

        // 解析 userId
        let userId: number = 0;
        const userIdValue: Object = statsData['userId'] ?? 0;
        if (typeof userIdValue === 'string') {
          const parsedUserId: number = parseInt(userIdValue as string, 10);
          if (!isNaN(parsedUserId)) {
            userId = parsedUserId;
          }
        } else {
          userId = userIdValue as number;
        }

        const stats: TrainingStatsModel = new TrainingStatsModel(
          userId,
          statsData['period'] as string ?? period,
          statsData['startDate'] as string ?? '',
          statsData['endDate'] as string ?? '',
          statsData['totalTrainingCount'] as number ?? 0,
          statsData['totalDuration'] as number ?? 0,
          statsData['totalWeight'] as number ?? 0,
          statsData['totalSets'] as number ?? 0,
          statsData['totalCalories'] as number ?? 0,
          statsData['avgDuration'] as number ?? 0,
          statsData['avgWeight'] as number ?? 0,
          statsData['mostTrainedMuscle'] as string ?? '',
          statsData['favoriteExercise'] as string ?? '',
          dailyStats
        );

        response.data = stats;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return StatsApiService.createErrorResponse(6001, '获取训练统计失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取肌群训练统计
   * GET /stats/muscle-groups?period=month
   */
  static async getMuscleGroupStats(period: string = 'month'): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/stats/muscle-groups?period=${period}`,
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const statsArray: Object[] = response.data as Object[];
        const muscleGroupStats: MuscleGroupStatsModel[] = [];

        for (let i: number = 0; i < statsArray.length; i++) {
          const statsData: Record<string, Object> = statsArray[i] as Record<string, Object>;
          const stat: MuscleGroupStatsModel = new MuscleGroupStatsModel(
            statsData['muscleGroup'] as string ?? '',
            statsData['trainingCount'] as number ?? 0,
            statsData['totalWeight'] as number ?? 0,
            statsData['percentage'] as number ?? 0
          );
          muscleGroupStats.push(stat);
        }

        response.data = muscleGroupStats;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return StatsApiService.createErrorResponse(6002, '获取肌群统计失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取个人记录 (PR - Personal Record)
   * GET /stats/personal-records
   */
  static async getPersonalRecords(): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        '/stats/personal-records',
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const recordsArray: Object[] = response.data as Object[];
        const personalRecords: PersonalRecordModel[] = [];

        for (let i: number = 0; i < recordsArray.length; i++) {
          const recordData: Record<string, Object> = recordsArray[i] as Record<string, Object>;
          const record: PersonalRecordModel = new PersonalRecordModel(
            recordData['exerciseName'] as string ?? '',
            recordData['maxWeight'] as number ?? 0,
            recordData['date'] as string ?? '',
            recordData['recordId'] as number ?? 0
          );
          personalRecords.push(record);
        }

        response.data = personalRecords;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return StatsApiService.createErrorResponse(6003, '获取个人记录失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取训练日历数据
   * GET /stats/calendar?year=2025&month=11
   */
  static async getCalendar(year: number, month: number): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/stats/calendar?year=${year}&month=${month}`,
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const daysArray: Object[] = response.data as Object[];
        const calendarDays: CalendarDayModel[] = [];

        for (let i: number = 0; i < daysArray.length; i++) {
          const dayData: Record<string, Object> = daysArray[i] as Record<string, Object>;
          const day: CalendarDayModel = new CalendarDayModel(
            dayData['date'] as string ?? '',
            dayData['hasTraining'] as boolean ?? false,
            dayData['trainingCount'] as number ?? 0,
            dayData['totalDuration'] as number ?? 0
          );
          calendarDays.push(day);
        }

        response.data = calendarDays;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return StatsApiService.createErrorResponse(6004, '获取日历数据失败: ' + JSON.stringify(error));
    }
  }
}
