/**
 * 我的页面 - Profile
 * 用户信息、设置、分享等
 */

import { UserInfoData, StorageConst, StorageUtils, toast } from '@tbs/common';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Component
export struct ProfilePage {
  @State userInfo: UserInfoData | null = null

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
      } catch (err) {
        console.error('解析用户信息失败:', JSON.stringify(err));
      }
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
          color: '#666666'
        },
        {
          text: '确定',
          color: '#FF0000'
        }
      ]
    }).then((data: promptAction.ShowDialogSuccessResponse) => {
      if (data.index === 1) {
        // 清除登录信息 (后端无需logout接口, 客户端直接清除token即可)
        StorageUtils.deleteValueSync(StorageConst.TOKEN);
        StorageUtils.deleteValueSync(StorageConst.USER_INFO);

        toast('已退出登录');

        // 跳转到登录页
        router.replaceUrl({
          url: 'pages/LoginPage'
        }).catch((err: Error) => {
          console.error('跳转失败:', JSON.stringify(err));
        });
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
              toast('个人资料编辑功能开发中...');
            })
            this.MenuDivider()
            this.MenuItem('主题设置', '浅色模式', () => {
              toast('主题设置功能开发中...');
            })
            this.MenuDivider()
            this.MenuItem('训练提醒', '未设置', () => {
              toast('训练提醒功能开发中...');
            })
            this.MenuDivider()
            this.MenuItem('数据导出', 'CSV/PDF', () => {
              toast('数据导出功能开发中...');
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // AI助手预留入口
          Column({ space: 0 }) {
            this.MenuItem('AI 训练助手', '敬请期待', () => {
              toast('AI训练助手即将上线');
            }, true)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 关于
          Column({ space: 0 }) {
            this.MenuItem('关于 FitEasy', 'v1.0.0', () => {
              toast('FitEasy v1.0.0 - 让健身更简单');
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 登出按钮
          Button('退出登录')
            .width('90%')
            .height(48)
            .fontSize(16)
            .backgroundColor('#FF3B30')
            .fontColor(Color.White)
            .borderRadius(8)
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
    .backgroundColor('#F5F5F5')
  }

  @Builder
  UserInfoCard() {
    Row({ space: 16 }) {
      // 头像
      Column() {
        Text(this.userInfo?.nickname?.substring(0, 1) ?? '👤')
          .fontSize(28)
          .fontColor(Color.White)
      }
      .width(64)
      .height(64)
      .backgroundColor('#007AFF')
      .borderRadius(32)
      .justifyContent(FlexAlign.Center)

      // 用户信息
      Column({ space: 6 }) {
        Text(this.userInfo?.nickname ?? '健身爱好者')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Text('@' + (this.userInfo?.username ?? 'user'))
          .fontSize(14)
          .fontColor('#666666')

        if (this.userInfo !== null && this.userInfo.fitnessGoal.length > 0) {
          Text('目标: ' + this.userInfo.fitnessGoal)
            .fontSize(12)
            .fontColor('#007AFF')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#E3F2FF')
            .borderRadius(4)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 编辑按钮
      Text('›')
        .fontSize(24)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      toast('编辑个人资料功能开发中...');
    })
  }

  @Builder
  BodyDataCard() {
    Column({ space: 12 }) {
      Text('身体数据')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')

      Row({ space: 12 }) {
        // 身高
        if (this.userInfo !== null && this.userInfo.height > 0) {
          Column({ space: 4 }) {
            Text(this.userInfo.height.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#007AFF')
            Text('身高(cm)')
              .fontSize(11)
              .fontColor('#666666')
          }
          .layoutWeight(1)
          .padding(12)
          .backgroundColor('#F9F9F9')
          .borderRadius(8)
        }

        // 体重
        if (this.userInfo !== null && this.userInfo.weight > 0) {
          Column({ space: 4 }) {
            Text(this.userInfo.weight.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#34C759')
            Text('体重(kg)')
              .fontSize(11)
              .fontColor('#666666')
          }
          .layoutWeight(1)
          .padding(12)
          .backgroundColor('#F9F9F9')
          .borderRadius(8)
        }

        // 目标体重
        if (this.userInfo !== null && this.userInfo.targetWeight > 0) {
          Column({ space: 4 }) {
            Text(this.userInfo.targetWeight.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9500')
            Text('目标体重(kg)')
              .fontSize(11)
              .fontColor('#666666')
          }
          .layoutWeight(1)
          .padding(12)
          .backgroundColor('#F9F9F9')
          .borderRadius(8)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  MenuItem(title: string, subtitle: string, onClick: () => void, isComingSoon: boolean = false) {
    Row() {
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(title)
            .fontSize(16)
            .fontColor('#333333')

          if (isComingSoon) {
            Text('即将上线')
              .fontSize(12)
              .fontColor('#007AFF')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor('#E3F2FF')
              .borderRadius(4)
          }
        }

        Text(subtitle)
          .fontSize(14)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('›')
        .fontSize(20)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .onClick(onClick)
  }

  @Builder
  MenuDivider() {
    Divider()
      .strokeWidth(0.5)
      .color('#E0E0E0')
      .margin({ left: 16, right: 16 })
  }
}
