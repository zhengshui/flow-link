/**
 * 组类型选择弹窗组件
 * 支持选择热身、正式、放松三种组类型
 */

import { SetTypeConst } from '@tbs/common';

@Component
export struct SetTypeSelectDialog {
  @Prop currentSetType: string = SetTypeConst.WORKING
  onSelect: (setType: string) => void = (): void => {}
  onCancel: () => void = (): void => {}

  build() {
    Column() {
      Column({ space: 0 }) {
        Text('选择组类型')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 20, bottom: 16 })

        Column({ space: 0 }) {
          // 热身选项
          this.SetTypeOption('热身', '🔥', SetTypeConst.WARMUP, $r('app.color.set_warmup'), '低强度，准备肌肉')

          Divider().color($r('app.color.divider')).margin({ left: 20, right: 20 })

          // 正式选项
          this.SetTypeOption('正式', '💪', SetTypeConst.WORKING, $r('app.color.set_working'), '主要训练组')

          Divider().color($r('app.color.divider')).margin({ left: 20, right: 20 })

          // 放松选项
          this.SetTypeOption('放松', '🧘', SetTypeConst.COOLDOWN, $r('app.color.set_cooldown'), '低强度，恢复肌肉')
        }
        .width('100%')

        // 取消按钮
        Button('取消')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: 16, bottomRight: 16 })
          .margin({ top: 8 })
          .onClick((): void => {
            this.onCancel();
          })
      }
      .width('85%')
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.overlay_background'))
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      this.onCancel();
    })
  }

  @Builder
  SetTypeOption(title: string, icon: string, setType: string, checkColor: Resource, description: string): void {
    Row() {
      Row({ space: 12 }) {
        Text(icon)
          .fontSize(20)

        Column({ space: 2 }) {
          Text(title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text(description)
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
        }
        .alignItems(HorizontalAlign.Start)
      }

      if (this.currentSetType === setType) {
        Text('✓')
          .fontSize(18)
          .fontColor(checkColor)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.card_background'))
    .onClick((): void => {
      this.onSelect(setType);
    })
  }
}
