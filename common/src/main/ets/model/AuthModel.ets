/**
 * 认证相关数据模型
 */

/**
 * 登录响应数据
 */
export class LoginData {
  token: string = ''
  role: string = ''

  constructor(token: string, role: string) {
    this.token = token;
    this.role = role;
  }
}

/**
 * 用户信息数据
 */
export class UserInfoData {
  id: number = 0
  username: string = ''
  nickname: string = ''
  avatarUrl: string = ''
  email: string = ''
  phone: string = ''
  gender: string = ''
  age: number = 0
  height: number = 0
  weight: number = 0
  targetWeight: number = 0
  fitnessGoal: string = ''
  joinDate: string = ''

  constructor(
    id: number = 0,
    username: string = '',
    nickname: string = '',
    avatarUrl: string = '',
    email: string = '',
    phone: string = '',
    gender: string = '',
    age: number = 0,
    height: number = 0,
    weight: number = 0,
    targetWeight: number = 0,
    fitnessGoal: string = '',
    joinDate: string = ''
  ) {
    this.id = id;
    this.username = username;
    this.nickname = nickname;
    this.avatarUrl = avatarUrl;
    this.email = email;
    this.phone = phone;
    this.gender = gender;
    this.age = age;
    this.height = height;
    this.weight = weight;
    this.targetWeight = targetWeight;
    this.fitnessGoal = fitnessGoal;
    this.joinDate = joinDate;
  }
}
