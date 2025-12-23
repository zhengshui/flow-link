/**
 * Dashboard 今日训练摘要卡片
 */

import { TrainingRecordModel, RouterManager, NavRoutes } from '@tbs/common';

@Component
export struct DashboardTodaySummaryCard {
  @Prop todayRecords: TrainingRecordModel[] = []
  @Link currentRecordIndex: number

  build(): void {
    Column({ space: 12 }) {
      Row() {
        Text('今日训练')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        if (this.todayRecords.length > 1) {
          Text((this.currentRecordIndex + 1).toString() + '/' + this.todayRecords.length.toString())
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
      }
      .width('100%')

      if (this.todayRecords.length > 0) {
        Swiper() {
          ForEach(this.todayRecords, (record: TrainingRecordModel) => {
            this.TrainingRecordContent(record)
          })
        }
        .index(this.currentRecordIndex)
        .indicator(this.todayRecords.length > 1 ?
          new DotIndicator()
            .color($r('app.color.outline'))
            .selectedColor($r('app.color.brand_primary'))
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(6)
            .selectedItemHeight(6)
          : false)
        .loop(false)
        .onChange((index: number) => {
          this.currentRecordIndex = index;
        })
        .width('100%')
      } else {
        Column({ space: 8 }) {
          Text('今天还没有训练记录')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))
          Text('点击下方按钮开始训练')
            .fontSize(12)
            .fontColor($r('app.color.text_placeholder'))
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private TrainingRecordContent(record: TrainingRecordModel): void {
    Column({ space: 12 }) {
      Row() {
        Text(record.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 6 }) {
          Text(this.formatTimeRange(record.startTime, record.endTime))
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))

          if (record.mood !== null && record.mood !== '') {
            Text(this.getMoodLabel(record.mood))
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor(this.getMoodColor(record.mood))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
          }
        }
        .flexShrink(0)
      }
      .width('100%')

      Row({ space: 12 }) {
        this.DataItem('时长', record.duration.toString() + '分钟', $r('app.color.color_success'))
        this.DataItem('组数', record.totalSets.toString() + '组', $r('app.color.color_warning'))
        this.DataItem('卡路里', record.caloriesBurned.toString(), $r('app.color.color_danger'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text('继续训练 >')
        .fontSize(13)
        .fontColor($r('app.color.brand_primary'))
        .width('100%')
        .textAlign(TextAlign.End)
        .onClick(() => {
          RouterManager.pushPath(NavRoutes.TRAINING_SESSION, { recordId: record.id });
        })
    }
    .width('100%')
    .padding({ top: 4 })
  }

  private formatTimeRange(startTime: string, endTime: string): string {
    const startParts: string[] = startTime.split(' ');
    const endParts: string[] = endTime.split(' ');
    const startHHmmss: string = startParts.length > 1 ? startParts[1].substring(0, 8) : startTime;
    const endHHmmss: string = endParts.length > 1 ? endParts[1].substring(0, 8) : endTime;
    return startHHmmss + '-' + endHHmmss;
  }

  private getMoodLabel(mood: string): string {
    return mood || '';
  }

  private getMoodColor(mood: string): Resource {
    if (mood === '优秀') {
      return $r('app.color.color_success');
    } else if (mood === '良好') {
      return $r('app.color.brand_primary');
    } else if (mood === '一般') {
      return $r('app.color.color_warning');
    } else if (mood === '疲劳') {
      return $r('app.color.color_danger');
    }
    return $r('app.color.text_hint');
  }

  @Builder
  private DataItem(label: string, value: string, color: Resource): void {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor($r('app.color.card_background_secondary'))
    .borderRadius(8)
    .alignItems(HorizontalAlign.Center)
  }
}
