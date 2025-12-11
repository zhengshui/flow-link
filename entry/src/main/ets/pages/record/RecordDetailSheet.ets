/**
 * 训练记录详情弹窗组件
 */

import { TrainingRecordModel, ExerciseModel, toast, TrainingApiService, RouterManager, NavRoutes, NavRouteParams } from '@tbs/common';
import { promptAction } from '@kit.ArkUI';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';
import { CalendarDayModel, CopyActionData } from './CalendarDayModel';

/**
 * 训练记录详情弹窗
 */
@Component
export struct RecordDetailSheet {
  @Link showDetailDialog: boolean
  @Link selectedDay: CalendarDayModel | null
  @Link selectedDayRecords: TrainingRecordModel[]
  @Link currentRecordIndex: number
  @StorageProp('topRectHeight') topRectHeight: number = 0
  onRecordDeleted: () => void = () => {}

  // Swiper控制器
  private swiperController: SwiperController = new SwiperController()

  build() {
    Column() {
      // 顶部标题栏
      this.HeaderBar()

      // 记录详情 - Swiper 支持左右滑动
      if (this.selectedDayRecords.length > 1) {
        Swiper(this.swiperController) {
          ForEach(this.selectedDayRecords, (record: TrainingRecordModel, index: number) => {
            this.RecordDetailContent(record)
          })
        }
        .index(this.currentRecordIndex)
        .indicator(false)
        .loop(false)
        .onChange((index: number) => {
          this.currentRecordIndex = index;
        })
        .width('100%')
        .layoutWeight(1)
      } else if (this.selectedDayRecords.length === 1) {
        this.RecordDetailContent(this.selectedDayRecords[0])
      }

      // 底部操作栏
      if (this.selectedDayRecords.length > 0) {
        this.BottomActionBar(this.selectedDayRecords[this.currentRecordIndex])
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  HeaderBar(): void {
    Row() {
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(24)
        .fontColor([$r('app.color.text_primary')])
        .onClick(() => {
          this.showDetailDialog = false;
        })

      Blank()

      Text(this.selectedDay?.dateStr ?? '')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Blank()

      // 页码指示
      if (this.selectedDayRecords.length > 1) {
        Text((this.currentRecordIndex + 1).toString() + '/' + this.selectedDayRecords.length.toString())
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      } else {
        Text('')
          .fontSize(14)
          .width(40)
      }
    }
    .width('100%')
    .height(70)
    .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  RecordDetailContent(record: TrainingRecordModel): void {
    Scroll() {
      Column({ space: 16 }) {
        // 训练标题卡片
        Column({ space: 12 }) {
          Row() {
            Column({ space: 4 }) {
              Text(record.title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
              Text(this.extractTimeFromDateTime(record.startTime) + ' - ' + this.extractTimeFromDateTime(record.endTime))
                .fontSize(13)
                .fontColor($r('app.color.text_hint'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (record.mood.length > 0) {
              Text(record.mood)
                .fontSize(11)
                .fontColor(Color.White)
                .backgroundColor(this.getMoodColor(record.mood))
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(4)
            }
          }
          .width('100%')

          // 训练数据统计
          Row({ space: 8 }) {
            this.DataTag('时长', record.duration.toString() + '分钟', $r('app.color.color_success'))
            this.DataTag('组数', record.totalSets.toString() + '组', $r('app.color.color_warning'))
            this.DataTag('容量', (record.totalWeight / 1000).toFixed(1) + 'T', $r('app.color.brand_primary'))
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)

        // 训练动作详情
        if (record.exercises.length > 0) {
          Column({ space: 12 }) {
            Text('训练动作')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            ForEach(record.exercises, (exercise: ExerciseModel, index: number) => {
              this.ExerciseDetailItem(exercise, index)
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
        }

        // 训练备注
        if (record.notes.length > 0) {
          Column({ space: 8 }) {
            Text('训练心得')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            Text(record.notes)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }

        // 底部间距
        Column().height(80)
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  ExerciseDetailItem(exercise: ExerciseModel, index: number): void {
    Row({ space: 12 }) {
      // 序号
      Text((index + 1).toString())
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(12)

      // 动作信息
      Column({ space: 4 }) {
        Text(exercise.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Row({ space: 16 }) {
          Text(exercise.sets.toString() + '组')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Text(exercise.reps.toString() + '次/组')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Text(exercise.weight.toString() + 'kg')
            .fontSize(13)
            .fontColor($r('app.color.brand_primary'))
            .fontWeight(FontWeight.Medium)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 肌群标签
      if (exercise.muscleGroup.length > 0) {
        Text(exercise.muscleGroup)
          .fontSize(11)
          .fontColor($r('app.color.text_hint'))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(4)
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background_secondary'))
    .borderRadius(8)
  }

  @Builder
  BottomActionBar(record: TrainingRecordModel): void {
    Row({ space: 10 }) {
      // 编辑/继续训练
      Button('继续训练')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .height(42)
        .layoutWeight(1)
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(8)
        .onClick(() => {
          this.showDetailDialog = false;
          const params: NavRouteParams = { recordId: record.id };
          RouterManager.pushPath(NavRoutes.TRAINING_SESSION, params);
        })

      // 复制到今天
      Button('复制到今天')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .height(42)
        .layoutWeight(1)
        .backgroundColor($r('app.color.color_success'))
        .borderRadius(8)
        .onClick(() => {
          this.copyToToday(record);
        })

      // 删除
      Button('删除')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .height(42)
        .width(64)
        .backgroundColor($r('app.color.color_danger'))
        .borderRadius(8)
        .onClick(() => {
          promptAction.showDialog({
            title: '确认删除',
            message: '确定要删除这条训练记录吗？',
            buttons: [
              { text: '取消', color: '#646A73' },
              { text: '删除', color: '#F54A45' }
            ]
          }).then((result: promptAction.ShowDialogSuccessResponse) => {
            if (result.index === 1) {
              this.deleteRecord(record.id);
            }
          }).catch((err: Error) => {
            console.error('Dialog error:', JSON.stringify(err));
          });
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor($r('app.color.card_background'))
    .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.06)', offsetX: 0, offsetY: -2 })
  }

  @Builder
  DataTag(label: string, value: string, color: Resource): void {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor($r('app.color.card_background_secondary'))
    .borderRadius(8)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 复制到今天 - 将记录中的动作添加到今天的训练
   */
  private copyToToday(record: TrainingRecordModel): void {
    // 将动作数据存储到 AppStorage
    const actionsData: CopyActionData[] = [];
    for (let i: number = 0; i < record.exercises.length; i++) {
      const ex: ExerciseModel = record.exercises[i];
      actionsData.push(new CopyActionData(
        ex.id.toString(),
        ex.name,
        ex.muscleGroup,
        ex.sets,
        ex.reps,
        ex.weight
      ));
    }
    AppStorage.setOrCreate<string>('copyRecordActionsJson', JSON.stringify(actionsData));

    this.showDetailDialog = false;
    toast('已复制动作，开始训练');
    const params: NavRouteParams = { copyFromRecord: true };
    RouterManager.pushPath(NavRoutes.TRAINING_SESSION, params);
  }

  /**
   * 删除训练记录
   */
  private async deleteRecord(recordId: string): Promise<void> {
    try {
      const res: ResponseResult = await TrainingApiService.deleteTrainingRecord(recordId);
      if (res.code === 0) {
        toast('删除成功');
        this.showDetailDialog = false;
        this.onRecordDeleted();
      } else {
        toast(res.message ?? '删除失败');
      }
    } catch (err) {
      console.error('删除训练记录失败:', JSON.stringify(err));
      toast('删除失败，请重试');
    }
  }

  /**
   * 从完整日期时间字符串中提取时间部分 (HH:mm)
   * 支持格式: "YYYY-MM-DD HH:mm:ss" 或 "HH:mm" 或 "HH:mm:ss"
   */
  private extractTimeFromDateTime(dateTimeStr: string): string {
    if (dateTimeStr.length === 0) {
      return '';
    }
    // 如果包含空格，说明是完整日期时间格式 "YYYY-MM-DD HH:mm:ss"
    const spaceIndex: number = dateTimeStr.indexOf(' ');
    if (spaceIndex > 0) {
      const timePart: string = dateTimeStr.substring(spaceIndex + 1);
      // 提取 HH:mm 部分
      if (timePart.length >= 5) {
        return timePart.substring(0, 5);
      }
      return timePart;
    }
    // 否则可能已经是时间格式 "HH:mm" 或 "HH:mm:ss"
    if (dateTimeStr.length >= 5) {
      return dateTimeStr.substring(0, 5);
    }
    return dateTimeStr;
  }

  /**
   * 获取心情状态颜色
   */
  private getMoodColor(mood: string): Resource {
    if (mood === '优秀') {
      return $r('app.color.color_success');
    } else if (mood === '良好') {
      return $r('app.color.set_cooldown');
    } else if (mood === '一般') {
      return $r('app.color.color_warning');
    } else if (mood === '疲劳') {
      return $r('app.color.color_danger');
    }
    return $r('app.color.text_hint');
  }
}

