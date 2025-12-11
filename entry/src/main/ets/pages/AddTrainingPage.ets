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
      Column() {
        // 自定义标题栏
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([$r('app.color.text_primary')])
            .onClick(() => {
              this.pathStack.pop();
            })

          Text('添加训练记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('保存')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.brand_primary'))
            .onClick(() => {
              this.saveTraining();
            })
        }
        .width('100%')
        .height(70)
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topRectHeight) })
        .backgroundColor($r('app.color.card_background'))

        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 0 }) {
              Row() {
                Text('训练标题')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .width(100)

              TextInput({ placeholder: '例如：胸部训练' })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .fontColor($r('app.color.text_primary'))
                .fontSize(15)
                .onChange((value: string) => {
                  this.title = value;
                })
            }
            .width('100%')
            .height(52)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)

            Divider().color($r('app.color.outline'))

            Row() {
              Text('日期')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .width(100)

              Text(this.date)
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .height(52)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)

            Divider().color($r('app.color.outline'))

            Row() {
              Text('时长(分钟)')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .width(100)

              TextInput({ placeholder: '输入训练时长' })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .fontColor($r('app.color.text_primary'))
                .fontSize(15)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.duration = value;
                })
            }
            .width('100%')
            .height(52)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ top: 16 })

          Column({ space: 12 }) {
            Text('训练状态')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            Row({ space: 8 }) {
              ForEach(['良好', '一般', '疲劳'], (moodItem: string) => {
                Text(moodItem)
                  .fontSize(13)
                  .fontColor(this.mood === moodItem ? Color.White : $r('app.color.text_secondary'))
                  .backgroundColor(this.mood === moodItem ? $r('app.color.brand_primary') : $r('app.color.outline'))
                  .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                  .borderRadius(16)
                  .onClick(() => {
                    this.mood = moodItem;
                  })
              })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)

          Column({ space: 12 }) {
            Text('备注')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            TextArea({ placeholder: '记录今天的训练感受...' })
              .width('100%')
              .height(120)
              .backgroundColor($r('app.color.card_background'))
              .fontColor($r('app.color.text_primary'))
              .borderRadius(8)
              .onChange((value: string) => {
                this.notes = value;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)

            Column()
              .height(40)
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .backgroundColor($r('app.color.page_background'))
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
