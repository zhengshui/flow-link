/**
 * Mock 认证服务
 * 模拟登录、注册、用户信息等接口
 */

import { ResponseResult } from '../http/response';
import { LoginData, UserInfoData } from '../model/AuthModel';

/**
 * 模拟异步请求延迟
 */
export async function mockDelay(ms: number = 500): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout((): void => {
      resolve();
    }, ms);
  });
}

/**
 * 模拟用户数据库
 */
const mockUsers: Map<string, { password: string, userInfo: UserInfoData }> = new Map([
  ['admin', {
    password: '123456',
    userInfo: new UserInfoData(
      1,
      'admin',
      '健身管理员',
      '',
      'admin@fiteasy.com',
      '13800138000',
      '男',
      28,
      175,
      70,
      68,
      '增肌',
      '2024-01-01'
    )
  }],
  ['test', {
    password: '123456',
    userInfo: new UserInfoData(
      2,
      'test',
      '测试用户',
      '',
      'test@fiteasy.com',
      '13900139000',
      '女',
      25,
      165,
      55,
      50,
      '减脂',
      '2024-02-01'
    )
  }]
]);

/**
 * 当前登录的用户信息
 */
let currentUser: UserInfoData | null = null;

export class MockAuthService {
  /**
   * 用户登录
   */
  static async login(username: string, password: string): Promise<ResponseResult> {
    await mockDelay(800);

    if (!username || !password) {
      return {
        code: 1001,
        message: '用户名或密码不能为空',
        data: null
      };
    }

    const userData: { password: string, userInfo: UserInfoData } | undefined = mockUsers.get(username);

    if (userData && userData.password === password) {
      const timestamp: number = Date.now();
      const loginData: LoginData = new LoginData(
        `fiteasy_token_${timestamp}_${username}`,
        username === 'admin' ? 'admin' : 'user'
      );

      // 保存当前用户信息
      currentUser = userData.userInfo;

      return {
        code: 0,
        message: '登录成功',
        data: loginData
      };
    } else {
      return {
        code: 1002,
        message: '用户名或密码错误',
        data: null
      };
    }
  }

  /**
   * 用户注册
   */
  static async register(
    username: string,
    password: string,
    nickname: string,
    email: string
  ): Promise<ResponseResult> {
    await mockDelay(1000);

    if (!username || !password || !nickname) {
      return {
        code: 2001,
        message: '请填写完整的注册信息',
        data: null
      };
    }

    if (mockUsers.has(username)) {
      return {
        code: 2002,
        message: '用户名已存在',
        data: null
      };
    }

    // 创建新用户
    const newUserId: number = mockUsers.size + 1;
    const newUser: UserInfoData = new UserInfoData(
      newUserId,
      username,
      nickname,
      '',
      email,
      '',
      '',
      0,
      0,
      0,
      0,
      '',
      MockAuthService.getTodayString()
    );

    mockUsers.set(username, {
      password: password,
      userInfo: newUser
    });

    return {
      code: 0,
      message: '注册成功',
      data: 0
    };
  }

  /**
   * 获取用户信息
   */
  static async getUserInfo(): Promise<ResponseResult> {
    await mockDelay(500);

    if (currentUser === null) {
      return {
        code: 3001,
        message: '未登录',
        data: null
      };
    }

    return {
      code: 0,
      message: '获取成功',
      data: currentUser
    };
  }

  /**
   * 更新用户信息
   */
  static async updateUserInfo(userInfo: UserInfoData): Promise<ResponseResult> {
    await mockDelay(500);

    if (currentUser === null) {
      return {
        code: 3001,
        message: '未登录',
        data: null
      };
    }

    // 更新当前用户信息
    currentUser = userInfo;

    // 更新 mockUsers 中的数据
    const userData: { password: string, userInfo: UserInfoData } | undefined = mockUsers.get(currentUser.username);
    if (userData) {
      userData.userInfo = userInfo;
    }

    return {
      code: 0,
      message: '更新成功',
      data: userInfo
    };
  }

  /**
   * 登出
   */
  static async logout(): Promise<ResponseResult> {
    await mockDelay(300);

    currentUser = null;

    return {
      code: 0,
      message: '登出成功',
      data: null
    };
  }

  /**
   * 获取今天日期字符串
   */
  static getTodayString(): string {
    const today: Date = new Date();
    const year: number = today.getFullYear();
    const month: number = today.getMonth() + 1;
    const day: number = today.getDate();
    return year.toString() + '-' +
      (month < 10 ? '0' : '') + month.toString() + '-' +
      (day < 10 ? '0' : '') + day.toString();
  }
}
