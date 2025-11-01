/**
 * 动作详情页面 - Exercise Detail
 * 显示动作的详细信息、视频讲解和动作步骤
 */

import { ActionModel, ActionDataService, toast } from '@tbs/common';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ExerciseDetailPage {
  @State action: ActionModel | null = null
  @State actionId: string = ''

  aboutToAppear(): void {
    // 获取路由参数
    const params: ESObject = router.getParams() as ESObject;
    if (params !== null && params.actionId !== undefined) {
      this.actionId = params.actionId as string;
      this.loadData();
    }
  }

  /**
   * 加载动作数据
   */
  loadData(): void {
    this.action = ActionDataService.getActionById(this.actionId);
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    router.back();
  }

  build() {
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
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
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
      .backgroundColor('#E8E8E8')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        toast('视频播放功能开发中...');
      })

      Text(this.action?.englishName ?? '')
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BasicInfoSection() {
    Column({ space: 12 }) {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      // 信息卡片
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(this.action?.muscleGroup ?? '')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          Text('目标肌群')
            .fontSize(11)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#F9F9F9')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Text(this.action?.difficulty ?? '')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getDifficultyColor(this.action?.difficulty ?? ''))
          Text('难度等级')
            .fontSize(11)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#F9F9F9')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Text(this.action?.equipment ?? '无')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
          Text('所需器械')
            .fontSize(11)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#F9F9F9')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DescriptionSection() {
    Column({ space: 12 }) {
      Text('动作说明')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      Text(this.action?.description ?? '')
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StepsSection() {
    Column({ space: 12 }) {
      Text('动作步骤')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      Column({ space: 12 }) {
        ForEach(this.action?.steps ?? [], (step: string, index: number) => {
          this.StepItem(step, index + 1)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
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
      .backgroundColor('#007AFF')
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 步骤内容
      Text(step)
        .fontSize(14)
        .fontColor('#333333')
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

      Column({ space: 8 }) {
        ForEach(this.action?.tips ?? [], (tip: string) => {
          Row({ space: 8 }) {
            Text('•')
              .fontSize(16)
              .fontColor('#FF9800')
              .fontWeight(FontWeight.Bold)

            Text(tip)
              .fontSize(14)
              .fontColor('#666666')
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
    .backgroundColor(Color.White)
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
