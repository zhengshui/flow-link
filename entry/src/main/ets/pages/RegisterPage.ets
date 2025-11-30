/**
 * 注册页面 - Register
 * 新用户注册
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { AuthApiService, toast } from '@tbs/common';
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

    try {
      const res: ResponseResult = await AuthApiService.register(
        this.username,
        this.password,
        this.nickname,
        this.email
      );

      if (res.code === 0) {
        toast('注册成功，请登录');
        // 返回登录页
        this.pathStack.pop();
      } else {
        toast(res.message ?? '注册失败');
      }
    } catch (err) {
      console.error('注册失败:', JSON.stringify(err));
      toast('注册失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 20 }) {
          // Logo
          Column() {
            Text('💪')
              .fontSize(60)
          }
          .margin({ top: 40 })

          // 表单区域
          Column({ space: 16 }) {
            // 用户名
            Column({ space: 8 }) {
              Text('用户名')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')

              TextInput({ placeholder: '请输入用户名（至少4个字符）' })
                .width('100%')
                .height(48)
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(8)
                .onChange((value: string) => {
                  this.username = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 密码
            Column({ space: 8 }) {
              Text('密码')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')

              TextInput({ placeholder: '请输入密码（至少6个字符）' })
                .width('100%')
                .height(48)
                .type(InputType.Password)
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(8)
                .onChange((value: string) => {
                  this.password = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 确认密码
            Column({ space: 8 }) {
              Text('确认密码')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')

              TextInput({ placeholder: '请再次输入密码' })
                .width('100%')
                .height(48)
                .type(InputType.Password)
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(8)
                .onChange((value: string) => {
                  this.confirmPassword = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 昵称
            Column({ space: 8 }) {
              Text('昵称')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')

              TextInput({ placeholder: '请输入昵称' })
                .width('100%')
                .height(48)
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(8)
                .onChange((value: string) => {
                  this.nickname = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 邮箱（可选）
            Column({ space: 8 }) {
              Text('邮箱（可选）')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')

              TextInput({ placeholder: '请输入邮箱' })
                .width('100%')
                .height(48)
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(8)
                .onChange((value: string) => {
                  this.email = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 注册按钮
            Button(this.isLoading ? '注册中...' : '立即注册')
              .width('100%')
              .height(48)
              .fontSize(16)
              .backgroundColor($r('app.color.brand_primary'))
              .borderRadius(8)
              .margin({ top: 20 })
              .opacity((this.username.length > 0 && this.password.length > 0 &&
                this.confirmPassword.length > 0 && this.nickname.length > 0 && !this.isLoading) ? 1 : 0.5)
              .enabled(this.username.length > 0 && this.password.length > 0 &&
                this.confirmPassword.length > 0 && this.nickname.length > 0 && !this.isLoading)
              .onClick(() => {
                this.register();
              })
          }
          .width('90%')
          .padding(20)
          .margin({ top: 20 })

          // 底部提示
          Row({ space: 4 }) {
            Text('已有账号？')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))

            Text('立即登录')
              .fontSize(14)
              .fontColor($r('app.color.brand_primary'))
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.pathStack.pop();
              })
          }
          .margin({ bottom: 40 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.page_background'))
    }
    .title('注册')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
