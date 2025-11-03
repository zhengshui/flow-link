/**
 * 认证 API 服务
 * 真实后端接口调用
 */

import http from '@ohos.net.http';
import { requestApiCall } from '../http/httpUtils';
import { ResponseResult } from '../http/response';
import { LoginData, UserInfoData } from '../model/AuthModel';

export class AuthApiService {
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
   * 用户登录
   * POST /login
   */
  static async login(username: string, password: string): Promise<ResponseResult> {
    try {
      const loginData: Record<string, number | boolean | string | Object | undefined> = {
        'username': username,
        'password': password
      };
      const response: ResponseResult = await requestApiCall(
        '/auth/login',
        http.RequestMethod.POST,
        loginData
      );

      // 后端返回格式: {code, message, data: {token, role}}
      // 需要转换为 LoginData 格式
      if (response.code === 200 && response.data) {
        const apiData: Record<string, Object> = response.data as Record<string, Object>;
        const token: string = apiData['token'] as string;
        const role: string = apiData['role'] as string;

        response.data = new LoginData(token, role);
        response.code = 0; // 前端统一使用 0 表示成功
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return AuthApiService.createErrorResponse(1002, '登录失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 用户注册
   * POST /auth/register
   */
  static async register(
    username: string,
    password: string,
    nickname: string,
    email: string,
    phone: string = '',
    gender: string = '',
    age: number = 0,
    height: number = 0,
    weight: number = 0,
    targetWeight: number = 0,
    fitnessGoal: string = ''
  ): Promise<ResponseResult> {
    try {
      const requestData: Record<string, number | boolean | string | Object | undefined> = {
        'username': username,
        'password': password,
        'nickname': nickname
      };

      if (email) {
        requestData['email'] = email;
      }
      if (phone) {
        requestData['phone'] = phone;
      }
      if (gender) {
        requestData['gender'] = gender;
      }
      if (age > 0) {
        requestData['age'] = age;
      }
      if (height > 0) {
        requestData['height'] = height;
      }
      if (weight > 0) {
        requestData['weight'] = weight;
      }
      if (targetWeight > 0) {
        requestData['targetWeight'] = targetWeight;
      }
      if (fitnessGoal) {
        requestData['fitnessGoal'] = fitnessGoal;
      }

      const response: ResponseResult = await requestApiCall(
        '/auth/register',
        http.RequestMethod.POST,
        requestData
      );

      // 转换响应码
      if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return AuthApiService.createErrorResponse(2001, '注册失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取用户信息
   * GET /user/info
   */
  static async getUserInfo(): Promise<ResponseResult> {
    try {
      const response: ResponseResult = await requestApiCall(
        '/user/info',
        http.RequestMethod.GET
      );

      // 后端返回的用户信息需要转换为 UserInfoData 格式
      if (response.code === 200 && response.data) {
        const apiData: Record<string, Object> = response.data as Record<string, Object>;

        const userInfo: UserInfoData = new UserInfoData(
          apiData['id'] as number,
          apiData['username'] as string,
          apiData['nickname'] as string ?? '',
          apiData['avatarUrl'] as string ?? '',
          apiData['email'] as string ?? '',
          apiData['phone'] as string ?? '',
          apiData['gender'] as string ?? '',
          apiData['age'] as number ?? 0,
          apiData['height'] as number ?? 0,
          apiData['weight'] as number ?? 0,
          apiData['targetWeight'] as number ?? 0,
          apiData['fitnessGoal'] as string ?? '',
          apiData['joinDate'] as string ?? ''
        );

        response.data = userInfo;
        response.code = 0;
      } else if (response.code === 200) {
        response.code = 0;
      }

      return response;
    } catch (error) {
      return AuthApiService.createErrorResponse(3001, '获取用户信息失败: ' + JSON.stringify(error));
    }
  }

  /**
   * 更新用户信息
   * PUT /user/info
   */
  static async updateUserInfo(userInfo: UserInfoData): Promise<ResponseResult> {
    try {
      const requestData: Record<string, number | boolean | string | Object | undefined> = {};

      if (userInfo.nickname) {
        requestData['nickname'] = userInfo.nickname;
      }
      if (userInfo.avatarUrl) {
        requestData['avatarUrl'] = userInfo.avatarUrl;
      }
      if (userInfo.email) {
        requestData['email'] = userInfo.email;
      }
      if (userInfo.phone) {
        requestData['phone'] = userInfo.phone;
      }
      if (userInfo.gender) {
        requestData['gender'] = userInfo.gender;
      }
      if (userInfo.age > 0) {
        requestData['age'] = userInfo.age;
      }
      if (userInfo.height > 0) {
        requestData['height'] = userInfo.height;
      }
      if (userInfo.weight > 0) {
        requestData['weight'] = userInfo.weight;
      }
      if (userInfo.targetWeight > 0) {
        requestData['targetWeight'] = userInfo.targetWeight;
      }
      if (userInfo.fitnessGoal) {
        requestData['fitnessGoal'] = userInfo.fitnessGoal;
      }

      const response: ResponseResult = await requestApiCall(
        '/user/info',
        http.RequestMethod.PUT,
        requestData
      );

      if (response.code === 200) {
        response.code = 0;
        response.data = userInfo;
      }

      return response;
    } catch (error) {
      return AuthApiService.createErrorResponse(3002, '更新用户信息失败: ' + JSON.stringify(error));
    }
  }

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
}
