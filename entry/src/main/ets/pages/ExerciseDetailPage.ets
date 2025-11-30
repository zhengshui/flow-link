/**
 * 动作详情页面 - Exercise Detail
 * 显示动作的详细信息、视频讲解和动作步骤
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { ActionModel, ActionDataService, toast, NavRouteParams } from '@tbs/common';

/**
 * 系统路由表构建函数
 */
@Builder
export function ExerciseDetailPageBuilder(): void {
  ExerciseDetailPage()
}

@Component
export struct ExerciseDetailPage {
  @State action: ActionModel | null = null
  @State actionId: string = ''
  @StorageProp('topRectHeight') topRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  /**
   * 加载动作数据
   */
  loadData(): void {
    this.action = ActionDataService.getActionById(this.actionId);
  }

  build() {
    NavDestination() {
      Column() {
        if (this.action !== null) {
          // 主内容区域
          Scroll() {
            Column({ space: 16 }) {
              // 视频区域
              this.VideoSection()

              // 基本信息
              this.BasicInfoSection()

              // 动作描述
              this.DescriptionSection()

              // 动作步骤
              this.StepsSection()

              // 注意事项
              if (this.action.tips.length > 0) {
                this.TipsSection()
              }

              // 底部间距
              Column()
                .height(20)
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .height('100%')
        } else {
          // 无数据
          Column() {
            Text('动作不存在')
              .fontSize(16)
              .fontColor($r('app.color.text_hint'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .title(this.action?.name ?? '动作详情')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      // 获取路由参数
      const params: NavRouteParams | undefined = context.pathInfo.param as NavRouteParams | undefined
      if (params !== undefined && params.actionId !== undefined) {
        this.actionId = params.actionId
        this.loadData()
      }
    })
  }

  @Builder
  VideoSection() {
    Column({ space: 12 }) {
      // 视频封面/播放区域
      Column() {
        Column() {
          Text('▶️')
            .fontSize(48)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height(200)
      .backgroundColor($r('app.color.outline'))
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        toast('视频播放功能开发中...');
      })

      Text(this.action?.englishName ?? '')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BasicInfoSection() {
    Column({ space: 12 }) {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      // 信息卡片
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(this.action?.muscleGroup ?? '')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_primary'))
          Text('目标肌群')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Text(this.action?.difficulty ?? '')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getDifficultyColor(this.action?.difficulty ?? ''))
          Text('难度等级')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Text(this.action?.equipment ?? '无')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.color_warning'))
          Text('所需器械')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DescriptionSection() {
    Column({ space: 12 }) {
      Text('动作说明')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(this.action?.description ?? '')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StepsSection() {
    Column({ space: 12 }) {
      Text('动作步骤')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Column({ space: 12 }) {
        ForEach(this.action?.steps ?? [], (step: string, index: number) => {
          this.StepItem(step, index + 1)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StepItem(step: string, stepNumber: number) {
    Row({ space: 12 }) {
      // 步骤编号
      Column() {
        Text(stepNumber.toString())
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(32)
      .height(32)
      .backgroundColor($r('app.color.brand_primary'))
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 步骤内容
      Text(step)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .lineHeight(22)
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  TipsSection() {
    Column({ space: 12 }) {
      Text('注意事项')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Column({ space: 8 }) {
        ForEach(this.action?.tips ?? [], (tip: string) => {
          Row({ space: 8 }) {
            Text('•')
              .fontSize(16)
              .fontColor($r('app.color.color_warning'))
              .fontWeight(FontWeight.Bold)

            Text(tip)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .lineHeight(22)
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 获取难度等级颜色
   */
  getDifficultyColor(difficulty: string): string {
    if (difficulty === '初级') {
      return '#4CAF50';
    } else if (difficulty === '中级') {
      return '#FF9800';
    } else if (difficulty === '高级') {
      return '#F44336';
    }
    return '#999999';
  }
}
