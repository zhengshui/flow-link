/**
 * 训练感受选择组件
 * 支持选择优秀、良好、一般、疲劳四种训练状态
 */

@Component
export struct TrainingFeedbackSection {
  @Prop selectedMood: string = ''
  onSelect: (mood: string) => void = (): void => {}

  build() {
    Column({ space: 16 }) {
      Text('训练状态')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      Row({ space: 8 }) {
        this.MoodButton('优秀', '🌟')
        this.MoodButton('良好', '😊')
        this.MoodButton('一般', '😐')
        this.MoodButton('疲劳', '😓')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 2
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  MoodButton(mood: string, icon: string) {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(22)

      Text(mood)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectedMood === mood ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
    }
    .layoutWeight(1)
    .height(68)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.selectedMood === mood ? $r('app.color.brand_primary_light') : $r('app.color.card_background_secondary'))
    .borderRadius(12)
    .border({
      width: this.selectedMood === mood ? 2 : 0,
      color: $r('app.color.brand_primary')
    })
    .onClick((): void => {
      this.onSelect(mood);
    })
  }
}
