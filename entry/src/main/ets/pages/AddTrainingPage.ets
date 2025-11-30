/**
 * 添加训练记录页面 - Add Training
 * 用户可以添加新的训练记录
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { toast } from '@tbs/common';

/**
 * 系统路由表构建函数
 */
@Builder
export function AddTrainingPageBuilder(): void {
  AddTrainingPage()
}

@Component
export struct AddTrainingPage {
  @State title: string = ''
  @State date: string = ''
  @State startTime: string = ''
  @State endTime: string = ''
  @State duration: string = ''
  @State notes: string = ''
  @State mood: string = '良好'
  @StorageProp('topRectHeight') topRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    const today: Date = new Date();
    const year: number = today.getFullYear();
    const month: number = today.getMonth() + 1;
    const day: number = today.getDate();
    this.date = year.toString() + '-' +
      (month < 10 ? '0' : '') + month.toString() + '-' +
      (day < 10 ? '0' : '') + day.toString();
  }

  saveTraining(): void {
    if (!this.title) {
      toast('请输入训练标题');
      return;
    }
    if (!this.duration || Number(this.duration) <= 0) {
      toast('请输入训练时长');
      return;
    }

    toast('训练记录已保存');
    this.pathStack.pop();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 0 }) {
            Row() {
              Text('训练标题')
                .fontSize(14)
                .fontColor('#333333')
                .width(100)

              TextInput({ placeholder: '例如：胸部训练' })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((value: string) => {
                  this.title = value;
                })
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)

            Divider().color('#F0F0F0')

            Row() {
              Text('日期')
                .fontSize(14)
                .fontColor('#333333')
                .width(100)

              Text(this.date)
                .fontSize(16)
                .fontColor('#333333')
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)

            Divider().color('#F0F0F0')

            Row() {
              Text('时长(分钟)')
                .fontSize(14)
                .fontColor('#333333')
                .width(100)

              TextInput({ placeholder: '输入训练时长' })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.duration = value;
                })
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 16 })

          Column({ space: 16 }) {
            Text('训练状态')
              .fontSize(14)
              .fontColor('#333333')
              .width('100%')

            Row({ space: 8 }) {
              ForEach(['良好', '一般', '疲劳'], (moodItem: string) => {
                Text(moodItem)
                  .fontSize(14)
                  .fontColor(this.mood === moodItem ? Color.White : '#666666')
                  .backgroundColor(this.mood === moodItem ? '#007AFF' : '#F0F0F0')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .borderRadius(16)
                  .onClick(() => {
                    this.mood = moodItem;
                  })
              })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)

          Column({ space: 12 }) {
            Text('备注')
              .fontSize(14)
              .fontColor('#333333')
              .width('100%')

            TextArea({ placeholder: '记录今天的训练感受...' })
              .width('100%')
              .height(120)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .onChange((value: string) => {
                this.notes = value;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)

          Column()
            .height(40)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .title('添加训练记录')
    .menus([
      {
        value: '保存',
        action: (): void => {
          this.saveTraining();
        }
      }
    ])
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
