/**
 * 训练底部操作栏组件
 * 提供最小化、添加动作、心得和设置按钮
 */

@Component
export struct TrainingBottomBar {
  @Prop bottomRectHeight: number = 0;
  onMinimize: () => void = (): void => {};
  onAddExercise: () => void = (): void => {};
  onShowNote: () => void = (): void => {};
  onShowSettings: () => void = (): void => {};

  build() {
    Column() {
      Row({ space: 8 }) {
        // 最小化按钮
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_down'))
            .fontSize(18)
            .fontColor([$r('app.color.text_secondary')])
        }
        .width(44)
        .height(44)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(12)
        .onClick((): void => { this.onMinimize(); })

        // 添加动作按钮
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
        .height(44)
        .layoutWeight(1)
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(12)
        .onClick((): void => { this.onAddExercise(); })

        // 心得按钮
        Button() {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(16)
            .fontColor([$r('app.color.text_primary')])
        }
        .width(44)
        .height(44)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(12)
        .onClick((): void => { this.onShowNote(); })

        // 设置按钮
        Button() {
          SymbolGlyph($r('sys.symbol.gearshape'))
            .fontSize(16)
            .fontColor([$r('app.color.text_primary')])
        }
        .width(44)
        .height(44)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(12)
        .onClick((): void => { this.onShowSettings(); })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })

      // 底部导航区域避让
      Row()
        .width('100%')
        .height(this.getUIContext().px2vp(this.bottomRectHeight))
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .shadow({ radius: 6, color: 'rgba(0, 0, 0, 0.06)', offsetX: 0, offsetY: -1 })
  }
}

