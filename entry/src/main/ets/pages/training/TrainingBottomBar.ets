/**
 * 训练底部操作栏组件
 * 提供添加动作和心得按钮
 */

@Component
export struct TrainingBottomBar {
  @Prop bottomRectHeight: number = 0;
  onAddExercise: () => void = (): void => {};
  onShowNote: () => void = (): void => {};

  build() {
    Column() {
      Row({ space: 10 }) {
        Button() {
          Row({ space: 6 }) {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(16)
              .fontColor([Color.White])
            Text('添加动作')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
        }
        .height(48)
        .layoutWeight(1)
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(12)
        .onClick((): void => { this.onAddExercise(); })

        Button() {
          Row({ space: 6 }) {
            SymbolGlyph($r('sys.symbol.square_and_pencil'))
              .fontSize(16)
              .fontColor([$r('app.color.text_primary')])
            Text('心得')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
          }
        }
        .height(48)
        .layoutWeight(0.6)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(12)
        .onClick((): void => { this.onShowNote(); })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 底部导航区域避让
      Row()
        .width('100%')
        .height(this.getUIContext().px2vp(this.bottomRectHeight))
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.08)', offsetX: 0, offsetY: -2 })
  }
}

