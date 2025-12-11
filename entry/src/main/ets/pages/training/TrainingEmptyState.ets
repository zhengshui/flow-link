/**
 * 训练空状态组件
 * 当没有添加训练动作时显示
 */

@Component
export struct TrainingEmptyState {
  build() {
    Column({ space: 20 }) {
      Column() {
        SymbolGlyph($r('sys.symbol.dumbbell'))
          .fontSize(48)
          .fontColor([$r('app.color.brand_primary')])
      }
      .width(100)
      .height(100)
      .backgroundColor($r('app.color.card_background_secondary'))
      .borderRadius(50)
      .justifyContent(FlexAlign.Center)

      Column({ space: 8 }) {
        Text('准备开始训练')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('点击下方「添加动作」开始记录')
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .margin({ top: 60 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

