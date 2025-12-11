/**
 * 时间编辑对话框组件
 * 允许用户手动编辑训练时间
 */

@Component
export struct TimeEditDialog {
  @Link editHours: string;
  @Link editMinutes: string;
  @Link editSeconds: string;
  onSave: () => void = (): void => {};
  onCancel: () => void = (): void => {};

  build() {
    Column() {
      Column({ space: 0 }) {
        Text('编辑训练时间')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(16)

        Row({ space: 8 }) {
          // 小时输入
          Column({ space: 4 }) {
            TextInput({ text: this.editHours })
              .width(70)
              .height(50)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Center)
              .type(InputType.Number)
              .backgroundColor($r('app.color.card_background_secondary'))
              .borderRadius(8)
              .onChange((value: string): void => {
                this.editHours = value;
              })
            Text('小时')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
          }
          .alignItems(HorizontalAlign.Center)

          Text(':')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          // 分钟输入
          Column({ space: 4 }) {
            TextInput({ text: this.editMinutes })
              .width(70)
              .height(50)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Center)
              .type(InputType.Number)
              .backgroundColor($r('app.color.card_background_secondary'))
              .borderRadius(8)
              .onChange((value: string): void => {
                // 限制分钟在 0-59
                const min: number = parseInt(value) || 0;
                if (min > 59) {
                  this.editMinutes = '59';
                } else {
                  this.editMinutes = value;
                }
              })
            Text('分钟')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
          }
          .alignItems(HorizontalAlign.Center)

          Text(':')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          // 秒数输入
          Column({ space: 4 }) {
            TextInput({ text: this.editSeconds })
              .width(70)
              .height(50)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Center)
              .type(InputType.Number)
              .backgroundColor($r('app.color.card_background_secondary'))
              .borderRadius(8)
              .onChange((value: string): void => {
                // 限制秒数在 0-59
                const sec: number = parseInt(value) || 0;
                if (sec > 59) {
                  this.editSeconds = '59';
                } else {
                  this.editSeconds = value;
                }
              })
            Text('秒')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 8, bottom: 16 })

        Text('点击数字可以直接输入修改')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
          .margin({ bottom: 16 })

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.outline'))
            .fontColor($r('app.color.text_primary'))
            .onClick((): void => { this.onCancel(); })

          Button('确定')
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.brand_primary'))
            .onClick((): void => { this.onSave(); })
        }
        .width('100%')
        .padding(16)
      }
      .width('90%')
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(12)
      .onClick((): void => {
        // 阻止点击内部关闭对话框
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.overlay_background'))
    .justifyContent(FlexAlign.Center)
    .onClick((): void => { this.onCancel(); })
  }
}

