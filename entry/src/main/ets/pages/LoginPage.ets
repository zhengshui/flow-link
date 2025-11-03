/**
 * 登录页面 - Login
 * 支持账号密码登录
 */

import { AuthApiService, LoginData, StorageConst, StorageUtils, toast, UserInfoData } from '@tbs/common';
import { router } from '@kit.ArkUI';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

@Entry
@Component
struct LoginPage {
  @State username: string = ''
  @State password: string = ''
  @State isLoading: boolean = false

  /**
   * 执行登录
   */
  async login(): Promise<void> {
    if (!this.username) {
      toast('请输入用户名');
      return;
    }
    if (!this.password) {
      toast('请输入密码');
      return;
    }

    this.isLoading = true;

    try {
      const res: ResponseResult = await AuthApiService.login(this.username, this.password);

      if (res.code === 0 && res.data) {
        const loginData: LoginData = res.data as LoginData;
        const token: string = loginData.token;

        // 保存 token
        StorageUtils.saveValueSync(StorageConst.TOKEN, token);

        // 获取用户信息
        const userInfoRes: ResponseResult = await AuthApiService.getUserInfo();
        if (userInfoRes.code === 0 && userInfoRes.data) {
          const userInfo: UserInfoData = userInfoRes.data as UserInfoData;
          StorageUtils.saveValueSync(StorageConst.USER_INFO, userInfo);
        }

        toast('登录成功');

        // 跳转到主页
        router.replaceUrl({
          url: 'home/HomePage'
        }).catch((err: Error) => {
          console.error('跳转失败:', JSON.stringify(err));
        });
      } else {
        toast(res.message ?? '登录失败');
      }
    } catch (err) {
      console.error('登录失败:', JSON.stringify(err));
      toast('登录失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 跳转到注册页
   */
  goToRegister(): void {
    router.pushUrl({
      url: 'pages/RegisterPage'
    }).catch((err: Error) => {
      console.error('跳转失败:', JSON.stringify(err));
    });
  }

  build() {
    Column({ space: 20 }) {
      // 顶部Logo和标题
      Column({ space: 16 }) {
        // Logo
        Text('💪')
          .fontSize(80)
          .margin({ top: 80 })

        // 应用名称
        Text('FitEasy')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        // 欢迎语
        Text('健身易 - 让健身更简单')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')

      // 表单区域
      Column({ space: 16 }) {
        // 用户名输入框
        TextInput({ placeholder: '请输入用户名' })
          .width('100%')
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.username = value;
          })

        // 密码输入框
        TextInput({ placeholder: '请输入密码' })
          .width('100%')
          .height(48)
          .type(InputType.Password)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.password = value;
          })

        // 登录按钮
        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#007AFF')
          .borderRadius(8)
          .opacity((this.username.length > 0 && this.password.length > 0 && !this.isLoading) ? 1 : 0.5)
          .enabled(this.username.length > 0 && this.password.length > 0 && !this.isLoading)
          .onClick(() => {
            this.login();
          })
      }
      .width('90%')
      .padding(20)
      .margin({ top: 40 })

      // 底部提示
      Row({ space: 4 }) {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#666666')

        Text('立即注册')
          .fontSize(14)
          .fontColor('#007AFF')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.goToRegister();
          })
      }

      // 测试账号提示
      Column({ space: 8 }) {
        Text('测试账号')
          .fontSize(12)
          .fontColor('#999999')

        Text('用户名: admin 或 test')
          .fontSize(11)
          .fontColor('#CCCCCC')

        Text('密码: 123456')
          .fontSize(11)
          .fontColor('#CCCCCC')
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .alignItems(HorizontalAlign.Center)
  }
}
