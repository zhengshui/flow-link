/**
 * 健身计划和模板 API 服务
 * 处理健身计划和计划模板相关的后端接口调用
 */

import http from '@ohos.net.http';
import { requestApiCall } from '../http/httpUtils';
import { ResponseResult } from '../http/response';
import { FitnessPlanModel } from '../model/FitnessPlanModel';
import { PlanTemplateModel, TrainingDayModel } from '../model/PlanTemplateModel';
import { ExerciseModel } from '../model/ExerciseModel';

export class PlanApiService {
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
   * 获取计划模板列表 (公开接口,无需认证)
   * GET /templates?page=1&pageSize=20&goal=xxx&level=xxx&splitType=xxx&equipment=xxx
   */
  static async getPlanTemplates(
    page: number = 1,
    pageSize: number = 20,
    goal: string = '',
    level: string = '',
    splitType: string = '',
    equipment: string = '',
    durationWeeksMin: number = 0,
    durationWeeksMax: number = 0,
    isOfficial: boolean = true
  ): Promise<ResponseResult> {
    try {
      let url: string = `/templates?page=${page}&pageSize=${pageSize}`;

      if (goal) {
        url += `&goal=${goal}`;
      }
      if (level) {
        url += `&level=${level}`;
      }
      if (splitType) {
        url += `&splitType=${splitType}`;
      }
      if (equipment) {
        url += `&equipment=${equipment}`;
      }
      if (durationWeeksMin > 0) {
        url += `&durationWeeksMin=${durationWeeksMin}`;
      }
      if (durationWeeksMax > 0) {
        url += `&durationWeeksMax=${durationWeeksMax}`;
      }
      url += `&isOfficial=${isOfficial}`;

      const response: ResponseResult = await requestApiCall(
        url,
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const apiData: Record<string, Object> = response.data as Record<string, Object>;
        const templatesArray: Object[] = apiData['templates'] as Object[] ?? [];

        const templates: PlanTemplateModel[] = [];
        for (let i: number = 0; i < templatesArray.length; i++) {
          const templateData: Record<string, Object> = templatesArray[i] as Record<string, Object>;
          const template: PlanTemplateModel = PlanApiService.parsePlanTemplate(templateData);
          templates.push(template);
        }

        response.data = {
          total: apiData['total'] ?? 0,
          page: apiData['page'] ?? page,
          pageSize: apiData['pageSize'] ?? pageSize,
          templates: templates
        };
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5001, '获取计划模板失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取单个计划模板详情
   * GET /templates/{templateId}
   */
  static async getPlanTemplate(templateId: string): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/templates/${templateId}`,
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const templateData: Record<string, Object> = response.data as Record<string, Object>;
        const template: PlanTemplateModel = PlanApiService.parsePlanTemplate(templateData);
        response.data = template;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5002, '获取计划模板失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 创建个人模板
   * POST /templates/custom
   */
  static async createCustomTemplate(template: PlanTemplateModel): Promise<ResponseResult> {
    try {
      const trainingDaysArray: Object[] = PlanApiService.serializeTrainingDays(template.trainingDays);

      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'name': template.name,
        'description': template.description,
        'goal': template.goal,
        'splitType': template.splitType,
        'level': template.level,
        'equipment': template.equipment,
        'durationWeeks': template.durationWeeks,
        'trainingDaysPerWeek': template.trainingDaysPerWeek,
        'trainingDays': trainingDaysArray,
        'tags': template.tags,
        'imageUrl': template.imageUrl
      };

      const response: ResponseResult = await requestApiCall(
        '/templates/custom',
        http.RequestMethod.POST,
        requestData
      );

      if (response.code === 200 && response.data) {
        const templateData: Record<string, Object> = response.data as Record<string, Object>;
        const newTemplate: PlanTemplateModel = PlanApiService.parsePlanTemplate(templateData);
        response.data = newTemplate;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5010, '创建个人模板失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 复制官方模板为个人模板
   * POST /templates/{templateId}/duplicate
   */
  static async duplicateTemplate(templateId: string): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/templates/${templateId}/duplicate`,
        http.RequestMethod.POST
      );

      if (response.code === 200 && response.data) {
        const templateData: Record<string, Object> = response.data as Record<string, Object>;
        const newTemplate: PlanTemplateModel = PlanApiService.parsePlanTemplate(templateData);
        response.data = newTemplate;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5011, '复制模板失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 更新个人模板
   * PUT /templates/{templateId}
   */
  static async updateTemplate(templateId: string, template: PlanTemplateModel): Promise<ResponseResult> {
    try {
      const trainingDaysArray: Object[] = PlanApiService.serializeTrainingDays(template.trainingDays);

      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'name': template.name,
        'description': template.description,
        'goal': template.goal,
        'splitType': template.splitType,
        'level': template.level,
        'equipment': template.equipment,
        'durationWeeks': template.durationWeeks,
        'trainingDaysPerWeek': template.trainingDaysPerWeek,
        'trainingDays': trainingDaysArray,
        'tags': template.tags,
        'imageUrl': template.imageUrl
      };

      const response: ResponseResult = await requestApiCall(
        `/templates/${templateId}`,
        http.RequestMethod.PUT,
        requestData
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5012, '更新模板失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 删除个人模板
   * DELETE /templates/{templateId}
   */
  static async deleteTemplate(templateId: string): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/templates/${templateId}`,
        http.RequestMethod.DELETE
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5013, '删除模板失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取用户健身计划列表
   * GET /plans?page=1&pageSize=20&status=xxx
   */
  static async getFitnessPlans(
    page: number = 1,
    pageSize: number = 20,
    status: string = ''
  ): Promise<ResponseResult> {
    try {
      let url: string = `/plans?page=${page}&pageSize=${pageSize}`;

      if (status) {
        url += `&status=${status}`;
      }

      const response: ResponseResult = await requestApiCall(
        url,
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const apiData: Record<string, Object> = response.data as Record<string, Object>;
        const plansArray: Object[] = apiData['plans'] as Object[] ?? [];

        const plans: FitnessPlanModel[] = [];
        for (let i: number = 0; i < plansArray.length; i++) {
          const planData: Record<string, Object> = plansArray[i] as Record<string, Object>;
          const plan: FitnessPlanModel = PlanApiService.parseFitnessPlan(planData);
          plans.push(plan);
        }

        response.data = {
          total: apiData['total'] ?? 0,
          page: apiData['page'] ?? page,
          pageSize: apiData['pageSize'] ?? pageSize,
          plans: plans
        };
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5003, '获取健身计划失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取单个健身计划详情
   * GET /plans/{planId}
   */
  static async getFitnessPlan(planId: string): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/plans/${planId}`,
        http.RequestMethod.GET
      );

      if (response.code === 200 && response.data) {
        const planData: Record<string, Object> = response.data as Record<string, Object>;
        const plan: FitnessPlanModel = PlanApiService.parseFitnessPlan(planData);
        response.data = plan;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5004, '获取健身计划失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 基于模板创建健身计划
   * POST /plans/from-template
   */
  static async createPlanFromTemplate(templateId: number, startDate: string, name: string = ''): Promise<ResponseResult> {
    try {
      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'templateId': templateId,
        'startDate': startDate
      };

      if (name) {
        requestData['name'] = name;
      }

      const response: ResponseResult = await requestApiCall(
        '/plans/from-template',
        http.RequestMethod.POST,
        requestData
      );

      if (response.code === 200 && response.data) {
        const planData: Record<string, Object> = response.data as Record<string, Object>;
        const plan: FitnessPlanModel = PlanApiService.parseFitnessPlan(planData);
        response.data = plan;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5005, '创建健身计划失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 创建自定义健身计划
   * POST /plans/custom
   */
  static async createCustomPlan(plan: FitnessPlanModel): Promise<ResponseResult> {
    try {
      const trainingDaysArray: Object[] = [];
      for (let i: number = 0; i < plan.trainingDays.length; i++) {
        const day: TrainingDayModel = plan.trainingDays[i];
        const exercisesArray: Object[] = [];

        for (let j: number = 0; j < day.exercises.length; j++) {
          const exercise: ExerciseModel = day.exercises[j];
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

        const dayData: Record<string, number | boolean | string | Object | undefined> = {
          'dayNumber': day.dayNumber,
          'dayName': day.dayName,
          'isRestDay': day.isRestDay,
          'exercises': exercisesArray,
          'notes': day.notes
        };
        trainingDaysArray.push(dayData);
      }

      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'name': plan.name,
        'description': plan.description,
        'goal': plan.goal,
        'durationWeeks': plan.durationWeeks,
        'trainingDaysPerWeek': plan.trainingDaysPerWeek,
        'trainingDays': trainingDaysArray,
        'startDate': plan.startDate
      };

      const response: ResponseResult = await requestApiCall(
        '/plans/custom',
        http.RequestMethod.POST,
        requestData
      );

      if (response.code === 200 && response.data) {
        const planData: Record<string, Object> = response.data as Record<string, Object>;
        const newPlan: FitnessPlanModel = PlanApiService.parseFitnessPlan(planData);
        response.data = newPlan;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5006, '创建自定义计划失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 标记训练日为已完成
   * POST /plans/{planId}/complete-day
   */
  static async completePlanDay(planId: string, dayNumber: number, recordId: number = 0): Promise<ResponseResult> {
    try {
      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'dayNumber': dayNumber
      };

      if (recordId > 0) {
        requestData['recordId'] = recordId;
      }

      const response: ResponseResult = await requestApiCall(
        `/plans/${planId}/complete-day`,
        http.RequestMethod.POST,
        requestData
      );

      if (response.code === 200 && response.data) {
        const planData: Record<string, Object> = response.data as Record<string, Object>;
        const plan: FitnessPlanModel = PlanApiService.parseFitnessPlan(planData);
        response.data = plan;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5007, '标记完成失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取计划进度摘要
   * GET /plans/{planId}/progress
   */
  static async getPlanProgress(planId: string): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/plans/${planId}/progress`,
        http.RequestMethod.GET
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5014, '获取计划进度失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 跳过计划日
   * POST /plans/{planId}/skip-day
   */
  static async skipPlanDay(planId: string, dayNumber: number, reason: string = ''): Promise<ResponseResult> {
    try {
      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'dayNumber': dayNumber
      };

      if (reason) {
        requestData['reason'] = reason;
      }

      const response: ResponseResult = await requestApiCall(
        `/plans/${planId}/skip-day`,
        http.RequestMethod.POST,
        requestData
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5015, '跳过训练日失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 临时调整计划日动作
   * POST /plans/{planId}/adjust-day
   */
  static async adjustPlanDay(
    planId: string,
    dayNumber: number,
    exercises: ExerciseModel[],
    notes: string = ''
  ): Promise<ResponseResult> {
    try {
      const exercisesArray: Object[] = [];
      for (let i: number = 0; i < exercises.length; i++) {
        const exercise: ExerciseModel = exercises[i];
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

      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'dayNumber': dayNumber,
        'exercises': exercisesArray,
        'notes': notes
      };

      const response: ResponseResult = await requestApiCall(
        `/plans/${planId}/adjust-day`,
        http.RequestMethod.POST,
        requestData
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5016, '调整训练日失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 更新计划状态
   * PUT /plans/{planId}/status
   */
  static async updatePlanStatus(planId: string, status: string): Promise<ResponseResult> {
    try {
      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'status': status
      };
      const response: ResponseResult = await requestApiCall(
        `/plans/${planId}/status`,
        http.RequestMethod.PUT,
        requestData
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5008, '更新计划状态失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 删除健身计划
   * DELETE /plans/{planId}
   */
  static async deleteFitnessPlan(planId: string): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        `/plans/${planId}`,
        http.RequestMethod.DELETE
      );

      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return PlanApiService.createErrorResponse(5009, '删除健身计划失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 序列化训练日程数据
   */
  private static serializeTrainingDays(trainingDays: TrainingDayModel[]): Object[] {
    const trainingDaysArray: Object[] = [];
    for (let i: number = 0; i < trainingDays.length; i++) {
      const day: TrainingDayModel = trainingDays[i];
      const exercisesArray: Object[] = [];

      for (let j: number = 0; j < day.exercises.length; j++) {
        const exercise: ExerciseModel = day.exercises[j];
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

      const dayData: Record<string, number | boolean | string | Object | undefined> = {
        'dayNumber': day.dayNumber,
        'dayName': day.dayName,
        'isRestDay': day.isRestDay,
        'exercises': exercisesArray,
        'notes': day.notes,
        'intensityHint': day.intensityHint,
        'warmupTips': day.warmupTips,
        'cooldownTips': day.cooldownTips
      };
      trainingDaysArray.push(dayData);
    }
    return trainingDaysArray;
  }

  /**
   * 解析计划模板数据
   */
  private static parsePlanTemplate(data: Record<string, Object>): PlanTemplateModel {
    const trainingDaysData: Object[] = data['trainingDays'] as Object[] ?? [];
    const trainingDays: TrainingDayModel[] = PlanApiService.parseTrainingDays(trainingDaysData);

    // 解析 ID
    let templateId: number = 0;
    const idValue: Object = data['id'] ?? 0;
    if (typeof idValue === 'string') {
      const parsedId: number = parseInt(idValue as string, 10);
      if (!isNaN(parsedId)) {
        templateId = parsedId;
      }
    } else {
      templateId = idValue as number;
    }

    // 解析 tags
    const tagsData: Object[] = data['tags'] as Object[] ?? [];
    const tags: string[] = [];
    for (let i: number = 0; i < tagsData.length; i++) {
      tags.push(tagsData[i] as string);
    }

    const template: PlanTemplateModel = new PlanTemplateModel(
      templateId,
      data['name'] as string ?? '',
      data['description'] as string ?? '',
      data['goal'] as string ?? '',
      data['level'] as string ?? '',
      data['durationWeeks'] as number ?? 0,
      data['trainingDaysPerWeek'] as number ?? 0,
      trainingDays,
      data['imageUrl'] as string ?? '',
      data['author'] as string ?? '',
      tags,
      data['createdAt'] as string ?? '',
      data['splitType'] as string ?? '',
      data['equipment'] as string ?? '',
      data['recommendedIntensity'] as string ?? '',
      data['isOfficial'] as boolean ?? true,
      data['userId'] as number ?? 0
    );

    return template;
  }

  /**
   * 解析健身计划数据
   */
  private static parseFitnessPlan(data: Record<string, Object>): FitnessPlanModel {
    const trainingDaysData: Object[] = data['trainingDays'] as Object[] ?? [];
    const trainingDays: TrainingDayModel[] = PlanApiService.parseTrainingDays(trainingDaysData);

    // 解析覆盖日程
    const trainingDaysOverrideData: Object[] = data['trainingDaysOverride'] as Object[] ?? [];
    const trainingDaysOverride: TrainingDayModel[] =
      PlanApiService.parseTrainingDays(trainingDaysOverrideData);

    // 解析 ID
    let planId: number = 0;
    const idValue: Object = data['id'] ?? 0;
    if (typeof idValue === 'string') {
      const parsedId: number = parseInt(idValue as string, 10);
      if (!isNaN(parsedId)) {
        planId = parsedId;
      }
    } else {
      planId = idValue as number;
    }

    // 解析 completedDays
    const completedDaysData: Object[] = data['completedDays'] as Object[] ?? [];
    const completedDays: number[] = [];
    for (let i: number = 0; i < completedDaysData.length; i++) {
      completedDays.push(completedDaysData[i] as number);
    }

    // 解析 skippedDays
    const skippedDaysData: Object[] = data['skippedDays'] as Object[] ?? [];
    const skippedDays: number[] = [];
    for (let i: number = 0; i < skippedDaysData.length; i++) {
      skippedDays.push(skippedDaysData[i] as number);
    }

    const plan: FitnessPlanModel = new FitnessPlanModel(
      planId,
      0, // userId - 不需要前端处理
      data['templateId'] as number ?? 0,
      data['name'] as string ?? '',
      data['description'] as string ?? '',
      data['goal'] as string ?? '',
      data['durationWeeks'] as number ?? 0,
      data['trainingDaysPerWeek'] as number ?? 0,
      trainingDays,
      data['startDate'] as string ?? '',
      data['endDate'] as string ?? '',
      data['status'] as string ?? '',
      data['currentWeek'] as number ?? 0,
      data['currentDay'] as number ?? 0,
      completedDays,
      data['totalCompletedDays'] as number ?? 0,
      data['completionRate'] as number ?? 0,
      data['createdAt'] as string ?? '',
      data['updatedAt'] as string ?? '',
      data['durationWeeksOverride'] as number ?? 0,
      trainingDaysOverride,
      skippedDays,
      data['totalWeight'] as number ?? 0,
      data['totalDuration'] as number ?? 0,
      data['totalCalories'] as number ?? 0
    );

    return plan;
  }

  /**
   * 解析训练日程数据
   */
  private static parseTrainingDays(daysData: Object[]): TrainingDayModel[] {
    const trainingDays: TrainingDayModel[] = [];

    for (let i: number = 0; i < daysData.length; i++) {
      const dayData: Record<string, Object> = daysData[i] as Record<string, Object>;
      const exercisesData: Object[] = dayData['exercises'] as Object[] ?? [];
      const exercises: ExerciseModel[] = [];

      for (let j: number = 0; j < exercisesData.length; j++) {
        const exData: Record<string, Object> = exercisesData[j] as Record<string, Object>;
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

      const trainingDay: TrainingDayModel = new TrainingDayModel(
        dayData['dayNumber'] as number ?? 0,
        dayData['dayName'] as string ?? '',
        dayData['isRestDay'] as boolean ?? false,
        exercises,
        dayData['notes'] as string ?? '',
        dayData['intensityHint'] as string ?? '',
        dayData['warmupTips'] as string ?? '',
        dayData['cooldownTips'] as string ?? ''
      );
      trainingDays.push(trainingDay);
    }

    return trainingDays;
  }
}
