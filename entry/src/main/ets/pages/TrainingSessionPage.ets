/**
 * 训练会话页面 - Training Session
 * 实时记录训练过程，支持计时、动作管理、组记录等功能
 */

import {
  TrainingSessionModel,
  SessionExerciseModel,
  TrainingSetModel,
  TrainingDifficultyConst,
  SetTypeConst,
  toast,
  TrainingApiService,
  TrainingRecordModel,
  ExerciseModel,
  ActionModel,
  ActionDataService
} from '@tbs/common';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

/**
 * 选中动作数据类（与 ActionSelectPage 共享）
 */
class SelectedActionData {
  id: string = '';
  name: string = '';
  muscleGroup: string = '';
  thumbnailUrl: string = '';
}

@Entry
@Component
struct TrainingSessionPage {
  @State session: TrainingSessionModel = new TrainingSessionModel()
  @State currentTime: string = '00:00'
  @State timerInterval: number = -1
  @State pauseStartTime: number = 0
  @State showDifficultyPicker: boolean = false
  @State showNoteDialog: boolean = false
  @State tempNote: string = ''
  @State isSaving: boolean = false

  aboutToAppear(): void {
    this.session.startTime = Date.now();
    this.session.isRunning = true;
    this.session.title = '训练记录';
    this.startTimer();
  }

  /**
   * 页面显示时检查是否有选中的动作
   */
  onPageShow(): void {
    this.checkSelectedActions();
  }

  /**
   * 检查并处理选中的动作
   */
  checkSelectedActions(): void {
    const jsonStr: string | undefined = AppStorage.get<string>('selectedActionsJson');

    if (jsonStr !== undefined && jsonStr.length > 0) {
      try {
        const selectedData: SelectedActionData[] = JSON.parse(jsonStr) as SelectedActionData[];

        if (selectedData.length > 0) {
          let addedCount: number = 0;
          const newExercises: SessionExerciseModel[] = [];

          // 复制现有动作
          for (let k: number = 0; k < this.session.exercises.length; k++) {
            newExercises.push(this.session.exercises[k]);
          }

          for (let i: number = 0; i < selectedData.length; i++) {
            const actionData: SelectedActionData = selectedData[i];
            const actionId: string = actionData.id;
            const actionName: string = actionData.name;
            const muscleGroup: string = actionData.muscleGroup;
            const thumbnailUrl: string = actionData.thumbnailUrl;

            // 检查是否已添加该动作
            let alreadyExists: boolean = false;
            for (let j: number = 0; j < newExercises.length; j++) {
              if (newExercises[j].actionId === actionId) {
                alreadyExists = true;
                break;
              }
            }

            if (!alreadyExists) {
              const newExercise: SessionExerciseModel = new SessionExerciseModel(
                actionId,
                actionName,
                muscleGroup,
                [],
                0,
                4,
                8,
                '',
                thumbnailUrl
              );
              // 添加一个默认的正式组
              newExercise.addSet(SetTypeConst.WORKING, 0, 8);
              newExercises.push(newExercise);
              addedCount++;
            }
          }

          // 清除 AppStorage 中的数据
          AppStorage.delete('selectedActionsJson');

          // 重新赋值 session 触发 UI 更新
          if (addedCount > 0) {
            const updatedSession: TrainingSessionModel = new TrainingSessionModel(
              this.session.title,
              this.session.startTime,
              this.session.pausedTime,
              newExercises,
              this.session.difficulty,
              this.session.notes,
              this.session.isRunning,
              this.session.planId
            );
            this.session = updatedSession;
            toast('已添加 ' + addedCount.toString() + ' 个动作');
          }
        }
      } catch (e) {
        console.error('解析选中动作数据失败');
      }
    }
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  /**
   * 启动计时器
   */
  startTimer(): void {
    this.stopTimer();
    this.timerInterval = setInterval((): void => {
      this.updateTimer();
    }, 1000);
  }

  /**
   * 停止计时器
   */
  stopTimer(): void {
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval);
      this.timerInterval = -1;
    }
  }

  /**
   * 更新计时器显示
   */
  updateTimer(): void {
    const seconds: number = this.session.getDurationInSeconds();
    const minutes: number = Math.floor(seconds / 60);
    const secs: number = seconds % 60;
    const minutesStr: string = minutes < 10 ? '0' + minutes.toString() : minutes.toString();
    const secsStr: string = secs < 10 ? '0' + secs.toString() : secs.toString();
    this.currentTime = minutesStr + ':' + secsStr;
  }

  /**
   * 暂停/继续计时
   */
  toggleTimer(): void {
    if (this.session.isRunning) {
      this.pauseStartTime = Date.now();
      this.session.isRunning = false;
      this.stopTimer();
    } else {
      if (this.pauseStartTime > 0) {
        this.session.pausedTime += Date.now() - this.pauseStartTime;
        this.pauseStartTime = 0;
      }
      this.session.isRunning = true;
      this.startTimer();
    }
  }

  /**
   * 完成训练
   */
  async finishTraining(): Promise<void> {
    if (this.session.exercises.length === 0) {
      toast('请至少添加一个训练动作');
      return;
    }

    if (this.session.getTotalCompletedSets() === 0) {
      toast('请至少完成一组训练');
      return;
    }

    this.showFinishDialog();
  }

  /**
   * 显示完成确认对话框
   */
  showFinishDialog(): void {
    promptAction.showDialog({
      title: '完成训练',
      message: '确定要结束并保存本次训练吗？',
      buttons: [
        {
          text: '取消',
          color: '#666666'
        },
        {
          text: '保存',
          color: '#007AFF'
        }
      ]
    }).then((data: promptAction.ShowDialogSuccessResponse): void => {
      if (data.index === 1) {
        this.saveTraining();
      }
    }).catch((): void => {
      console.error('Dialog error');
    });
  }

  /**
   * 保存训练记录
   */
  async saveTraining(): Promise<void> {
    this.isSaving = true;
    this.stopTimer();

    try {
      const record: TrainingRecordModel = this.convertToTrainingRecord();
      const res: ResponseResult = await TrainingApiService.createTrainingRecord(record);

      if (res.code === 0) {
        toast('训练记录保存成功');
        router.back();
      } else {
        toast(res.message ?? '保存失败');
        this.isSaving = false;
      }
    } catch (err) {
      console.error('保存训练记录失败:', JSON.stringify(err));
      toast('保存失败，请重试');
      this.isSaving = false;
    }
  }

  /**
   * 转换为训练记录模型
   */
  convertToTrainingRecord(): TrainingRecordModel {
    const record: TrainingRecordModel = new TrainingRecordModel();
    record.title = this.session.title;

    const now: Date = new Date();
    const year: number = now.getFullYear();
    const month: number = now.getMonth() + 1;
    const day: number = now.getDate();
    const hours: number = now.getHours();
    const minutes: number = now.getMinutes();

    record.date = year.toString() + '-' +
      (month < 10 ? '0' : '') + month.toString() + '-' +
      (day < 10 ? '0' : '') + day.toString();

    const startDate: Date = new Date(this.session.startTime);
    const startHours: number = startDate.getHours();
    const startMinutes: number = startDate.getMinutes();
    record.startTime = (startHours < 10 ? '0' : '') + startHours.toString() + ':' +
      (startMinutes < 10 ? '0' : '') + startMinutes.toString();

    record.endTime = (hours < 10 ? '0' : '') + hours.toString() + ':' +
      (minutes < 10 ? '0' : '') + minutes.toString();

    record.duration = this.session.getDuration();
    record.notes = this.session.notes;
    record.mood = this.session.difficulty;
    record.planId = this.session.planId;

    const exercises: ExerciseModel[] = [];
    for (let i: number = 0; i < this.session.exercises.length; i++) {
      const sessionEx: SessionExerciseModel = this.session.exercises[i];
      const completedSets: number = sessionEx.getCompletedSetsCount();

      if (completedSets > 0) {
        let totalReps: number = 0;
        let totalWeight: number = 0;

        for (let j: number = 0; j < sessionEx.sets.length; j++) {
          const set: TrainingSetModel = sessionEx.sets[j];
          if (set.isCompleted) {
            totalReps += set.reps;
            totalWeight += set.weight;
          }
        }

        const avgReps: number = Math.floor(totalReps / completedSets);
        const avgWeight: number = Math.floor(totalWeight / completedSets);

        const exercise: ExerciseModel = new ExerciseModel(
          0,
          sessionEx.actionName,
          completedSets,
          avgReps,
          avgWeight,
          0,
          sessionEx.muscleGroup,
          sessionEx.note,
          0
        );
        exercises.push(exercise);
      }
    }

    record.exercises = exercises;
    record.totalSets = this.session.getTotalCompletedSets();
    record.totalWeight = this.session.getTotalVolume();
    record.caloriesBurned = Math.floor(record.totalWeight * 0.1);

    return record;
  }

  /**
   * 添加动作
   */
  addExercise(): void {
    router.pushUrl({
      url: 'pages/ActionSelectPage'
    }).catch((err: Error): void => {
      console.error('跳转失败:', JSON.stringify(err));
    });
  }

  /**
   * 删除动作
   */
  removeExercise(index: number): void {
    promptAction.showDialog({
      title: '删除动作',
      message: '确定要删除这个动作吗？',
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
    }).then((data: promptAction.ShowDialogSuccessResponse): void => {
      if (data.index === 1) {
        this.session.removeExercise(index);
      }
    }).catch((): void => {
      console.error('Dialog error');
    });
  }

  /**
   * 添加训练组
   */
  addSet(exerciseIndex: number): void {
    const exercise: SessionExerciseModel = this.session.exercises[exerciseIndex];
    const lastSet: TrainingSetModel | null = exercise.sets.length > 0 ?
      exercise.sets[exercise.sets.length - 1] : null;

    const weight: number = lastSet !== null ? lastSet.weight : 0;
    const reps: number = lastSet !== null ? lastSet.reps : exercise.targetReps;

    exercise.addSet(SetTypeConst.WORKING, weight, reps);
  }

  /**
   * 删除训练组
   */
  removeSet(exerciseIndex: number, setIndex: number): void {
    this.session.exercises[exerciseIndex].removeSet(setIndex);
  }

  /**
   * 切换组完成状态
   */
  toggleSetComplete(exerciseIndex: number, setIndex: number): void {
    const set: TrainingSetModel = this.session.exercises[exerciseIndex].sets[setIndex];
    set.isCompleted = !set.isCompleted;
  }

  /**
   * 显示主观反馈选择器
   */
  selectDifficulty(difficulty: string): void {
    this.session.difficulty = difficulty;
  }

  /**
   * 显示心得输入对话框
   */
  showNoteInput(): void {
    this.tempNote = this.session.notes;
    this.showNoteDialog = true;
  }

  /**
   * 保存心得
   */
  saveNote(): void {
    this.session.notes = this.tempNote;
    this.showNoteDialog = false;
    toast('心得已保存');
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        this.TopBar()

        Scroll() {
          Column({ space: 16 }) {
            if (this.session.exercises.length === 0) {
              this.EmptyState()
            } else {
              ForEach(this.session.exercises, (exercise: SessionExerciseModel, index: number) => {
                this.ExerciseCard(exercise, index)
              })
            }

            this.FeedbackSection()

            Column().height(100)
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      this.BottomBar()

      if (this.showNoteDialog) {
        this.NoteDialog()
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  TopBar() {
    Column({ space: 8 }) {
      // 状态栏占位
      Column()
        .height(0)
      
      Row() {
        Text('✖')
          .fontSize(20)
          .fontColor('#333333')
          .onClick((): void => {
            router.back();
          })

        TextInput({ text: this.session.title })
          .layoutWeight(1)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Transparent)
          .margin({ left: 12, right: 12 })
          .onChange((value: string): void => {
            this.session.title = value;
          })

        Button('✅ 完成')
          .fontSize(14)
          .height(32)
          .backgroundColor('#4CAF50')
          .borderRadius(6)
          .onClick((): void => {
            this.finishTraining();
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })

      Row() {
        Row({ space: 8 }) {
          Text(this.currentTime)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')

          Text(this.session.isRunning ? '⏸' : '▶')
            .fontSize(18)
            .onClick((): void => {
              this.toggleTimer();
            })
        }

        Text(this.session.getTotalCompletedSets().toString() + '/' +
          this.session.exercises.length.toString() + '组  ' +
          this.session.getCompletedExercisesCount().toString() + '/' +
          this.session.exercises.length.toString() + '动作  ' +
          this.session.getTotalVolume().toString() + 'kg容量')
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({ top: 15, bottom: 12 })
  }

  @Builder
  EmptyState() {
    Column({ space: 16 }) {
      Text('🏋️')
        .fontSize(48)

      Text('还没有添加训练动作')
        .fontSize(16)
        .fontColor('#666666')

      Text('点击下方「➕ 加动作」开始训练')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .margin({ top: 80 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ExerciseCard(exercise: SessionExerciseModel, exerciseIndex: number) {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text(exercise.actionName)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text(exercise.muscleGroup)
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row({ space: 12 }) {
          Text('⚙')
            .fontSize(16)

          Text('✖')
            .fontSize(16)
            .fontColor('#FF4444')
            .onClick((): void => {
              this.removeExercise(exerciseIndex);
            })
        }
      }
      .width('100%')

      Divider().color('#F0F0F0')

      Column({ space: 0 }) {
        Row() {
          Text('组')
            .fontSize(12)
            .fontColor('#666666')
            .width(40)
            .textAlign(TextAlign.Center)

          Text('类型')
            .fontSize(12)
            .fontColor('#666666')
            .width(60)
            .textAlign(TextAlign.Center)

          Text('重量(kg)')
            .fontSize(12)
            .fontColor('#666666')
            .width(80)
            .textAlign(TextAlign.Center)

          Text('次数')
            .fontSize(12)
            .fontColor('#666666')
            .width(60)
            .textAlign(TextAlign.Center)

          Text('✓')
            .fontSize(12)
            .fontColor('#666666')
            .width(40)
            .textAlign(TextAlign.Center)

          Text('...')
            .fontSize(12)
            .fontColor('#666666')
            .width(40)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(32)
        .backgroundColor('#F8F8F8')
        .borderRadius(6)

        ForEach(exercise.sets, (set: TrainingSetModel, setIndex: number) => {
          this.SetRow(set, exerciseIndex, setIndex)
        })
      }
      .width('100%')

      Button('+ 添加组')
        .width('100%')
        .height(36)
        .fontSize(14)
        .backgroundColor('#F0F0F0')
        .fontColor('#007AFF')
        .borderRadius(6)
        .onClick((): void => {
          this.addSet(exerciseIndex);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SetRow(set: TrainingSetModel, exerciseIndex: number, setIndex: number) {
    Row() {
      Text((setIndex + 1).toString())
        .fontSize(14)
        .fontColor('#333333')
        .width(40)
        .textAlign(TextAlign.Center)

      Text(set.setType)
        .fontSize(12)
        .fontColor(set.setType === SetTypeConst.WARMUP ? '#FF9800' :
          set.setType === SetTypeConst.COOLDOWN ? '#4CAF50' : '#2196F3')
        .width(60)
        .textAlign(TextAlign.Center)
        .backgroundColor(set.setType === SetTypeConst.WARMUP ? '#FFF3E0' :
          set.setType === SetTypeConst.COOLDOWN ? '#E8F5E9' : '#E3F2FD')
        .borderRadius(4)
        .padding({ top: 2, bottom: 2 })

      TextInput({ text: set.weight.toString() })
        .width(80)
        .height(32)
        .fontSize(14)
        .type(InputType.Number)
        .textAlign(TextAlign.Center)
        .backgroundColor('#F8F8F8')
        .borderRadius(4)
        .onChange((value: string): void => {
          const weight: number = parseInt(value, 10);
          if (!isNaN(weight)) {
            set.weight = weight;
          }
        })

      TextInput({ text: set.reps.toString() })
        .width(60)
        .height(32)
        .fontSize(14)
        .type(InputType.Number)
        .textAlign(TextAlign.Center)
        .backgroundColor('#F8F8F8')
        .borderRadius(4)
        .onChange((value: string): void => {
          const reps: number = parseInt(value, 10);
          if (!isNaN(reps)) {
            set.reps = reps;
          }
        })

      Text(set.isCompleted ? '✅' : '⭕')
        .fontSize(18)
        .width(40)
        .textAlign(TextAlign.Center)
        .onClick((): void => {
          this.toggleSetComplete(exerciseIndex, setIndex);
        })

      Text('✖')
        .fontSize(14)
        .fontColor('#FF4444')
        .width(40)
        .textAlign(TextAlign.Center)
        .onClick((): void => {
          this.removeSet(exerciseIndex, setIndex);
        })
    }
    .width('100%')
    .height(44)
    .padding({ top: 6, bottom: 6 })
  }

  @Builder
  FeedbackSection() {
    Column({ space: 12 }) {
      Text('训练感受')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')

      Row({ space: 12 }) {
        this.DifficultyButton('简单', '🟢')
        this.DifficultyButton('正常', '🟡')
        this.DifficultyButton('困难', '🔴')
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
  DifficultyButton(difficulty: string, icon: string) {
    Button() {
      Row({ space: 6 }) {
        Text(icon)
          .fontSize(16)

        Text(difficulty)
          .fontSize(14)
          .fontColor(this.session.difficulty === difficulty ? Color.White : '#333333')
      }
    }
    .layoutWeight(1)
    .height(40)
    .backgroundColor(this.session.difficulty === difficulty ? '#007AFF' : '#F0F0F0')
    .borderRadius(8)
    .onClick((): void => {
      this.selectDifficulty(difficulty);
    })
  }

  @Builder
  BottomBar() {
    Row({ space: 12 }) {
      Button('最小化')
        .fontSize(14)
        .height(44)
        .layoutWeight(1)
        .backgroundColor('#E0E0E0')
        .fontColor('#333333')
        .borderRadius(8)
        .onClick((): void => {
          toast('最小化功能开发中...');
        })

      Button('➕ 加动作')
        .fontSize(14)
        .height(44)
        .layoutWeight(1)
        .backgroundColor('#007AFF')
        .borderRadius(8)
        .onClick((): void => {
          this.addExercise();
        })

      Button('✏️ 写心得')
        .fontSize(14)
        .height(44)
        .layoutWeight(1)
        .backgroundColor('#4CAF50')
        .borderRadius(8)
        .onClick((): void => {
          this.showNoteInput();
        })

      Button('⚙️')
        .fontSize(16)
        .width(44)
        .height(44)
        .backgroundColor('#9E9E9E')
        .borderRadius(8)
        .onClick((): void => {
          toast('设置功能开发中...');
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  @Builder
  NoteDialog() {
    Column() {
      Column({ space: 0 }) {
        Text('训练心得')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(16)

        TextArea({ text: this.tempNote })
          .width('100%')
          .height(200)
          .fontSize(14)
          .backgroundColor(Color.White)
          .onChange((value: string): void => {
            this.tempNote = value;
          })

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#E0E0E0')
            .fontColor('#333333')
            .onClick((): void => {
              this.showNoteDialog = false;
            })

          Button('保存')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#007AFF')
            .onClick((): void => {
              this.saveNote();
            })
        }
        .width('100%')
        .padding(16)
      }
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      this.showNoteDialog = false;
    })
  }
}
