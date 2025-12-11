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

  aboutToAppear(): void {
    this.loadUserInfo();
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

      if (response.code === 200 && response.data !== null) {
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
        Column({ space: 16 }) {
          // 用户信息卡片
          this.UserInfoCard()

          // 身体数据卡片
          if (this.userInfo !== null) {
            this.BodyDataCard()
          }

          // 功能菜单
          Column({ space: 0 }) {
            this.MenuItem('个人资料', '编辑个人信息', () => {
              RouterManager.pushPath(NavRoutes.PROFILE_EDIT);
            })
            this.MenuDivider()
            this.MenuItem('主题设置', this.getThemeDisplay(), () => {
              RouterManager.pushPath(NavRoutes.THEME_SETTINGS);
            })
            this.MenuDivider()
            this.MenuItem('训练提醒', this.getReminderDisplay(), () => {
              RouterManager.pushPath(NavRoutes.REMINDER_SETTINGS);
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 关于
          Column({ space: 0 }) {
            this.MenuItem('关于 FitEasy', 'v1.0.0', () => {
              RouterManager.pushPath(NavRoutes.ABOUT);
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 登出按钮
          Button('退出登录')
            .width('90%')
            .height(46)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.color_danger'))
            .fontColor(Color.White)
            .borderRadius(10)
            .margin({ left: 16, right: 16, top: 8, bottom: 40 })
            .onClick(() => {
              this.logout();
            })
        }
        .width('100%')
        .padding({ top: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    // 顶部状态栏避让
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }

  @Builder
  UserInfoCard() {
    Row({ space: 16 }) {
      // 头像
      Column() {
        if (this.userInfo !== null && this.userInfo.nickname.length > 0) {
          Text(this.userInfo.nickname.substring(0, 1))
            .fontSize(28)
            .fontColor(Color.White)
        } else {
          SymbolGlyph($r('sys.symbol.person_fill'))
            .fontSize(28)
            .fontColor([Color.White])
        }
      }
      .width(64)
      .height(64)
      .backgroundColor($r('app.color.brand_primary'))
      .borderRadius(32)
      .justifyContent(FlexAlign.Center)

      // 用户信息
      Column({ space: 6 }) {
        Text(this.userInfo?.nickname ?? '健身爱好者')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text('@' + (this.userInfo?.username ?? 'user'))
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))

        if (this.userInfo !== null && this.userInfo.fitnessGoal.length > 0) {
          Text('目标: ' + this.userInfo.fitnessGoal)
            .fontSize(12)
            .fontColor($r('app.color.brand_primary'))
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor($r('app.color.brand_primary_light'))
            .borderRadius(4)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 编辑按钮
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(18)
        .fontColor([$r('app.color.text_placeholder')])
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(VerticalAlign.Center)
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
    } else if (theme === 'auto') {
      return '跟随系统';
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
    Column({ space: 12 }) {
      Text('身体数据')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Row({ space: 12 }) {
        // 身高
        if (this.userInfo !== null && this.userInfo.height > 0) {
          Column({ space: 4 }) {
            Text(this.userInfo.height.toString())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_primary'))
            Text('身高(cm)')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
          }
          .layoutWeight(1)
          .padding(12)
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(8)
          .alignItems(HorizontalAlign.Center)
        }

        // 体重
        if (this.userInfo !== null && this.userInfo.weight > 0) {
          Column({ space: 4 }) {
            Text(this.userInfo.weight.toString())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.color_success'))
            Text('体重(kg)')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
          }
          .layoutWeight(1)
          .padding(12)
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(8)
          .alignItems(HorizontalAlign.Center)
        }

        // 目标体重
        if (this.userInfo !== null && this.userInfo.targetWeight > 0) {
          Column({ space: 4 }) {
            Text(this.userInfo.targetWeight.toString())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.color_warning'))
            Text('目标(kg)')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
          }
          .layoutWeight(1)
          .padding(12)
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(8)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  MenuItem(title: string, subtitle: string, onClick: () => void, isComingSoon: boolean = false) {
    Row() {
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(title)
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))

          if (isComingSoon) {
            Text('即将上线')
              .fontSize(11)
              .fontColor($r('app.color.brand_primary'))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor($r('app.color.brand_primary_light'))
              .borderRadius(4)
          }
        }

        Text(subtitle)
          .fontSize(13)
          .fontColor($r('app.color.text_hint'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([$r('app.color.text_placeholder')])
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(onClick)
  }

  @Builder
  MenuDivider() {
    Divider()
      .strokeWidth(0.5)
      .color($r('app.color.outline'))
      .margin({ left: 16, right: 16 })
  }
}
