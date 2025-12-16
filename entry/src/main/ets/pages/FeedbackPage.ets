/**
 * 反馈中心页面
 * 用户提交意见反馈
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { AuthApiService, ResponseResult, toast } from '@tbs/common';

/**
 * 系统路由表构建函数
 */
@Builder
export function FeedbackPageBuilder(): void {
  FeedbackPage()
}

@Component
export struct FeedbackPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State feedbackContent: string = ''
  @State isSubmitting: boolean = false
  @State selectedType: string = '建议'
  private pathStack: NavPathStack = new NavPathStack()
  private feedbackTypes: string[] = ['建议', '问题', '其他']
  private maxContentLength: number = 1000
  private minContentLength: number = 1

  /**
   * 检查是否可以提交
   */
  canSubmit(): boolean {
    return this.feedbackContent.length >= this.minContentLength &&
      this.feedbackContent.length <= this.maxContentLength &&
      !this.isSubmitting;
  }

  /**
   * 提交反馈
   */
  async submitFeedback(): Promise<void> {
    if (!this.canSubmit()) {
      if (this.feedbackContent.length < this.minContentLength) {
        toast('请输入至少' + this.minContentLength + '个字符');
      }
      return;
    }

    this.isSubmitting = true;

    try {
      const response: ResponseResult = await AuthApiService.submitFeedback(
        this.feedbackContent,
        this.selectedType
      );

      if (response.code === 0) {
        toast('感谢您的反馈！');
        this.pathStack.pop();
      } else {
        toast(response.message ?? '提交失败');
      }
    } catch (err) {
      toast('提交失败，请稍后重试');
      console.error('提交反馈失败:', JSON.stringify(err));
    } finally {
      this.isSubmitting = false;
    }
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

          Text('反馈中心')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          // 占位，保持标题居中
          Column().width(24)
        }
        .width('100%')
        .height(70)
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topRectHeight) })
        .backgroundColor($r('app.color.card_background'))

        // 内容区域
        Scroll() {
          Column({ space: 20 }) {
            // 顶部提示
            Column({ space: 8 }) {
              Text('您的意见对我们很重要')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))

              Text('请描述您遇到的问题或提出宝贵建议')
                .fontSize(14)
                .fontColor($r('app.color.text_hint'))
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 20, right: 20, top: 20 })

            // 反馈类型选择
            Column({ space: 12 }) {
              Text('反馈类型')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))

              Row({ space: 12 }) {
                ForEach(this.feedbackTypes, (type: string) => {
                  this.TypeChip(type)
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .alignItems(HorizontalAlign.Start)

            // 反馈输入区域
            Column({ space: 12 }) {
              Text('反馈内容')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))

              Column() {
                TextArea({ placeholder: '请详细描述您的问题或建议...' })
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                  .placeholderColor($r('app.color.text_placeholder'))
                  .placeholderFont({ size: 15 })
                  .backgroundColor(Color.Transparent)
                  .padding(0)
                  .height(180)
                  .maxLength(this.maxContentLength)
                  .onChange((value: string) => {
                    this.feedbackContent = value;
                  })

                // 字数统计
                Row() {
                  Blank()
                  Text(this.feedbackContent.length + '/' + this.maxContentLength)
                    .fontSize(12)
                    .fontColor(this.feedbackContent.length > this.maxContentLength ?
                    $r('app.color.color_danger') : $r('app.color.text_hint'))
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.card_background'))
              .borderRadius(12)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .alignItems(HorizontalAlign.Start)

            // 温馨提示
            Column({ space: 8 }) {
              Row({ space: 6 }) {
                SymbolGlyph($r('sys.symbol.lightbulb'))
                  .fontSize(14)
                  .fontColor([$r('app.color.brand_primary')])
                Text('温馨提示')
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.brand_primary'))
              }

              Text('• 请尽量详细描述问题或建议')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
              Text('• 我们会认真阅读每一条反馈')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
              Text('• 感谢您帮助我们做得更好')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('90%')
            .padding(16)
            .margin({ left: 20, right: 20 })
            .backgroundColor($r('app.color.card_background_secondary'))
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)

            // 提交按钮
            Button(this.isSubmitting ? '提交中...' : '提交反馈')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor(this.canSubmit() ? $r('app.color.brand_primary') : $r('app.color.text_placeholder'))
              .borderRadius(12)
              .height(50)
              .width('90%')
              .margin({ left: 20, right: 20, top: 12 })
              .enabled(this.canSubmit())
              .onClick(() => {
                this.submitFeedback();
              })
          }
          .width('100%')
          .padding({ bottom: 40 })
        }
        .layoutWeight(1)
        .backgroundColor($r('app.color.page_background'))
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
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

  @Builder
  TypeChip(type: string) {
    Text(type)
      .fontSize(14)
      .fontColor(this.selectedType === type ? Color.White : $r('app.color.text_primary'))
      .backgroundColor(this.selectedType === type ? $r('app.color.brand_primary') : $r('app.color.card_background'))
      .borderRadius(20)
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .onClick(() => {
        this.selectedType = type;
      })
  }
}

