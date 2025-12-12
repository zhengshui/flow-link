/**
 * 训练动作卡片组件
 * 显示单个动作的训练记录
 */

import { SessionExerciseModel, TrainingSetModel } from '@tbs/common';
import { SessionSetRow } from './SessionSetRow';

@Component
export struct SessionExerciseCard {
  @ObjectLink exercise: SessionExerciseModel
  @Prop exerciseIndex: number = 0
  onRemoveExercise: (index: number) => void = (): void => {}
  onAddSet: (index: number) => void = (): void => {}
  onToggleSetComplete: (exerciseIndex: number, setIndex: number) => void = (): void => {}
  onRemoveSet: (exerciseIndex: number, setIndex: number) => void = (): void => {}
  onShowSetTypeSelector: (exerciseIndex: number, setIndex: number) => void = (): void => {}

  build() {
    Column({ space: 0 }) {
      // 动作头部信息
      Row() {
        Column({ space: 4 }) {
          Text(this.exercise.actionName)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Row({ space: 8 }) {
            Text(this.exercise.muscleGroup)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))

            Text('·')
              .fontSize(13)
              .fontColor($r('app.color.text_placeholder'))

            Text(this.exercise.getCompletedSetsCount().toString() + '/' + this.exercise.sets.length.toString() + ' 组')
              .fontSize(13)
              .fontColor($r('app.color.brand_primary'))

            if (this.exercise.getTotalVolume() > 0) {
              Text('·')
                .fontSize(13)
                .fontColor($r('app.color.text_placeholder'))

              Text(this.exercise.getTotalVolume().toString() + ' kg')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('×')
          .fontSize(22)
          .fontColor($r('app.color.text_placeholder'))
          .fontWeight(FontWeight.Lighter)
          .onClick((): void => {
            this.onRemoveExercise(this.exerciseIndex);
          })
      }
      .width('100%')
      .padding({ bottom: 16 })

      // 表头
      Row() {
        Text('#')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
          .fontWeight(FontWeight.Medium)
          .width(28)
          .textAlign(TextAlign.Center)

        Text('类型')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
          .fontWeight(FontWeight.Medium)
          .width(40)
          .textAlign(TextAlign.Center)

        Text('重量')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('次数')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 操作列占位
        Row()
          .width(68)
      }
      .width('100%')

        // 训练组列表
        Column({ space: 8 }) {
          ForEach(this.exercise.sets, (set: TrainingSetModel, setIndex: number) => {
            SessionSetRow({
              set: set,
              exerciseIndex: this.exerciseIndex,
              setIndex: setIndex,
              onToggleComplete: this.onToggleSetComplete,
              onRemoveSet: this.onRemoveSet,
              onShowTypeSelector: this.onShowSetTypeSelector
            })
          })
        }
        .width('100%')
        .margin({ top: 12 })

      // 添加组按钮
      Button('+ 添加组')
        .width('100%')
        .height(40)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.card_background_secondary'))
        .fontColor($r('app.color.brand_primary'))
        .borderRadius(8)
        .margin({ top: 16 })
        .onClick((): void => {
          this.onAddSet(this.exerciseIndex);
        })
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
}
