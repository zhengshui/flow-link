/**
 * 训练记录 API 服务
 * 处理训练记录相关的后端接口调用
 */

import http from '@ohos.net.http';
import { requestApiCall } from '../http/httpUtils';
import { ResponseResult } from '../http/response';
import { TrainingRecordModel } from '../model/TrainingRecordModel';
import { ExerciseModel } from '../model/ExerciseModel';

export class TrainingApiService {
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
   * 获取训练记录列表
   * GET /training/records?page=1&pageSize=20&startDate=xxx&endDate=xxx&planId=xxx
   */
  static async getTrainingRecords(
    page: number = 1,
    pageSize: number = 20,
    startDate: string = '',
    endDate: string = '',
    planId: number = 0
  ): Promise<ResponseResult> {
    try {
      let url: string = `/training/records?page=${page}&pageSize=${pageSize}`;

      if (startDate) {
        url += `&startDate=${startDate}`;
      }
      if (endDate) {
        url += `&endDate=${endDate}`;
      }
      if (planId > 0) {
        url += `&planId=${planId}`;
      }

      console.log('[TrainingApiService] getTrainingRecords - URL:', url);

      const response: ResponseResult = await requestApiCall(
        url,
        http.RequestMethod.GET
      );

      console.log('[TrainingApiService] getTrainingRecords - Response code:', response.code);
      console.log('[TrainingApiService] getTrainingRecords - Response data:', JSON.stringify(response.data));

      if (response.code === 200 && response.data) {
        const apiData: Record<string, Object> = response.data as Record<string, Object>;
        const recordsArray: Object[] = apiData['records'] as Object[] ?? [];
        console.log('[TrainingApiService] getTrainingRecords - recordsArray length:', recordsArray.length);

        const records: TrainingRecordModel[] = [];
        for (let i: number = 0; i < recordsArray.length; i++) {
          const recordData: Record<string, Object> = recordsArray[i] as Record<string, Object>;
          const record: TrainingRecordModel = TrainingApiService.parseTrainingRecord(recordData);
          records.push(record);
        }

        console.log('[TrainingApiService] getTrainingRecords - Parsed records count:', records.length);

        response.data = {
          total: apiData['total'] ?? 0,
          page: apiData['page'] ?? page,
          pageSize: apiData['pageSize'] ?? pageSize,
          records: records
        };
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      } else {
        console.error('[TrainingApiService] getTrainingRecords - Failed with code:', response.code, 'message:', response.message);
      }

      return response;
    } catch (error) {
      console.error('[TrainingApiService] getTrainingRecords - Exception:', JSON.stringify(error));
      return TrainingApiService.createErrorResponse(4001, '获取训练记录失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取单条训练记录
   * GET /training/records/{recordId}
   */
  static async getTrainingRecord(recordId: string): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/training/records/${recordId}`,
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const recordData: Record<string, Object> = response.data as Record<string, Object>;
        const record: TrainingRecordModel = TrainingApiService.parseTrainingRecord(recordData);
        response.data = record;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return TrainingApiService.createErrorResponse(4002, '获取训练记录失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 创建训练记录
   * POST /training/records
   */
  static async createTrainingRecord(record: TrainingRecordModel): Promise<ResponseResult> {
    try {
      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'title': record.title,
        'date': record.date,
        'startTime': record.startTime,
        'endTime': record.endTime,
        'duration': record.duration,
        'exercises': [],
        'totalWeight': record.totalWeight,
        'totalSets': record.totalSets,
        'caloriesBurned': record.caloriesBurned,
        'notes': record.notes,
        'mood': record.mood,
        'planId': record.planId
      };

      // 转换训练项目
      const exercisesArray: Object[] = [];
      for (let i: number = 0; i < record.exercises.length; i++) {
        const exercise: ExerciseModel = record.exercises[i];
        const exerciseData: Record<string, number | boolean | string | Object | undefined> = {
          'name': exercise.name,
          'sets': exercise.sets,
          'reps': exercise.reps,
          'weight': exercise.weight,
          'restTime': exercise.restTime,
          'muscleGroup': exercise.muscleGroup,
          'notes': exercise.notes,
          'duration': exercise.duration
        };
        exercisesArray.push(exerciseData);
      }
      requestData['exercises'] = exercisesArray;

      const response: ResponseResult = await requestApiCall(
        '/training/records',
        http.RequestMethod.POST,
        requestData
      );

      if (response.code === 200 && response.data) {
        const recordData: Record<string, Object> = response.data as Record<string, Object>;
        const newRecord: TrainingRecordModel = TrainingApiService.parseTrainingRecord(recordData);
        response.data = newRecord;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return TrainingApiService.createErrorResponse(4003, '创建训练记录失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 更新训练记录
   * PUT /training/records/{recordId}
   */
  static async updateTrainingRecord(recordId: string, record: TrainingRecordModel): Promise<ResponseResult> {
    try {
      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'title': record.title,
        'date': record.date,
        'startTime': record.startTime,
        'endTime': record.endTime,
        'duration': record.duration,
        'exercises': [],
        'totalWeight': record.totalWeight,
        'totalSets': record.totalSets,
        'caloriesBurned': record.caloriesBurned,
        'notes': record.notes,
        'mood': record.mood,
        'planId': record.planId
      };

      // 转换训练项目
      const exercisesArray: Object[] = [];
      for (let i: number = 0; i < record.exercises.length; i++) {
        const exercise: ExerciseModel = record.exercises[i];
        const exerciseData: Record<string, number | boolean | string | Object | undefined> = {
          'name': exercise.name,
          'sets': exercise.sets,
          'reps': exercise.reps,
          'weight': exercise.weight,
          'restTime': exercise.restTime,
          'muscleGroup': exercise.muscleGroup,
          'notes': exercise.notes,
          'duration': exercise.duration
        };
        exercisesArray.push(exerciseData);
      }
      requestData['exercises'] = exercisesArray;

      const response: ResponseResult = await requestApiCall(
        `/training/records/${recordId}`,
        http.RequestMethod.PUT,
        requestData
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return TrainingApiService.createErrorResponse(4004, '更新训练记录失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 删除训练记录
   * DELETE /training/records/{recordId}
   */
  static async deleteTrainingRecord(recordId: string): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/training/records/${recordId}`,
        http.RequestMethod.DELETE
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return TrainingApiService.createErrorResponse(4005, '删除训练记录失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 解析训练记录数据
   */
  private static parseTrainingRecord(data: Record<string, Object>): TrainingRecordModel {
    const exercisesData: Object[] = data['exercises'] as Object[] ?? [];
    const exercises: ExerciseModel[] = [];

    for (let i: number = 0; i < exercisesData.length; i++) {
      const exData: Record<string, Object> = exercisesData[i] as Record<string, Object>;
      const exercise: ExerciseModel = new ExerciseModel(
        exData['id'] as number ?? 0,
        exData['name'] as string ?? '',
        exData['sets'] as number ?? 0,
        exData['reps'] as number ?? 0,
        exData['weight'] as number ?? 0,
        exData['restTime'] as number ?? 0,
        exData['muscleGroup'] as string ?? '',
        exData['notes'] as string ?? '',
        exData['duration'] as number ?? 0
      );
      exercises.push(exercise);
    }

    // 将字符串 ID 转换为数字
    let recordId: number = 0;
    const idValue: Object = data['id'] ?? 0;
    if (typeof idValue === 'string') {
      const parsedId: number = parseInt(idValue as string, 10);
      if (!isNaN(parsedId)) {
        recordId = parsedId;
      }
    } else {
      recordId = idValue as number;
    }

    const record: TrainingRecordModel = new TrainingRecordModel(
      recordId,
      0, // userId - 不需要前端处理
      data['title'] as string ?? '',
      data['date'] as string ?? '',
      data['startTime'] as string ?? '',
      data['endTime'] as string ?? '',
      data['duration'] as number ?? 0,
      exercises,
      data['totalWeight'] as number ?? 0,
      data['totalSets'] as number ?? 0,
      data['caloriesBurned'] as number ?? 0,
      data['notes'] as string ?? '',
      data['mood'] as string ?? '',
      data['planId'] as number ?? 0,
      data['createdAt'] as string ?? '',
      data['updatedAt'] as string ?? ''
    );

    return record;
  }
}
