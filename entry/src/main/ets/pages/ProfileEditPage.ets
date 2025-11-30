/**
 * 个人资料编辑页面
 * 编辑用户的个人信息、身体数据等
 */

import { UserInfoData, StorageConst, StorageUtils, toast, requestApiCall, ResponseResult, TbsTitleBar } from '@tbs/common';
import { router } from '@kit.ArkUI';
import http from '@ohos.net.http';

@Entry
@Component
struct ProfileEditPage {
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
          StorageUtils.saveValueSync(StorageConst.USER_INFO, JSON.stringify(infoResponse.data));
          toast('保存成功');

          // 延迟返回，让用户看到成功提示
          setTimeout((): void => {
            router.back();
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
    Column() {
      // 状态栏占位
      Row()
        .width('100%')
        .height(this.getUIContext().px2vp(this.topRectHeight))
        .backgroundColor(Color.White)

      // 标题栏
      TbsTitleBar({
        title: '编辑个人资料',
        showBackIcon: true
      })

      // 表单内容
      Scroll() {
        Column({ space: 0 }) {
          // 基本信息
          this.SectionTitle('基本信息')
          this.InputItem('昵称', this.nickname, (value: string): void => {
            this.nickname = value;
          }, '请输入昵称')
          this.Divider()
          this.InputItem('邮箱', this.email, (value: string): void => {
            this.email = value;
          }, '请输入邮箱')
          this.Divider()
          this.InputItem('手机号', this.phone, (value: string): void => {
            this.phone = value;
          }, '请输入手机号')

          // 个人信息
          this.SectionTitle('个人信息')
          this.SelectItem('性别', this.gender, this.genderOptions, (value: string): void => {
            this.gender = value;
          })
          this.Divider()
          this.InputItem('年龄', this.age, (value: string): void => {
            this.age = value;
          }, '请输入年龄', true)

          // 身体数据
          this.SectionTitle('身体数据')
          this.InputItem('身高 (cm)', this.heightValue, (value: string): void => {
            this.heightValue = value;
          }, '请输入身高', true)
          this.Divider()
          this.InputItem('体重 (kg)', this.weightValue, (value: string): void => {
            this.weightValue = value;
          }, '请输入体重', true)
          this.Divider()
          this.InputItem('目标体重 (kg)', this.targetWeightValue, (value: string): void => {
            this.targetWeightValue = value;
          }, '请输入目标体重', true)

          // 健身目标
          this.SectionTitle('健身目标')
          this.SelectItem('健身目标', this.fitnessGoal, this.fitnessGoalOptions, (value: string): void => {
            this.fitnessGoal = value;
          })

          // 保存按钮
          Button(this.isLoading ? '保存中...' : '保存')
            .width('90%')
            .height(48)
            .fontSize(16)
            .backgroundColor(this.isLoading ? '#CCCCCC' : '#007AFF')
            .fontColor(Color.White)
            .borderRadius(8)
            .margin({ top: 32, bottom: 40 })
            .enabled(!this.isLoading)
            .onClick((): void => {
              this.saveUserInfo();
            })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor('#999999')
      .width('100%')
      .padding({ left: 16, top: 16, bottom: 8 })
  }

  @Builder
  InputItem(label: string, value: string, onChange: (value: string) => void, placeholder: string, isNumber: boolean = false) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#333333')
        .width(100)

      TextInput({ text: value, placeholder: placeholder })
        .layoutWeight(1)
        .fontSize(16)
        .fontColor('#333333')
        .backgroundColor(Color.Transparent)
        .type(isNumber ? InputType.Number : InputType.Normal)
        .onChange((value: string): void => {
          onChange(value);
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  SelectItem(label: string, value: string, options: string[], onChange: (value: string) => void) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#333333')
        .width(100)

      Row({ space: 8 }) {
        ForEach(options, (option: string) => {
          Text(option)
            .fontSize(14)
            .fontColor(value === option ? Color.White : '#666666')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(value === option ? '#007AFF' : '#F0F0F0')
            .borderRadius(6)
            .onClick((): void => {
              onChange(option);
            })
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  Divider() {
    Divider()
      .strokeWidth(0.5)
      .color('#E0E0E0')
      .margin({ left: 16, right: 16 })
  }
}
