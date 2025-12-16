/**
 * 个人资料编辑页面
 * 编辑用户的个人信息、身体数据等
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { UserInfoData, StorageConst, StorageUtils, toast, requestApiCall, ResponseResult, AuthApiService } from '@tbs/common';
import http from '@ohos.net.http';

/**
 * 系统路由表构建函数
 */
@Builder
export function ProfileEditPageBuilder(): void {
  ProfileEditPage()
}

@Component
export struct ProfileEditPage {
  @State userInfo: UserInfoData | null = null
  @State nickname: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State gender: string = '男'
  @State age: string = ''
  @State heightValue: string = ''
  @State weightValue: string = ''
  @State targetWeightValue: string = ''
  @State fitnessGoal: string = '增肌'
  @State isLoading: boolean = false
  @State isDataLoaded: boolean = false
  @StorageProp('topRectHeight') topRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  private genderOptions: string[] = ['男', '女']
  private fitnessGoalOptions: string[] = ['增肌', '减脂', '力量提升', '耐力提升', '综合健身']

  aboutToAppear(): void {
    this.loadUserInfo();
  }

  /**
   * 从服务器加载用户信息
   * 确保多设备登录时数据一致性
   */
  async loadUserInfo(): Promise<void> {
    this.isDataLoaded = false;
    this.userInfo = null;

    try {
      const response: ResponseResult = await AuthApiService.getUserInfo();

      if (response.code === 0 && response.data !== null) {
        this.userInfo = response.data as UserInfoData;
        this.nickname = this.userInfo.nickname;
        this.email = this.userInfo.email.length > 0 ? this.userInfo.email : '';
        this.phone = this.userInfo.phone.length > 0 ? this.userInfo.phone : '';
        this.gender = this.userInfo.gender.length > 0 ? this.userInfo.gender : '男';
        this.age = this.userInfo.age > 0 ? this.userInfo.age.toString() : '';
        this.heightValue = this.userInfo.height > 0 ? this.userInfo.height.toString() : '';
        this.weightValue = this.userInfo.weight > 0 ? this.userInfo.weight.toString() : '';
        this.targetWeightValue = this.userInfo.targetWeight > 0 ? this.userInfo.targetWeight.toString() : '';
        this.fitnessGoal = this.userInfo.fitnessGoal.length > 0 ? this.userInfo.fitnessGoal : '增肌';

        // 同步更新本地存储
        const userInfoJson: string = JSON.stringify(response.data);
        StorageUtils.saveValueSync(StorageConst.USER_INFO, userInfoJson);
      } else {
        const msg: string = response.message !== undefined && response.message.length > 0 ? response.message : '获取用户信息失败';
        toast(msg);
      }
    } catch (err) {
      console.error('获取用户信息失败:', JSON.stringify(err));
      toast('获取用户信息失败，请重试');
    } finally {
      this.isDataLoaded = true;
    }
  }

  /**
   * 保存用户信息
   */
  async saveUserInfo(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    // 验证必填字段
    if (this.nickname.trim().length === 0) {
      toast('请输入昵称');
      return;
    }

    this.isLoading = true;

    try {
      // 构建更新数据
      const updateData: Map<string, number | string> = new Map();
      updateData.set('nickname', this.nickname.trim());

      if (this.email.trim().length > 0) {
        updateData.set('email', this.email.trim());
      }
      if (this.phone.trim().length > 0) {
        updateData.set('phone', this.phone.trim());
      }
      updateData.set('gender', this.gender);

      const ageNum: number = parseInt(this.age);
      if (!isNaN(ageNum) && ageNum > 0) {
        updateData.set('age', ageNum);
      }

      const heightNum: number = parseInt(this.heightValue);
      if (!isNaN(heightNum) && heightNum > 0) {
        updateData.set('height', heightNum);
      }

      const weightNum: number = parseFloat(this.weightValue);
      if (!isNaN(weightNum) && weightNum > 0) {
        updateData.set('weight', weightNum);
      }

      const targetWeightNum: number = parseFloat(this.targetWeightValue);
      if (!isNaN(targetWeightNum) && targetWeightNum > 0) {
        updateData.set('targetWeight', targetWeightNum);
      }

      updateData.set('fitnessGoal', this.fitnessGoal);

      // 转换为 Record 对象
      const requestBody: Record<string, number | boolean | string | Object | undefined> = {};
      updateData.forEach((value: number | string, key: string) => {
        requestBody[key] = value;
      });

      // 调用更新API
      const response: ResponseResult = await requestApiCall(
        '/user/info',
        http.RequestMethod.PUT,
        requestBody
      );

      if (response.code === 200) {
        // 更新成功，重新获取用户信息
        const infoResponse: ResponseResult = await requestApiCall(
          '/user/info',
          http.RequestMethod.GET,
          undefined
        );

        if (infoResponse.code === 200 && infoResponse.data !== null) {
          // 保存到本地存储
          const userInfoJson: string = JSON.stringify(infoResponse.data);
          StorageUtils.saveValueSync(StorageConst.USER_INFO, userInfoJson);
          // 同步更新 AppStorage，触发 ProfilePage 刷新
          AppStorage.setOrCreate<string>('userInfoJson', userInfoJson);
          toast('保存成功');

          // 延迟返回，让用户看到成功提示
          setTimeout((): void => {
            this.pathStack.pop();
          }, 500);
        }
      } else {
        const msg: string = response.message !== undefined && response.message.length > 0 ? response.message : '保存失败';
        toast(msg);
      }
    } catch (err) {
      console.error('保存用户信息失败:', JSON.stringify(err));
      toast('保存失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 自定义标题栏
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([$r('app.color.text_primary')])
            .onClick(() => {
              this.pathStack.pop();
            })

          Text('编辑个人资料')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          // 占位，保持标题居中
          Column().width(24)
        }
        .width('100%')
        .height(70)
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topRectHeight) })
        .backgroundColor($r('app.color.card_background'))

        // 表单内容 - 等待数据加载完成
        if (this.isDataLoaded) {
          Scroll() {
            Column({ space: 0 }) {
              // 基本信息
              this.SectionTitle('基本信息')

              // 昵称
              Row() {
                Text('昵称')
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .width(100)

                TextInput({ text: $$this.nickname, placeholder: '请输入昵称' })
                  .layoutWeight(1)
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor(Color.Transparent)
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.card_background'))

              this.ItemDivider()

              // 邮箱
              Row() {
                Text('邮箱')
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .width(100)

                TextInput({ text: $$this.email, placeholder: '请输入邮箱' })
                  .layoutWeight(1)
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor(Color.Transparent)
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.card_background'))

              this.ItemDivider()

              // 手机号
              Row() {
                Text('手机号')
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .width(100)

                TextInput({ text: $$this.phone, placeholder: '请输入手机号' })
                  .layoutWeight(1)
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor(Color.Transparent)
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.card_background'))

              // 个人信息
              this.SectionTitle('个人信息')
              this.GenderSelector()
              this.ItemDivider()

              // 年龄
              Row() {
                Text('年龄')
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .width(100)

                TextInput({ text: $$this.age, placeholder: '请输入年龄' })
                  .layoutWeight(1)
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor(Color.Transparent)
                  .type(InputType.Number)
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.card_background'))

              // 身体数据
              this.SectionTitle('身体数据')

              // 身高
              Row() {
                Text('身高 (cm)')
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .width(100)

                TextInput({ text: $$this.heightValue, placeholder: '请输入身高' })
                  .layoutWeight(1)
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor(Color.Transparent)
                  .type(InputType.Number)
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.card_background'))

              this.ItemDivider()

              // 体重
              Row() {
                Text('体重 (kg)')
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .width(100)

                TextInput({ text: $$this.weightValue, placeholder: '请输入体重' })
                  .layoutWeight(1)
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor(Color.Transparent)
                  .type(InputType.Number)
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.card_background'))

              this.ItemDivider()

              // 目标体重
              Row() {
                Text('目标体重 (kg)')
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .width(100)

                TextInput({ text: $$this.targetWeightValue, placeholder: '请输入目标体重' })
                  .layoutWeight(1)
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor(Color.Transparent)
                  .type(InputType.Number)
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.card_background'))

              // 健身目标
              this.SectionTitle('健身目标')
              this.FitnessGoalSelector()

              // 保存按钮
              Button(this.isLoading ? '保存中...' : '保存')
                .width('90%')
                .height(46)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(this.isLoading ? $r('app.color.text_placeholder') : $r('app.color.brand_primary'))
                .fontColor(Color.White)
                .borderRadius(10)
                .margin({ top: 32, bottom: 40 })
                .enabled(!this.isLoading)
                .onClick((): void => {
                  this.saveUserInfo();
                })
            }
            .width('100%')
          }
          .layoutWeight(1)
          .backgroundColor($r('app.color.page_background'))
          .align(Alignment.Top)
        } else {
          // 加载中状态
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('app.color.brand_primary'))
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.page_background'))
        }
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

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(12)
      .fontColor($r('app.color.text_hint'))
      .width('100%')
      .padding({ left: 16, top: 20, bottom: 8 })
  }

  @Builder
  GenderSelector() {
    Row() {
      Text('性别')
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .width(100)
        .flexShrink(0)

      Row({ space: 6 }) {
        ForEach(this.genderOptions, (option: string) => {
          Text(option)
            .fontSize(13)
            .fontColor(this.gender === option ? Color.White : $r('app.color.text_secondary'))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.gender === option ? $r('app.color.brand_primary') : $r('app.color.outline'))
            .borderRadius(6)
            .onClick(() => {
              this.gender = option;
            })
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  FitnessGoalSelector() {
    Row() {
      Text('健身目标')
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .width(100)
        .flexShrink(0)

      Scroll() {
        Row({ space: 6 }) {
          ForEach(this.fitnessGoalOptions, (option: string) => {
            Text(option)
              .fontSize(13)
              .fontColor(this.fitnessGoal === option ? Color.White : $r('app.color.text_secondary'))
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.fitnessGoal === option ? $r('app.color.brand_primary') : $r('app.color.outline'))
              .borderRadius(6)
              .onClick(() => {
                this.fitnessGoal = option;
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  ItemDivider() {
    Divider()
      .strokeWidth(0.5)
      .color($r('app.color.outline'))
      .margin({ left: 16, right: 16 })
  }
}
