/**
 * 训练记录页面 - Record
 * 按日期列表显示训练记录，支持添加、修改和删除
 */

import { TrainingRecordModel, TrainingApiService, toast, ExerciseModel } from '@tbs/common';
import { promptAction } from '@kit.ArkUI';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

@Component
export struct RecordPage {
  @State records: TrainingRecordModel[] = []
  @State isLoading: boolean = false

  aboutToAppear(): void {
    this.loadRecords();
  }

  /**
   * 加载训练记录
   */
  async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      const res: ResponseResult = await TrainingApiService.getTrainingRecords(1, 100);
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const recordsArray: Object = apiData['records'] ?? [];
        this.records = recordsArray as TrainingRecordModel[];
      } else {
        toast(res.message ?? '加载失败');
      }
    } catch (err) {
      console.error('加载训练记录失败:', JSON.stringify(err));
      toast('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 删除训练记录
   */
  async deleteRecord(recordId: number): Promise<void> {
    try {
      const res: ResponseResult = await TrainingApiService.deleteTrainingRecord(recordId.toString());
      if (res.code === 0) {
        // 从列表中移除已删除的记录
        const newRecords: TrainingRecordModel[] = [];
        for (let i: number = 0; i < this.records.length; i++) {
          if (this.records[i].id !== recordId) {
            newRecords.push(this.records[i]);
          }
        }
        this.records = newRecords;
        toast('删除成功');
      } else {
        toast(res.message ?? '删除失败');
      }
    } catch (err) {
      console.error('删除训练记录失败:', JSON.stringify(err));
      toast('删除失败，请重试');
    }
  }

  /**
   * 显示删除确认对话框
   */
  showDeleteDialog(record: TrainingRecordModel): void {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要删除这条训练记录吗？',
      buttons: [
        {
          text: '取消',
          color: '#666666'
        },
        {
          text: '删除',
          color: '#FF0000'
        }
      ]
    }).then((data: promptAction.ShowDialogSuccessResponse) => {
      if (data.index === 1) {
        this.deleteRecord(record.id);
      }
    }).catch(() => {
      console.error('Dialog error');
    });
  }

  build() {
    Column() {
      // 主内容区域
      if (this.records.length > 0) {
        // 显示记录列表
        List({ space: 12 }) {
          ForEach(this.records, (record: TrainingRecordModel) => {
            ListItem() {
              this.RecordCard(record)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('#F5F5F5')
      } else {
        // 空状态提示
        Scroll() {
          Column({ space: 16 }) {
            Text('📝')
              .fontSize(48)

            Text('还没有训练记录')
              .fontSize(16)
              .fontColor('#666666')

            Text('点击下方按钮开始记录您的第一次训练')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .margin({ top: 100 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .layoutWeight(1)
      }

      // 底部添加按钮
      Button('添加训练记录')
        .width('90%')
        .height(48)
        .fontSize(16)
        .backgroundColor('#007AFF')
        .borderRadius(8)
        .margin({ bottom: 16 })
        .onClick(() => {
          toast('添加功能开发中...');
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  RecordCard(record: TrainingRecordModel) {
    Column({ space: 12 }) {
      // 标题和日期
      Row() {
        Column({ space: 4 }) {
          Text(record.title)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          Text(record.date + ' ' + record.startTime)
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 删除按钮
        Button('删除')
          .fontSize(13)
          .height(28)
          .backgroundColor('#FF4444')
          .borderRadius(6)
          .onClick(() => {
            this.showDeleteDialog(record);
          })
      }
      .width('100%')

      // 分割线
      Divider()
        .color('#F0F0F0')

      // 训练数据
      Row({ space: 16 }) {
        this.DataTag('时长', record.duration.toString() + '分钟', '#4CAF50')
        this.DataTag('组数', record.totalSets.toString() + '组', '#FF9800')
        this.DataTag('重量', (record.totalWeight / 1000).toFixed(1) + 'T', '#2196F3')
        this.DataTag('卡路里', record.caloriesBurned.toString(), '#F44336')
      }
      .width('100%')

      // 训练项目
      if (record.exercises.length > 0) {
        Column({ space: 6 }) {
          Text('训练项目:')
            .fontSize(12)
            .fontColor('#666666')

          Column({ space: 4 }) {
            ForEach(record.exercises, (exercise: ExerciseModel, index: number) => {
              Text((index + 1).toString() + '. ' + exercise.name +
                ' (' + exercise.sets.toString() + '组 x ' +
                exercise.reps.toString() + '次 x ' +
                exercise.weight.toString() + 'kg)')
                .fontSize(12)
                .fontColor('#333333')
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 8 })
      }

      // 备注和状态
      if (record.notes.length > 0 || record.mood.length > 0) {
        Row({ space: 8 }) {
          if (record.mood.length > 0) {
            Text('状态: ' + record.mood)
              .fontSize(12)
              .fontColor('#666666')
          }
          if (record.notes.length > 0) {
            Text('|')
              .fontSize(12)
              .fontColor('#CCCCCC')
            Text(record.notes)
              .fontSize(12)
              .fontColor('#666666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DataTag(label: string, value: string, color: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(10)
        .fontColor('#999999')
    }
    .alignItems(HorizontalAlign.Center)
  }
}
