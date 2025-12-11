/**
 * 训练顶部栏组件
 * 显示标题、时间、统计数据和控制按钮
 */

/**
 * 顶部栏配置参数
 */
export interface TrainingTopBarParams {
  title: string;
  currentTime: string;
  isRunning: boolean;
  totalSets: number;
  completedExercises: number;
  totalVolume: number;
  topRectHeight: number;
}

/**
 * 顶部栏回调接口
 */
export interface TrainingTopBarCallbacks {
  onClose: () => void;
  onTitleChange: (value: string) => void;
  onFinish: () => void;
  onTimeClick: () => void;
  onToggleTimer: () => void;
  onResetTimer: () => void;
}

@Component
export struct TrainingTopBar {
  @Prop params: TrainingTopBarParams;
  callbacks: TrainingTopBarCallbacks = {
    onClose: (): void => {},
    onTitleChange: (_value: string): void => {},
    onFinish: (): void => {},
    onTimeClick: (): void => {},
    onToggleTimer: (): void => {},
    onResetTimer: (): void => {}
  };

  build() {
    Column({ space: 0 }) {
      // 状态栏占位
      Row()
        .width('100%')
        .height(this.getUIContext().px2vp(this.params.topRectHeight))

      Row() {
        // 关闭按钮
        Button() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(18)
            .fontColor([$r('app.color.text_secondary')])
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick((): void => { this.callbacks.onClose(); })

        TextInput({ text: this.params.title })
          .layoutWeight(1)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(Color.Transparent)
          .margin({ left: 8, right: 8 })
          .onChange((value: string): void => { this.callbacks.onTitleChange(value); })

        Button('完成')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .height(34)
          .padding({ left: 16, right: 16 })
          .backgroundColor($r('app.color.color_success'))
          .borderRadius(17)
          .onClick((): void => { this.callbacks.onFinish(); })
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 16 })

      Row() {
        Row({ space: 6 }) {
          // 时间显示，点击可编辑
          Text(this.params.currentTime)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_primary'))
            .onClick((): void => { this.callbacks.onTimeClick(); })

          // 暂停/继续按钮
          Button() {
            SymbolGlyph(this.params.isRunning ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
              .fontSize(14)
              .fontColor([$r('app.color.brand_primary')])
          }
          .width(32)
          .height(32)
          .backgroundColor($r('app.color.brand_primary_light'))
          .borderRadius(16)
          .onClick((): void => { this.callbacks.onToggleTimer(); })

          // 重置按钮
          Button() {
            SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
              .fontSize(14)
              .fontColor([$r('app.color.color_danger')])
          }
          .width(32)
          .height(32)
          .backgroundColor($r('app.color.color_danger_light'))
          .borderRadius(16)
          .onClick((): void => { this.callbacks.onResetTimer(); })
        }

        Row({ space: 16 }) {
          this.StatItem(this.params.totalSets.toString(), '组')
          this.StatItem(this.params.completedExercises.toString(), '动作')
          this.StatItem(this.params.totalVolume.toString(), 'kg')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.04)', offsetX: 0, offsetY: 2 })
  }

  @Builder
  StatItem(value: string, label: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
    }
    .alignItems(HorizontalAlign.Center)
  }
}

