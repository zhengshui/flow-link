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
            .fontColor('#1A1A1A')

          Row({ space: 8 }) {
            Text(this.exercise.muscleGroup)
              .fontSize(13)
              .fontColor('#666666')

            Text('·')
              .fontSize(13)
              .fontColor('#CCCCCC')

            Text(this.exercise.getCompletedSetsCount().toString() + '/' + this.exercise.sets.length.toString() + ' 组')
              .fontSize(13)
              .fontColor('#007AFF')

            if (this.exercise.getTotalVolume() > 0) {
              Text('·')
                .fontSize(13)
                .fontColor('#CCCCCC')

              Text(this.exercise.getTotalVolume().toString() + ' kg')
                .fontSize(13)
                .fontColor('#666666')
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('×')
          .fontSize(22)
          .fontColor('#CCCCCC')
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
            .fontColor('#999999')
            .fontWeight(FontWeight.Medium)
            .width(32)
            .textAlign(TextAlign.Center)

          Text('类型')
            .fontSize(12)
            .fontColor('#999999')
            .fontWeight(FontWeight.Medium)
            .width(56)
            .textAlign(TextAlign.Center)

          Blank().layoutWeight(0.2)

          Text('重量')
            .fontSize(12)
            .fontColor('#999999')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Blank().layoutWeight(0.2)

          Text('次数')
            .fontSize(12)
            .fontColor('#999999')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(0.8)
            .textAlign(TextAlign.Center)

          Text('')
            .width(44)

          Text('')
            .width(32)
        }
        .width('100%')
        .padding({ left: 4, right: 4 })

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
        .backgroundColor('#F5F7FA')
        .fontColor('#007AFF')
        .borderRadius(8)
        .margin({ top: 16 })
        .onClick((): void => {
          this.onAddSet(this.exerciseIndex);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
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

