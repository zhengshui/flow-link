/**
 * 训练动作卡片组件
 * 显示单个动作的训练记录，支持展开/收起
 */

import { SessionExerciseModel, TrainingSetModel } from '@tbs/common';
import { SessionSetRow } from './SessionSetRow';

@Component
export struct SessionExerciseCard {
  @ObjectLink exercise: SessionExerciseModel
  @Prop exerciseIndex: number = 0
  @State isExpanded: boolean = true
  onRemoveExercise: (index: number) => void = (): void => {}
  onAddSet: (index: number) => void = (): void => {}
  onToggleSetComplete: (exerciseIndex: number, setIndex: number) => void = (): void => {}
  onRemoveSet: (exerciseIndex: number, setIndex: number) => void = (): void => {}
  onShowSetTypeSelector: (exerciseIndex: number, setIndex: number) => void = (): void => {}

  build() {
    Column({ space: 0 }) {
      // 动作头部信息（可点击展开/收起）
      Row() {
        Column({ space: 4 }) {
          Text(this.exercise.actionName)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Row({ space: 6 }) {
            Text(this.exercise.muscleGroup)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))

            Text('·')
              .fontSize(12)
              .fontColor($r('app.color.text_placeholder'))

            Text(this.exercise.getCompletedSetsCount().toString() + '/' + this.exercise.sets.length.toString() + ' 组')
              .fontSize(12)
              .fontColor($r('app.color.brand_primary'))
              .fontWeight(FontWeight.Medium)

            if (this.exercise.getTotalVolume() > 0) {
              Text('·')
                .fontSize(12)
                .fontColor($r('app.color.text_placeholder'))

              Text(this.exercise.getTotalVolume().toString() + ' kg')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .onClick((): void => {
          this.isExpanded = !this.isExpanded;
        })

        Row({ space: 8 }) {
          // 展开/收起按钮
          SymbolGlyph(this.isExpanded ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
            .fontSize(16)
            .fontColor([$r('app.color.text_hint')])
            .onClick((): void => {
              this.isExpanded = !this.isExpanded;
            })

          // 删除按钮
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(14)
            .fontColor([$r('app.color.text_placeholder')])
            .onClick((): void => {
              this.onRemoveExercise(this.exerciseIndex);
            })
        }
      }
      .width('100%')
      .padding({ bottom: this.isExpanded ? 12 : 0 })

      // 展开时显示的内容
      if (this.isExpanded) {
        // 表头
        Row() {
          Text('#')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
            .fontWeight(FontWeight.Medium)
            .width(24)
            .textAlign(TextAlign.Center)

          Text('类型')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
            .fontWeight(FontWeight.Medium)
            .width(36)
            .textAlign(TextAlign.Center)

          Text('重量')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('次数')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          // 操作列占位
          Row()
            .width(64)
        }
        .width('100%')

        // 训练组列表
        Column({ space: 6 }) {
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
        .margin({ top: 8 })

        // 添加组按钮
        Button('+ 添加组')
          .width('100%')
          .height(36)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.card_background_secondary'))
          .fontColor($r('app.color.brand_primary'))
          .borderRadius(8)
          .margin({ top: 12 })
          .onClick((): void => {
            this.onAddSet(this.exerciseIndex);
          })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(14)
    .shadow({
      radius: 6,
      color: 'rgba(0, 0, 0, 0.03)',
      offsetX: 0,
      offsetY: 1
    })
    .alignItems(HorizontalAlign.Start)
  }
}
