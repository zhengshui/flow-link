/**
 * 个人资料编辑页面
 * 编辑用户的个人信息、身体数据等
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { UserInfoData, StorageConst, StorageUtils, toast, requestApiCall, ResponseResult } from '@tbs/common';
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
  @StorageProp('topRectHeight') topRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  private genderOptions: string[] = ['男', '女']
  private fitnessGoalOptions: string[] = ['增肌', '减脂', '力量提升', '耐力提升', '综合健身']

  aboutToAppear(): void {
    this.loadUserInfo();
  }

  /**
   * 加载用户信息
   */
  loadUserInfo(): void {
    const userInfoStr: string = StorageUtils.getStringValueSync(StorageConst.USER_INFO, '');
    if (userInfoStr.length > 0) {
      try {
        this.userInfo = JSON.parse(userInfoStr) as UserInfoData;
        this.nickname = this.userInfo.nickname;
        this.email = this.userInfo.email.length > 0 ? this.userInfo.email : '';
        this.phone = this.userInfo.phone.length > 0 ? this.userInfo.phone : '';
        this.gender = this.userInfo.gender.length > 0 ? this.userInfo.gender : '男';
        this.age = this.userInfo.age > 0 ? this.userInfo.age.toString() : '';
        this.heightValue = this.userInfo.height > 0 ? this.userInfo.height.toString() : '';
        this.weightValue = this.userInfo.weight > 0 ? this.userInfo.weight.toString() : '';
        this.targetWeightValue = this.userInfo.targetWeight > 0 ? this.userInfo.targetWeight.toString() : '';
        this.fitnessGoal = this.userInfo.fitnessGoal.length > 0 ? this.userInfo.fitnessGoal : '增肌';
      } catch (err) {
        console.error('解析用户信息失败:', JSON.stringify(err));
      }
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
      const updateData: ESObject = {
        nickname: this.nickname.trim()
      };

      if (this.email.trim().length > 0) {
        updateData['email'] = this.email.trim();
      }
      if (this.phone.trim().length > 0) {
        updateData['phone'] = this.phone.trim();
      }
      updateData['gender'] = this.gender;

      const ageNum: number = parseInt(this.age);
      if (!isNaN(ageNum) && ageNum > 0) {
        updateData['age'] = ageNum;
      }

      const heightNum: number = parseInt(this.heightValue);
      if (!isNaN(heightNum) && heightNum > 0) {
        updateData['height'] = heightNum;
      }

      const weightNum: number = parseFloat(this.weightValue);
      if (!isNaN(weightNum) && weightNum > 0) {
        updateData['weight'] = weightNum;
      }

      const targetWeightNum: number = parseFloat(this.targetWeightValue);
      if (!isNaN(targetWeightNum) && targetWeightNum > 0) {
        updateData['targetWeight'] = targetWeightNum;
      }

      updateData['fitnessGoal'] = this.fitnessGoal;

      // 调用更新API
      const response: ResponseResult = await requestApiCall(
        '/user/info',
        http.RequestMethod.PUT,
        updateData as Record<string, number | boolean | string | Object | undefined>
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

        // 表单内容
        Scroll() {
          Column({ space: 0 }) {
            // 基本信息
            this.SectionTitle('基本信息')
          this.InputItem('昵称', this.nickname, (value: string): void => {
            this.nickname = value;
          }, '请输入昵称')
          this.ItemDivider()
          this.InputItem('邮箱', this.email, (value: string): void => {
            this.email = value;
          }, '请输入邮箱')
          this.ItemDivider()
          this.InputItem('手机号', this.phone, (value: string): void => {
            this.phone = value;
          }, '请输入手机号')

          // 个人信息
          this.SectionTitle('个人信息')
          this.GenderSelector()
          this.ItemDivider()
          this.InputItem('年龄', this.age, (value: string): void => {
            this.age = value;
          }, '请输入年龄', true)

          // 身体数据
          this.SectionTitle('身体数据')
          this.InputItem('身高 (cm)', this.heightValue, (value: string): void => {
            this.heightValue = value;
          }, '请输入身高', true)
          this.ItemDivider()
          this.InputItem('体重 (kg)', this.weightValue, (value: string): void => {
            this.weightValue = value;
          }, '请输入体重', true)
          this.ItemDivider()
          this.InputItem('目标体重 (kg)', this.targetWeightValue, (value: string): void => {
            this.targetWeightValue = value;
          }, '请输入目标体重', true)

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
  InputItem(label: string, value: string, onChange: (value: string) => void, placeholder: string, isNumber: boolean = false) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .width(100)

      TextInput({ text: value, placeholder: placeholder })
        .layoutWeight(1)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor(Color.Transparent)
        .type(isNumber ? InputType.Number : InputType.Normal)
        .onChange((value: string): void => {
          onChange(value);
        })
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.card_background'))
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
