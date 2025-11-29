/**
 * 训练组行组件
 * 显示单组训练的详细信息，支持编辑重量、次数、完成状态等
 */

import { TrainingSetModel, SetTypeConst } from '@tbs/common';

@Component
export struct SessionSetRow {
  @ObjectLink set: TrainingSetModel
  @Prop exerciseIndex: number = 0
  @Prop setIndex: number = 0
  onToggleComplete: (exerciseIndex: number, setIndex: number) => void = (): void => {}
  onRemoveSet: (exerciseIndex: number, setIndex: number) => void = (): void => {}
  onShowTypeSelector: (exerciseIndex: number, setIndex: number) => void = (): void => {}

  build() {
    Row() {
      // 组序号
      Text((this.setIndex + 1).toString())
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.set.isCompleted ? '#007AFF' : '#666666')
        .width(32)
        .textAlign(TextAlign.Center)

      // 类型标签（可点击切换）
      Text(this.set.setType)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.set.setType === SetTypeConst.WARMUP ? '#E67E22' :
          this.set.setType === SetTypeConst.COOLDOWN ? '#27AE60' : '#3498DB')
        .width(56)
        .height(24)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.set.setType === SetTypeConst.WARMUP ? '#FDF2E9' :
          this.set.setType === SetTypeConst.COOLDOWN ? '#E8F8F5' : '#EBF5FB')
        .borderRadius(12)
        .onClick((): void => {
          this.onShowTypeSelector(this.exerciseIndex, this.setIndex);
        })

      Blank().layoutWeight(0.2)

      // 重量输入
      Row() {
        TextInput({ text: this.set.weight.toString() })
          .width(56)
          .height(36)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .type(InputType.Number)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.set.isCompleted ? '#F0F9FF' : '#F5F7FA')
          .borderRadius(8)
          .onChange((value: string): void => {
            const weight: number = parseInt(value, 10);
            if (!isNaN(weight)) {
              this.set.weight = weight;
            }
          })

        Text('kg')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Blank().layoutWeight(0.2)

      // 次数输入
      Row() {
        TextInput({ text: this.set.reps.toString() })
          .width(48)
          .height(36)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .type(InputType.Number)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.set.isCompleted ? '#F0F9FF' : '#F5F7FA')
          .borderRadius(8)
          .onChange((value: string): void => {
            const reps: number = parseInt(value, 10);
            if (!isNaN(reps)) {
              this.set.reps = reps;
            }
          })

        Text('次')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .layoutWeight(0.8)
      .justifyContent(FlexAlign.Center)

      // 完成状态按钮
      Button() {
        Text(this.set.isCompleted ? '✓' : '')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(32)
      .height(32)
      .backgroundColor(this.set.isCompleted ? '#007AFF' : '#E8E8E8')
      .borderRadius(16)
      .margin({ left: 8 })
      .onClick((): void => {
        this.onToggleComplete(this.exerciseIndex, this.setIndex);
      })

      // 删除按钮
      Text('×')
        .fontSize(18)
        .fontColor('#CCCCCC')
        .width(32)
        .textAlign(TextAlign.Center)
        .onClick((): void => {
          this.onRemoveSet(this.exerciseIndex, this.setIndex);
        })
    }
    .width('100%')
    .height(52)
    .padding({ left: 4, right: 4, top: 4, bottom: 4 })
    .backgroundColor(this.set.isCompleted ? '#FAFCFF' : Color.Transparent)
    .borderRadius(10)
  }
}

