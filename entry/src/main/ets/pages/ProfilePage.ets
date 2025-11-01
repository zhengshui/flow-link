/**
 * 我的页面 - Profile
 * 用户信息、设置、分享等
 */

@Component
export struct ProfilePage {
  build() {
    Column() {
      // 主内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 用户信息卡片
          this.UserInfoCard()

          // 功能菜单
          Column({ space: 0 }) {
            this.MenuItem('主题设置', '浅色模式', () => {
              console.info('点击主题设置')
            })
            this.MenuDivider()
            this.MenuItem('训练提醒', '未设置', () => {
              console.info('点击训练提醒')
            })
            this.MenuDivider()
            this.MenuItem('数据导出', 'CSV/PDF', () => {
              console.info('点击数据导出')
            })
          }
          .width('90%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // AI助手预留入口
          Column({ space: 0 }) {
            this.MenuItem('AI 训练助手', '敬请期待', () => {
              console.info('点击AI助手')
            }, true)
          }
          .width('90%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 关于
          Column({ space: 0 }) {
            this.MenuItem('关于 FitEasy', 'v1.0.0', () => {
              console.info('点击关于')
            })
          }
          .width('90%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 16, right: 16, bottom: 16 })
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
        Text('👤')
          .fontSize(32)
      }
      .width(64)
      .height(64)
      .backgroundColor('#E0E0E0')
      .borderRadius(32)
      .justifyContent(FlexAlign.Center)

      // 用户信息
      Column({ space: 6 }) {
        Text('健身爱好者')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)

        Text('开始记录你的健身之旅')
          .fontSize(14)
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('90%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(VerticalAlign.Center)
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
