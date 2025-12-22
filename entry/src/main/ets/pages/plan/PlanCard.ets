/**
 * 计划卡片组件
 * 用于展示单个健身计划的摘要信息
 */
import { FitnessPlanModel } from '@tbs/common';

@Component
export struct PlanCard {
  @Prop plan: FitnessPlanModel = new FitnessPlanModel();
  onTap: () => void = () => {};

  build() {
    Column({ space: 12 }) {
      // 标题行
      Row() {
        Text(this.plan.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.plan.status)
          .fontSize(11)
          .fontColor(Color.White)
          .backgroundColor(this.getStatusColor(this.plan.status))
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(4)
      }
      .width('100%')

      // 进度条
      Column({ space: 6 }) {
        Row() {
          Text('完成进度')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
          Blank()
          Text(this.plan.completionRate.toString() + '%')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.brand_primary'))
        }
        .width('100%')

        Row() {
          Row()
            .width(this.plan.completionRate.toString() + '%')
            .height('100%')
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(2)
        }
        .width('100%')
        .height(6)
        .backgroundColor($r('app.color.outline'))
        .borderRadius(3)
      }
      .width('100%')

      // 统计信息
      Row({ space: 16 }) {
        this.StatItem('第' + this.plan.currentWeek.toString() + '周', '当前周')
        this.StatItem(this.plan.totalCompletedDays.toString() + '天', '已完成')
        this.StatItem(this.plan.goal, '目标')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)

      // 日期信息
      Row() {
        Text(this.plan.startDate + ' 至 ' + this.plan.endDate)
          .fontSize(11)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')
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
  StatItem(value: string, label: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.brand_primary'))
      Text(label)
        .fontSize(10)
        .fontColor($r('app.color.text_hint'))
    }
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 获取计划状态颜色
   */
  getStatusColor(status: string): Resource {
    if (status === '进行中') {
      return $r('app.color.color_success');
    } else if (status === '已完成') {
      return $r('app.color.brand_primary');
    } else if (status === '已暂停') {
      return $r('app.color.color_warning');
    } else if (status === '已归档') {
      return $r('app.color.text_hint');
    }
    return $r('app.color.text_hint');
  }
}

