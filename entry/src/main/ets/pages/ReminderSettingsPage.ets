/**
 * 训练提醒设置页面
 * 设置训练提醒时间和频率
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { StorageUtils, toast } from '@tbs/common';

/**
 * 系统路由表构建函数
 */
@Builder
export function ReminderSettingsPageBuilder(): void {
  ReminderSettingsPage()
}

@Component
export struct ReminderSettingsPage {
  @State reminderEnabled: boolean = false
  @State reminderTime: string = '18:00'
  @State reminderDays: boolean[] = [false, false, false, false, false, false, false] // 周日到周六
  @StorageProp('topRectHeight') topRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()
  private weekDays: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

  aboutToAppear(): void {
    this.loadReminderSettings();
  }

  /**
   * 加载提醒设置
   */
  loadReminderSettings(): void {
    const enabledStr: string = StorageUtils.getStringValueSync('reminder_enabled', 'false');
    this.reminderEnabled = enabledStr === 'true';
    this.reminderTime = StorageUtils.getStringValueSync('reminder_time', '18:00');

    const daysStr: string = StorageUtils.getStringValueSync('reminder_days', '');
    if (daysStr.length > 0) {
      try {
        const days: boolean[] = JSON.parse(daysStr) as boolean[];
        this.reminderDays = days;
      } catch (err) {
        console.error('解析提醒日期失败:', JSON.stringify(err));
      }
    }
  }

  /**
   * 保存提醒设置
   */
  saveReminderSettings(): void {
    StorageUtils.saveValueSync('reminder_enabled', this.reminderEnabled ? 'true' : 'false');
    StorageUtils.saveValueSync('reminder_time', this.reminderTime);
    StorageUtils.saveValueSync('reminder_days', JSON.stringify(this.reminderDays));

    if (this.reminderEnabled) {
      // 检查是否至少选择了一天
      let hasSelectedDay: boolean = false;
      for (let i: number = 0; i < this.reminderDays.length; i++) {
        if (this.reminderDays[i]) {
          hasSelectedDay = true;
          break;
        }
      }

      if (!hasSelectedDay) {
        toast('请至少选择一天');
        return;
      }

      toast('训练提醒已设置');
      // 实际应用中，这里应该注册系统通知
      // 例如：使用NotificationManager注册定时提醒
    } else {
      toast('训练提醒已关闭');
      // 实际应用中，这里应该取消系统通知
    }

    // 延迟返回
    setTimeout((): void => {
      this.pathStack.pop();
    }, 500);
  }

  /**
   * 切换某一天的提醒状态
   */
  toggleDay(index: number): void {
    const newDays: boolean[] = [...this.reminderDays];
    newDays[index] = !newDays[index];
    this.reminderDays = newDays;
  }

  build() {
    NavDestination() {
      // 设置内容
      Scroll() {
        Column({ space: 16 }) {
          // 开关
          Column({ space: 0 }) {
            Row() {
              Text('启用训练提醒')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
                .onChange((isOn: boolean): void => {
                  this.reminderEnabled = isOn;
                })
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ left: 16, right: 16, top: 16 })

          // 提醒时间
          if (this.reminderEnabled) {
            Column({ space: 0 }) {
              Row() {
                Text('提醒时间')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                  .layoutWeight(1)

                Text(this.reminderTime)
                  .fontSize(16)
                  .fontColor($r('app.color.brand_primary'))
                  .onClick((): void => {
                    toast('时间选择器功能开发中...');
                    // 实际应用中，这里应该弹出时间选择器
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(12)
            .margin({ left: 16, right: 16 })

            // 提醒日期
            Column({ space: 0 }) {
              Text('提醒日期')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .padding({ left: 16, top: 12, bottom: 12 })

              Divider()
                .strokeWidth(0.5)
                .color($r('app.color.outline'))
                .margin({ left: 16, right: 16 })

              // 星期选择
              Row({ space: 8 }) {
                ForEach(this.weekDays, (day: string, index: number) => {
                  Column() {
                    Text(day)
                      .fontSize(14)
                      .fontColor(this.reminderDays[index] ? Color.White : $r('app.color.text_secondary'))
                      .fontWeight(this.reminderDays[index] ? FontWeight.Medium : FontWeight.Normal)
                  }
                  .width(40)
                  .height(40)
                  .backgroundColor(this.reminderDays[index] ? $r('app.color.brand_primary') : $r('app.color.outline'))
                  .borderRadius(20)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => {
                    this.toggleDay(index);
                  })
                })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 16 })
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(12)
            .margin({ left: 16, right: 16 })
          }

          // 提示信息
          Text('设置训练提醒可以帮助你养成良好的健身习惯')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
            .width('100%')
            .padding({ left: 24, right: 24, top: 8 })
            .textAlign(TextAlign.Center)

          // 保存按钮
          if (this.reminderEnabled) {
            Button('保存设置')
              .width('90%')
              .height(48)
              .fontSize(16)
              .backgroundColor($r('app.color.brand_primary'))
              .fontColor(Color.White)
              .borderRadius(8)
              .margin({ top: 16, bottom: 40 })
              .onClick((): void => {
                this.saveReminderSettings();
              })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.page_background'))
    }
    .title('训练提醒')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
