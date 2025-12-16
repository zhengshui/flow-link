/**
 * 注册页面 - Register
 * 新用户注册，注册成功后自动登录
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { AuthApiService, LoginData, StorageConst, StorageUtils, toast, UserInfoData } from '@tbs/common';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

/**
 * 系统路由表构建函数
 */
@Builder
export function RegisterPageBuilder(): void {
  RegisterPage()
}

@Component
export struct RegisterPage {
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State nickname: string = ''
  @State email: string = ''
  @State isLoading: boolean = false
  @State loadingText: string = '创建账号中...'
  @StorageProp('topRectHeight') topRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  /**
   * 执行注册
   */
  async register(): Promise<void> {
    if (!this.username) {
      toast('请输入用户名');
      return;
    }
    if (this.username.length < 4) {
      toast('用户名至少4个字符');
      return;
    }
    if (!this.password) {
      toast('请输入密码');
      return;
    }
    if (this.password.length < 6) {
      toast('密码至少6个字符');
      return;
    }
    if (!this.confirmPassword) {
      toast('请确认密码');
      return;
    }
    if (this.password !== this.confirmPassword) {
      toast('两次输入的密码不一致');
      return;
    }
    if (!this.nickname) {
      toast('请输入昵称');
      return;
    }

    this.isLoading = true;
    this.loadingText = '创建账号中...';

    try {
      const res: ResponseResult = await AuthApiService.register(
        this.username,
        this.password,
        this.nickname,
        this.email
      );

      if (res.code === 0) {
        // 注册成功，自动登录
        this.loadingText = '登录中...';
        await this.autoLogin();
      } else {
        toast(res.message ?? '注册失败');
        this.isLoading = false;
      }
    } catch (err) {
      console.error('注册失败:', JSON.stringify(err));
      toast('注册失败，请重试');
      this.isLoading = false;
    }
  }

  /**
   * 注册成功后自动登录
   */
  async autoLogin(): Promise<void> {
    try {
      const loginRes: ResponseResult = await AuthApiService.login(this.username, this.password);

      if (loginRes.code === 0 && loginRes.data) {
        const loginData: LoginData = loginRes.data as LoginData;
        const token: string = loginData.token;

        // 保存 token
        StorageUtils.saveValueSync(StorageConst.TOKEN, token);

        // 获取用户信息
        const userInfoRes: ResponseResult = await AuthApiService.getUserInfo();
        if (userInfoRes.code === 0 && userInfoRes.data) {
          const userInfo: UserInfoData = userInfoRes.data as UserInfoData;
          StorageUtils.saveValueSync(StorageConst.USER_INFO, JSON.stringify(userInfo));
        }

        toast('欢迎加入 FitEasy！');

        // 设置登录状态并清空路由栈返回首页
        AppStorage.setOrCreate<boolean>('isLoggedIn', true);
        this.pathStack.clear();
      } else {
        // 自动登录失败，提示用户手动登录
        toast('注册成功，请登录');
        this.pathStack.pop();
      }
    } catch (err) {
      console.error('自动登录失败:', JSON.stringify(err));
      toast('注册成功，请登录');
      this.pathStack.pop();
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 检查表单是否有效
   */
  isFormValid(): boolean {
    return this.username.length >= 4 &&
      this.password.length >= 6 &&
      this.confirmPassword.length > 0 &&
      this.nickname.length > 0 &&
      !this.isLoading;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 主内容
        Scroll() {
          Column() {
            // 顶部留白
            Column()
              .height(80)

            // 欢迎标题区域
            Column({ space: 8 }) {
              Text('创建账号')
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))

              Text('注册即刻开始您的健身之旅')
                .fontSize(15)
                .fontColor($r('app.color.text_hint'))
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 24, right: 24 })

            // 表单区域
            Column({ space: 16 }) {
              // 用户名
              TextInput({ placeholder: '用户名（至少4个字符）', text: this.username })
                .width('100%')
                .height(52)
                .fontSize(16)
                .placeholderFont({ size: 15 })
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(12)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.username = value;
                })

              // 昵称
              TextInput({ placeholder: '昵称', text: this.nickname })
                .width('100%')
                .height(52)
                .fontSize(16)
                .placeholderFont({ size: 15 })
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(12)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.nickname = value;
                })

              // 邮箱（可选）
              TextInput({ placeholder: '邮箱（选填）', text: this.email })
                .width('100%')
                .height(52)
                .fontSize(16)
                .placeholderFont({ size: 15 })
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(12)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.email = value;
                })

              // 密码
              TextInput({ placeholder: '密码（至少6个字符）', text: this.password })
                .width('100%')
                .height(52)
                .fontSize(16)
                .placeholderFont({ size: 15 })
                .type(InputType.Password)
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(12)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.password = value;
                })

              // 确认密码
              TextInput({ placeholder: '确认密码', text: this.confirmPassword })
                .width('100%')
                .height(52)
                .fontSize(16)
                .placeholderFont({ size: 15 })
                .type(InputType.Password)
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(12)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.confirmPassword = value;
                })
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 40 })

            // 注册按钮
            Button(this.isLoading ? this.loadingText : '注册并开始')
              .width('90%')
              .height(52)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor(this.isFormValid() ? $r('app.color.brand_primary') : '#C4D3F7')
              .borderRadius(12)
              .margin({ left: 24, right: 24, top: 32 })
              .enabled(this.isFormValid())
              .onClick(() => {
                this.register();
              })

            // 底部登录提示
            Row({ space: 4 }) {
              Text('已有账号？')
                .fontSize(14)
                .fontColor($r('app.color.text_hint'))

              Text('立即登录')
                .fontSize(14)
                .fontColor($r('app.color.brand_primary'))
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  this.pathStack.pop();
                })
            }
            .margin({ top: 24 })

            // 底部留白
            Column()
              .height(60)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        // 返回按钮（悬浮在顶部）
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(20)
              .fontColor([$r('app.color.text_primary')])
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.card_background'))
          .justifyContent(FlexAlign.Center)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.06)',
            offsetX: 0,
            offsetY: 2
          })
          .onClick(() => {
            this.pathStack.pop();
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ top: this.getUIContext().px2vp(this.topRectHeight) + 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
