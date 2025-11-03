/**
 * Mock 认证服务
 * 模拟登录、注册、用户信息等接口
 */

import { ResponseResult } from '../http/response';
import { LoginData, UserInfoData } from '../model/AuthModel';

export async function mockDelay(ms: number = 500): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout((): void => {
      resolve();
    }, ms);
  });
}

class UserRecord {
  username: string = ''
  password: string = ''
  userInfo: UserInfoData = new UserInfoData()

  constructor(username: string, password: string, userInfo: UserInfoData) {
    this.username = username;
    this.password = password;
    this.userInfo = userInfo;
  }
}

const mockUsers: UserRecord[] = [
  new UserRecord('admin', '123456', new UserInfoData(
    1, 'admin', '健身管理员', '', 'admin@fiteasy.com', '13800138000', '男', 28, 175, 70, 68, '增肌', '2024-01-01'
  )),
  new UserRecord('test', '123456', new UserInfoData(
    2, 'test', '测试用户', '', 'test@fiteasy.com', '13900139000', '女', 25, 165, 55, 50, '减脂', '2024-02-01'
  ))
];

let currentUser: UserInfoData | null = null;

export class MockAuthService {
  static async login(username: string, password: string): Promise<ResponseResult> {
    await mockDelay(800);

    if (!username || !password) {
      return {
        code: 1001,
        message: '用户名或密码不能为空',
        data: null
      };
    }

    let foundUser: UserRecord | null = null;
    for (let i: number = 0; i < mockUsers.length; i++) {
      if (mockUsers[i].username === username) {
        foundUser = mockUsers[i];
        break;
      }
    }

    if (foundUser !== null && foundUser.password === password) {
      const timestamp: number = Date.now();
      const loginData: LoginData = new LoginData(
        `fiteasy_token_${timestamp}_${username}`,
        username === 'admin' ? 'admin' : 'user'
      );

      currentUser = foundUser.userInfo;

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

    for (let i: number = 0; i < mockUsers.length; i++) {
      if (mockUsers[i].username === username) {
        return {
          code: 2002,
          message: '用户名已存在',
          data: null
        };
      }
    }

    const newUserId: number = mockUsers.length + 1;
    const newUser: UserInfoData = new UserInfoData(
      newUserId, username, nickname, '', email, '', '', 0, 0, 0, 0, '', MockAuthService.getTodayString()
    );

    mockUsers.push(new UserRecord(username, password, newUser));

    return {
      code: 0,
      message: '注册成功',
      data: 0
    };
  }

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

  static async updateUserInfo(userInfo: UserInfoData): Promise<ResponseResult> {
    await mockDelay(500);

    if (currentUser === null) {
      return {
        code: 3001,
        message: '未登录',
        data: null
      };
    }

    currentUser = userInfo;

    for (let i: number = 0; i < mockUsers.length; i++) {
      if (mockUsers[i].username === currentUser.username) {
        mockUsers[i].userInfo = userInfo;
        break;
      }
    }

    return {
      code: 0,
      message: '更新成功',
      data: userInfo
    };
  }

  static async logout(): Promise<ResponseResult> {
    await mockDelay(300);
    currentUser = null;
    return {
      code: 0,
      message: '登出成功',
      data: null
    };
  }

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
