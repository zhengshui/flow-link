/**
 * 训练心得对话框组件
 */

@Component
export struct NoteDialog {
  @Link tempNote: string;
  onSave: () => void = (): void => {};
  onCancel: () => void = (): void => {};

  build() {
    Column() {
      Column({ space: 0 }) {
        Text('训练心得')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(16)

        TextArea({ text: this.tempNote })
          .width('100%')
          .height(200)
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.card_background'))
          .onChange((value: string): void => { this.tempNote = value; })

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.outline'))
            .fontColor($r('app.color.text_primary'))
            .onClick((): void => { this.onCancel(); })

          Button('保存')
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.overlay_background'))
    .justifyContent(FlexAlign.Center)
    .onClick((): void => { this.onCancel(); })
  }
}

