/**
 * 模板卡片组件
 * 用于展示单个训练模板的摘要信息
 */
import { PlanTemplateModel } from '@tbs/common';

@Component
export struct TemplateCard {
  @Prop template: PlanTemplateModel = new PlanTemplateModel();
  onTap: () => void = () => {};
  onUse: () => void = () => {};
  showUseButton: boolean = true;

  build() {
    Column({ space: 10 }) {
      // 标题行
      Row() {
        Text(this.template.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 6 }) {
          // 难度标签
          Text(this.template.level)
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.getLevelColor(this.template.level))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(3)

          // 官方/个人标签
          if (this.template.isOfficial) {
            Text('官方')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.brand_primary'))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(3)
          }
        }
      }
      .width('100%')

      // 描述
      Text(this.template.description)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      // 标签信息行
      Row({ space: 8 }) {
        if (this.template.splitType) {
          this.InfoTag(this.template.splitType)
        }
        if (this.template.equipment) {
          this.InfoTag(this.template.equipment)
        }
        this.InfoTag(this.template.durationWeeks.toString() + '周')
        this.InfoTag('每周' + this.template.trainingDaysPerWeek.toString() + '天')
      }
      .width('100%')

      // 目标和作者
      Row() {
        Row({ space: 4 }) {
          Text('#' + this.template.goal)
            .fontSize(11)
            .fontColor($r('app.color.brand_primary'))
        }
        .layoutWeight(1)

        Text(this.template.author)
          .fontSize(11)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')

      // 使用按钮
      if (this.showUseButton) {
        Button('使用此模板')
          .width('100%')
          .height(36)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(8)
          .margin({ top: 4 })
          .onClick(() => {
            this.onUse();
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .onClick(() => {
      this.onTap();
    })
  }

  @Builder
  InfoTag(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor($r('app.color.text_secondary'))
      .backgroundColor($r('app.color.card_background_secondary'))
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(4)
  }

  /**
   * 获取难度等级颜色
   */
  getLevelColor(level: string): Resource {
    if (level === '初级') {
      return $r('app.color.color_success');
    } else if (level === '中级') {
      return $r('app.color.color_warning');
    } else if (level === '高级') {
      return $r('app.color.color_danger');
    }
    return $r('app.color.text_hint');
  }
}

