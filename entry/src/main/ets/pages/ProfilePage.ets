/**
 * 我的页面 - Profile
 * 用户信息、设置、分享等
 */

import { UserInfoData, StorageConst, StorageUtils, toast, ResponseResult, AuthApiService, RouterManager, NavRoutes } from '@tbs/common';
import { promptAction } from '@kit.ArkUI';

@Component
export struct ProfilePage {
  @State userInfo: UserInfoData | null = null
  @State isLoading: boolean = false
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageLink('userInfoJson') @Watch('onUserInfoChange') userInfoJson: string = ''

  aboutToAppear(): void {
    this.loadUserInfo();
  }

  /**
   * 监听 AppStorage 中用户信息变化
   */
  onUserInfoChange(): void {
    if (this.userInfoJson.length > 0) {
      try {
        this.userInfo = JSON.parse(this.userInfoJson) as UserInfoData;
      } catch (err) {
        console.error('解析用户信息失败:', JSON.stringify(err));
      }
    }
  }

  /**
   * 加载用户信息（优先从API获取，失败则从本地读取）
   */
  async loadUserInfo(): Promise<void> {
    // 先从本地读取
    const userInfoStr: string = StorageUtils.getStringValueSync(StorageConst.USER_INFO, '');
    if (userInfoStr.length > 0) {
      try {
        this.userInfo = JSON.parse(userInfoStr) as UserInfoData;
      } catch (err) {
        console.error('解析用户信息失败:', JSON.stringify(err));
      }
    }

    // 从API获取最新信息
    await this.fetchUserInfoFromApi();
  }

  /**
   * 从API获取用户信息
   */
  async fetchUserInfoFromApi(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;

    try {
      const response: ResponseResult = await AuthApiService.getUserInfo();

      if (response.code === 0 && response.data !== null) {
        // 更新本地存储
        StorageUtils.saveValueSync(StorageConst.USER_INFO, JSON.stringify(response.data));
        // 更新界面
        this.userInfo = response.data as UserInfoData;
      }
    } catch (err) {
      console.error('获取用户信息失败:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 检查是否有身体数据
   */
  hasBodyData(): boolean {
    if (this.userInfo === null) {
      return false;
    }
    return this.userInfo.height > 0 || this.userInfo.weight > 0 || this.userInfo.targetWeight > 0;
  }

  /**
   * 登出
   */
  logout(): void {
    promptAction.showDialog({
      title: '确认登出',
      message: '确定要退出登录吗？',
      buttons: [
        {
          text: '取消',
          color: '#646A73'
        },
        {
          text: '确定',
          color: '#F54A45'
        }
      ]
    }).then((data: promptAction.ShowDialogSuccessResponse) => {
      if (data.index === 1) {
        // 清除登录信息 (后端无需logout接口, 客户端直接清除token即可)
        StorageUtils.deleteValueSync(StorageConst.TOKEN);
        StorageUtils.deleteValueSync(StorageConst.USER_INFO);

        toast('已退出登录');

        // 设置登录状态为 false，触发 HomePage 跳转到登录页
        AppStorage.setOrCreate<boolean>('isLoggedIn', false);
      }
    }).catch(() => {
      console.error('Dialog error');
    });
  }

  build() {
    Column() {
      // 主内容区域
      Scroll() {
        Column({ space: 20 }) {
          // 用户信息卡片
          this.UserInfoCard()

          // 身体数据卡片
          this.BodyDataCard()

          // 功能菜单
          this.SettingsSection()

          // 登出按钮
          Text('退出登录')
            .fontSize(15)
            .fontColor($r('app.color.color_danger'))
            .fontWeight(FontWeight.Medium)
            .padding({ top: 16, bottom: 16 })
            .width('100%')
            .textAlign(TextAlign.Center)
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(16)
            .margin({ left: 20, right: 20 })
            .onClick(() => {
              this.logout();
            })
        }
        .width('100%')
        .padding({ top: 20, bottom: 40 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    // 顶部状态栏避让
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }

  @Builder
  UserInfoCard() {
    Column({ space: 16 }) {
      // 头像和用户名
      Row({ space: 16 }) {
        // 头像
        Stack() {
          Column() {
            if (this.userInfo !== null && this.userInfo.nickname.length > 0) {
              Text(this.userInfo.nickname.substring(0, 1).toUpperCase())
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            } else {
              SymbolGlyph($r('sys.symbol.person_fill'))
                .fontSize(32)
                .fontColor([Color.White])
            }
          }
          .width(72)
          .height(72)
          .linearGradient({
            angle: 135,
            colors: [['#667eea', 0], ['#764ba2', 1]]
          })
          .borderRadius(36)
          .justifyContent(FlexAlign.Center)
        }

        // 用户信息
        Column({ space: 6 }) {
          Text(this.userInfo?.nickname ?? '健身爱好者')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text('@' + (this.userInfo?.username ?? 'user'))
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))

          if (this.userInfo !== null && this.userInfo.fitnessGoal.length > 0) {
            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.flag_fill'))
                .fontSize(12)
                .fontColor([$r('app.color.brand_primary')])
              Text(this.userInfo.fitnessGoal)
                .fontSize(13)
                .fontColor($r('app.color.brand_primary'))
            }
            .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 编辑按钮
        Column() {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(20)
            .fontColor([$r('app.color.text_hint')])
        }
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(20)
    .margin({ left: 20, right: 20 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
    .onClick(() => {
      RouterManager.pushPath(NavRoutes.PROFILE_EDIT);
    })
  }

  /**
   * 获取主题显示文本
   */
  getThemeDisplay(): string {
    const theme: string = StorageUtils.getStringValueSync('app_theme', 'auto');
    if (theme === 'dark') {
      return '深色模式';
    }
    return '浅色模式';
  }

  /**
   * 获取提醒显示文本
   */
  getReminderDisplay(): string {
    const enabledStr: string = StorageUtils.getStringValueSync('reminder_enabled', 'false');
    const enabled: boolean = enabledStr === 'true';
    if (enabled) {
      const time: string = StorageUtils.getStringValueSync('reminder_time', '18:00');
      return '已设置 ' + time;
    }
    return '未设置';
  }

  @Builder
  BodyDataCard() {
    Column({ space: 16 }) {
      // 标题行
      Row() {
        Text('身体数据')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        if (this.hasBodyData()) {
          Text('编辑')
            .fontSize(14)
            .fontColor($r('app.color.brand_primary'))
            .onClick(() => {
              RouterManager.pushPath(NavRoutes.PROFILE_EDIT);
            })
        }
      }
      .width('100%')

      if (this.hasBodyData()) {
        // 有数据时显示数据卡片
        Row({ space: 12 }) {
          // 身高
          this.DataItem(
            this.userInfo !== null && this.userInfo.height > 0 ? this.userInfo.height.toString() : '--',
            '身高',
            'cm',
            '#667eea'
          )

          // 体重
          this.DataItem(
            this.userInfo !== null && this.userInfo.weight > 0 ? this.userInfo.weight.toString() : '--',
            '体重',
            'kg',
            '#34C759'
          )

          // 目标体重
          this.DataItem(
            this.userInfo !== null && this.userInfo.targetWeight > 0 ? this.userInfo.targetWeight.toString() : '--',
            '目标',
            'kg',
            '#FF9500'
          )
        }
        .width('100%')
      } else {
        // 没有数据时显示空状态
        Column({ space: 12 }) {
          SymbolGlyph($r('sys.symbol.ruler'))
            .fontSize(40)
            .fontColor([$r('app.color.text_placeholder')])

          Text('暂无身体数据')
            .fontSize(15)
            .fontColor($r('app.color.text_hint'))

          Text('添加身高体重，记录健身变化')
            .fontSize(13)
            .fontColor($r('app.color.text_placeholder'))

          Button('去完善')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.brand_primary'))
            .backgroundColor($r('app.color.brand_primary_light'))
            .borderRadius(20)
            .height(36)
            .padding({ left: 24, right: 24 })
            .margin({ top: 4 })
            .onClick(() => {
              RouterManager.pushPath(NavRoutes.PROFILE_EDIT);
            })
        }
        .width('100%')
        .padding({ top: 20, bottom: 20 })
      }
    }
    .width('100%')
    .padding(20)
    .margin({ left: 20, right: 20 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DataItem(value: string, label: string, unit: string, color: string) {
    Column({ space: 8 }) {
      Row({ space: 2 }) {
        Text(value)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)

        if (value !== '--') {
          Text(unit)
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
            .margin({ top: 10 })
        }
      }
      .alignItems(VerticalAlign.Bottom)

      Text(label)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor($r('app.color.card_background_secondary'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SettingsSection() {
    Column({ space: 0 }) {
      this.SettingItem('主题设置', () => {
        RouterManager.pushPath(NavRoutes.THEME_SETTINGS);
      }, this.getThemeDisplay())

      this.SettingDivider()

      this.SettingItem('反馈中心', () => {
        RouterManager.pushPath(NavRoutes.FEEDBACK);
      }, '')

      this.SettingDivider()

      this.SettingItem('关于我们', () => {
        RouterManager.pushPath(NavRoutes.ABOUT);
      }, 'v1.0.0')
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
    .margin({ left: 20, right: 20 })
  }

  @Builder
  SettingItem(title: string, onClick: () => void, subtitle: string = '') {
    Row({ space: 14 }) {
      // 标题
      Text(title)
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)

      // 副标题
      if (subtitle.length > 0) {
        Text(subtitle)
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
          .margin({ right: 4 })
      }

      // 箭头
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([$r('app.color.text_placeholder')])
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .onClick(onClick)
  }

  @Builder
  SettingDivider() {
    Divider()
      .strokeWidth(0.5)
      .color($r('app.color.outline'))
      .margin({ left: 16, right: 16 })
  }
}
