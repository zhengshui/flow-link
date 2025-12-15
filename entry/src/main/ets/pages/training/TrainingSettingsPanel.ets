/**
 * 训练设置面板组件
 * 从底部弹出，包含取消训练、保存返回等操作
 */

@Component
export struct TrainingSettingsPanel {
  @Prop bottomRectHeight: number = 0;
  onCancelTraining: () => void = (): void => {};
  onSaveAndExit: () => void = (): void => {};
  onClose: () => void = (): void => {};

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick((): void => { this.onClose(); })

      // 设置面板
      Column({ space: 0 }) {
        // 顶部拖拽条
        Row() {
          Column()
            .width(40)
            .height(4)
            .backgroundColor($r('app.color.divider'))
            .borderRadius(2)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 12, bottom: 8 })

        // 标题
        Text('训练设置')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .padding({ left: 20, right: 20, bottom: 16 })
          .width('100%')
          .textAlign(TextAlign.Start)

        // 分隔线
        Divider()
          .color($r('app.color.divider'))
          .width('100%')

        // 操作按钮行
        Row({ space: 12 }) {
          // 取消训练按钮
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.trash'))
              .fontSize(18)
              .fontColor(['#F54A45'])

            Text('取消训练')
              .fontSize(14)
              .fontColor('#F54A45')
          }
          .height(44)
          .padding({ left: 16, right: 16 })
          .backgroundColor('rgba(245, 74, 69, 0.1)')
          .borderRadius(12)
          .onClick((): void => { this.onCancelTraining(); })

          // 保存返回按钮
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.checkmark_circle'))
              .fontSize(18)
              .fontColor([Color.White])

            Text('保存返回')
              .fontSize(14)
              .fontColor(Color.White)
          }
          .height(44)
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(12)
          .onClick((): void => { this.onSaveAndExit(); })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })

        // 底部导航区域避让
        Row()
          .width('100%')
          .height(this.getUIContext().px2vp(this.bottomRectHeight))
      }
      .width('100%')
      .backgroundColor($r('app.color.card_background'))
      .borderRadius({
        topLeft: 20,
        topRight: 20,
        bottomLeft: 0,
        bottomRight: 0
      })
      .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 250, curve: Curve.EaseOut }))
    }
    .width('100%')
    .height('100%')
  }
}

