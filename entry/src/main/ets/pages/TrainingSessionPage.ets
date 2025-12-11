/**
 * 训练会话页面 - Training Session
 * 实时记录训练过程，支持计时、动作管理、组记录等功能
 * 使用 NavDestination 作为 Navigation 子页面
 */

import {
  TrainingSessionModel,
  SessionExerciseModel,
  TrainingSetModel,
  SetTypeConst,
  toast,
  TrainingApiService,
  TrainingRecordModel,
  ExerciseModel,
  NavRouteParams,
  NavRoutes
} from '@tbs/common';
import { promptAction } from '@kit.ArkUI';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';
import {
  SessionExerciseCard,
  SetTypeSelectDialog,
  TrainingFeedbackSection,
  TrainingTopBar,
  TrainingTopBarParams,
  TrainingTopBarCallbacks,
  TrainingBottomBar,
  NoteDialog,
  TimeEditDialog,
  TrainingEmptyState
} from './training/index';

/**
 * 选中动作数据类（与 ActionSelectPage 共享）
 */
class SelectedActionData {
  id: string = '';
  name: string = '';
  muscleGroup: string = '';
  thumbnailUrl: string = '';
}

/**
 * 系统路由表构建函数
 */
@Builder
export function TrainingSessionPageBuilder(): void {
  TrainingSessionPage()
}

@Component
export struct TrainingSessionPage {
  @State session: TrainingSessionModel = new TrainingSessionModel()
  @State currentTime: string = '00:00'
  @State timerInterval: number = -1
  @State pauseStartTime: number = 0
  @State showNoteDialog: boolean = false
  @State tempNote: string = ''
  @State isSaving: boolean = false
  @State showSetTypeMenu: boolean = false
  @State currentEditExerciseIndex: number = -1
  @State currentEditSetIndex: number = -1
  @State isLoadingRecord: boolean = false
  @State existingRecordId: string = ''
  @State selectedDate: string = '' // 用户选择的训练日期（从日历传入，格式 YYYY-MM-DD）
  @State showTimeEditDialog: boolean = false
  @State editHours: string = '0'
  @State editMinutes: string = '0'
  @State editSeconds: string = '0'
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  /**
   * 初始化新训练会话
   */
  initNewSession(): void {
    // 计算开始时间：如果有选中日期，使用选中日期 + 当前时分秒
    this.session.startTime = this.calculateStartTime();
    this.session.isRunning = true;
    this.session.title = '训练记录';
    this.startTimer();
  }

  /**
   * 加载复制的动作（复制到今天）
   */
  loadCopiedActions(): void {
    const jsonStr: string | undefined = AppStorage.get<string>('copyRecordActionsJson');
    if (jsonStr !== undefined && jsonStr.length > 0) {
      try {
        const actionsData: Object[] = JSON.parse(jsonStr) as Object[];
        const exercises: SessionExerciseModel[] = [];

        for (let i: number = 0; i < actionsData.length; i++) {
          const actionObj: Record<string, Object> = actionsData[i] as Record<string, Object>;
          const sessionEx: SessionExerciseModel = new SessionExerciseModel(
            actionObj['id'] as string ?? '',
            actionObj['name'] as string ?? '',
            actionObj['muscleGroup'] as string ?? '',
            [],
            0,
            actionObj['sets'] as number ?? 4,
            actionObj['reps'] as number ?? 8,
            '',
            ''
          );

          // 添加默认训练组
          const sets: number = actionObj['sets'] as number ?? 1;
          const reps: number = actionObj['reps'] as number ?? 8;
          const weight: number = actionObj['weight'] as number ?? 0;
          for (let s: number = 0; s < sets; s++) {
            sessionEx.addSet(SetTypeConst.WORKING, weight, reps);
          }

          exercises.push(sessionEx);
        }

        AppStorage.delete('copyRecordActionsJson');

        this.session = new TrainingSessionModel(
          '训练记录',
          Date.now(),
          0,
          exercises,
          '',
          '',
          true,
          0
        );

        this.startTimer();
        toast('已加载 ' + exercises.length.toString() + ' 个动作');
      } catch (e) {
        console.error('解析复制动作数据失败');
        this.initNewSession();
      }
    } else {
      this.initNewSession();
    }
  }

  /**
   * 加载已有的训练记录（继续训练）
   */
  async loadExistingRecord(recordId: string): Promise<void> {
    this.isLoadingRecord = true;
    try {
      const res: ResponseResult = await TrainingApiService.getTrainingRecord(recordId);
      if (res.code === 0 && res.data) {
        const record: TrainingRecordModel = res.data as TrainingRecordModel;
        this.convertRecordToSession(record);
        toast('已加载训练记录，可以继续训练');
      } else {
        toast(res.message ?? '加载训练记录失败');
        // 加载失败则作为新训练
        this.initNewSession();
      }
    } catch (err) {
      console.error('加载训练记录失败:', JSON.stringify(err));
      toast('加载失败，开始新训练');
      this.initNewSession();
    } finally {
      this.isLoadingRecord = false;
    }
  }

  /**
   * 将训练记录转换为训练会话
   */
  convertRecordToSession(record: TrainingRecordModel): void {
    const exercises: SessionExerciseModel[] = [];

    // 将 ExerciseModel 转换为 SessionExerciseModel
    for (let i: number = 0; i < record.exercises.length; i++) {
      const ex: ExerciseModel = record.exercises[i];
      const sessionEx: SessionExerciseModel = new SessionExerciseModel(
        ex.id.toString(),
        ex.name,
        ex.muscleGroup,
        [],
        0,
        ex.sets,
        ex.reps,
        ex.notes,
        ''
      );

      // 根据记录的组数创建训练组（已完成状态）
      for (let s: number = 0; s < ex.sets; s++) {
        const set: TrainingSetModel = new TrainingSetModel(
          SetTypeConst.WORKING,
          ex.weight,
          ex.reps,
          true, // 已完成
          ''
        );
        sessionEx.sets.push(set);
      }

      exercises.push(sessionEx);
    }

    // 计算原来的训练时长（毫秒），继续训练时从原来的时长开始
    const previousDurationMs: number = record.duration * 60 * 1000;
    const adjustedStartTime: number = Date.now() - previousDurationMs;

    // 创建会话
    this.session = new TrainingSessionModel(
      record.title,
      adjustedStartTime, // 调整开始时间，使时长显示从原来的时长开始
      0,
      exercises,
      record.mood,
      record.notes,
      true,
      record.planId
    );

    this.startTimer();
  }

  /**
   * 计算开始时间
   * 如果用户从日历选择了日期，则使用选中日期 + 当前时分秒
   * 否则使用当前完整时间
   */
  calculateStartTime(): number {
    const now: Date = new Date();

    if (this.selectedDate.length > 0) {
      // 解析选中的日期 (格式: YYYY-MM-DD)
      const parts: string[] = this.selectedDate.split('-');
      if (parts.length === 3) {
        const year: number = parseInt(parts[0]) || now.getFullYear();
        const month: number = (parseInt(parts[1]) || 1) - 1; // Date 月份从0开始
        const day: number = parseInt(parts[2]) || 1;

        // 使用选中日期 + 当前时分秒
        const selectedDateTime: Date = new Date(
          year,
          month,
          day,
          now.getHours(),
          now.getMinutes(),
          now.getSeconds()
        );
        return selectedDateTime.getTime();
      }
    }

    // 没有选中日期，使用当前时间
    return now.getTime();
  }

  onPageShow(): void {
    this.checkSelectedActions();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  // ==================== 计时器相关 ====================

  startTimer(): void {
    this.stopTimer();
    this.timerInterval = setInterval((): void => {
      this.updateTimer();
    }, 1000);
  }

  stopTimer(): void {
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval);
      this.timerInterval = -1;
    }
  }

  updateTimer(): void {
    const totalSeconds: number = this.session.getDurationInSeconds();
    const hours: number = Math.floor(totalSeconds / 3600);
    const minutes: number = Math.floor((totalSeconds % 3600) / 60);
    const secs: number = totalSeconds % 60;

    const hoursStr: string = hours < 10 ? '0' + hours.toString() : hours.toString();
    const minutesStr: string = minutes < 10 ? '0' + minutes.toString() : minutes.toString();
    const secsStr: string = secs < 10 ? '0' + secs.toString() : secs.toString();

    // 如果有小时则显示 HH:MM:SS，否则显示 MM:SS
    if (hours > 0) {
      this.currentTime = hoursStr + ':' + minutesStr + ':' + secsStr;
    } else {
      this.currentTime = minutesStr + ':' + secsStr;
    }
  }

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

  // ==================== 动作管理 ====================

  checkSelectedActions(): void {
    const jsonStr: string | undefined = AppStorage.get<string>('selectedActionsJson');

    if (jsonStr !== undefined && jsonStr.length > 0) {
      try {
        const selectedData: SelectedActionData[] = JSON.parse(jsonStr) as SelectedActionData[];

        if (selectedData.length > 0) {
          let addedCount: number = 0;
          const newExercises: SessionExerciseModel[] = [];

          for (let k: number = 0; k < this.session.exercises.length; k++) {
            newExercises.push(this.session.exercises[k]);
          }

          for (let i: number = 0; i < selectedData.length; i++) {
            const actionData: SelectedActionData = selectedData[i];

            let alreadyExists: boolean = false;
            for (let j: number = 0; j < newExercises.length; j++) {
              if (newExercises[j].actionId === actionData.id) {
                alreadyExists = true;
                break;
              }
            }

            if (!alreadyExists) {
              const newExercise: SessionExerciseModel = new SessionExerciseModel(
                actionData.id, actionData.name, actionData.muscleGroup,
                [], 0, 4, 8, '', actionData.thumbnailUrl
              );
              newExercise.addSet(SetTypeConst.WORKING, 0, 8);
              newExercises.push(newExercise);
              addedCount++;
            }
          }

          AppStorage.delete('selectedActionsJson');

          if (addedCount > 0) {
            this.session = new TrainingSessionModel(
              this.session.title, this.session.startTime, this.session.pausedTime,
              newExercises, this.session.mood, this.session.notes,
              this.session.isRunning, this.session.planId
            );
            toast('已添加 ' + addedCount.toString() + ' 个动作');
          }
        }
      } catch (e) {
        console.error('解析选中动作数据失败');
      }
    }
  }

  addExercise(): void {
    this.pathStack.pushPathByName(NavRoutes.ACTION_SELECT, undefined);
  }

  removeExercise(index: number): void {
    promptAction.showDialog({
      title: '删除动作',
      message: '确定要删除这个动作吗？',
      buttons: [{ text: '取消', color: '#646A73' }, { text: '删除', color: '#F54A45' }]
    }).then((data: promptAction.ShowDialogSuccessResponse): void => {
      if (data.index === 1) {
        this.session.removeExercise(index);
        this.refreshSession();
      }
    }).catch((): void => {});
  }

  // ==================== 训练组管理 ====================

  addSet(exerciseIndex: number): void {
    const exercise: SessionExerciseModel = this.session.exercises[exerciseIndex];
    const lastSet: TrainingSetModel | null = exercise.sets.length > 0 ?
      exercise.sets[exercise.sets.length - 1] : null;
    const weight: number = lastSet !== null ? lastSet.weight : 0;
    const reps: number = lastSet !== null ? lastSet.reps : exercise.targetReps;
    exercise.addSet(SetTypeConst.WORKING, weight, reps);
    this.refreshSession();
  }

  removeSet(exerciseIndex: number, setIndex: number): void {
    this.session.exercises[exerciseIndex].removeSet(setIndex);
    this.refreshSession();
  }

  toggleSetComplete(exerciseIndex: number, setIndex: number): void {
    const set: TrainingSetModel = this.session.exercises[exerciseIndex].sets[setIndex];
    set.isCompleted = !set.isCompleted;
    this.refreshSession();
  }

  showSetTypeSelector(exerciseIndex: number, setIndex: number): void {
    this.currentEditExerciseIndex = exerciseIndex;
    this.currentEditSetIndex = setIndex;
    this.showSetTypeMenu = true;
  }

  changeSetType(newType: string): void {
    if (this.currentEditExerciseIndex >= 0 && this.currentEditSetIndex >= 0) {
      const set: TrainingSetModel = this.session.exercises[this.currentEditExerciseIndex].sets[this.currentEditSetIndex];
      set.setType = newType;
    }
    this.showSetTypeMenu = false;
    this.currentEditExerciseIndex = -1;
    this.currentEditSetIndex = -1;
    this.refreshSession();
  }

  // ==================== 保存训练 ====================

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

  showFinishDialog(): void {
    promptAction.showDialog({
      title: '完成训练',
      message: '确定要结束并保存本次训练吗？',
      buttons: [{ text: '取消', color: '#646A73' }, { text: '保存', color: '#3370FF' }]
    }).then((data: promptAction.ShowDialogSuccessResponse): void => {
      if (data.index === 1) {
        this.saveTraining();
      }
    }).catch((): void => {});
  }

  async saveTraining(): Promise<void> {
    this.isSaving = true;
    this.stopTimer();
    try {
      const record: TrainingRecordModel = this.convertToTrainingRecord();
      let res: ResponseResult;

      if (this.existingRecordId.length > 0) {
        // 继续训练 - 更新已有记录
        res = await TrainingApiService.updateTrainingRecord(this.existingRecordId, record);
      } else {
        // 新训练 - 创建新记录
        res = await TrainingApiService.createTrainingRecord(record);
      }

      if (res.code === 0) {
        toast(this.existingRecordId.length > 0 ? '训练记录更新成功' : '训练记录保存成功');
        // 设置刷新标志，通知 RecordPage 刷新数据
        AppStorage.setOrCreate<boolean>('needRefreshRecordPage', true);
        this.pathStack.pop();
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

  convertToTrainingRecord(): TrainingRecordModel {
    const record: TrainingRecordModel = new TrainingRecordModel();
    record.title = this.session.title;

    // 开始时间（从 session.startTime 获取，包含用户选择的日期）
    const startDate: Date = new Date(this.session.startTime);
    // 结束时间（当前时间）
    const endDate: Date = new Date();

    // 从开始时间提取训练日期 (YYYY-MM-DD)
    record.date = startDate.getFullYear().toString() + '-' +
      (startDate.getMonth() + 1 < 10 ? '0' : '') + (startDate.getMonth() + 1).toString() + '-' +
      (startDate.getDate() < 10 ? '0' : '') + startDate.getDate().toString();

    // 开始时间完整格式 (YYYY-MM-DD HH:mm:ss)
    record.startTime = this.formatDateTime(startDate);
    // 结束时间完整格式 (YYYY-MM-DD HH:mm:ss)
    record.endTime = this.formatDateTime(endDate);

    record.duration = this.session.getDuration();
    record.notes = this.session.notes;
    record.mood = this.session.mood;
    record.planId = this.session.planId;

    const exercises: ExerciseModel[] = [];
    for (let i: number = 0; i < this.session.exercises.length; i++) {
      const sessionEx: SessionExerciseModel = this.session.exercises[i];
      const completedSets: number = sessionEx.getCompletedSetsCount();

      if (completedSets > 0) {
        let totalReps: number = 0;
        let totalWeight: number = 0;
        for (let j: number = 0; j < sessionEx.sets.length; j++) {
          if (sessionEx.sets[j].isCompleted) {
            totalReps += sessionEx.sets[j].reps;
            totalWeight += sessionEx.sets[j].weight;
          }
        }
        exercises.push(new ExerciseModel(
          0, sessionEx.actionName, completedSets,
          Math.floor(totalReps / completedSets), Math.floor(totalWeight / completedSets),
          0, sessionEx.muscleGroup, sessionEx.note, 0
        ));
      }
    }

    record.exercises = exercises;
    record.totalSets = this.session.getTotalCompletedSets();
    record.totalWeight = this.session.getTotalVolume();
    record.caloriesBurned = Math.floor(record.totalWeight * 0.1);
    return record;
  }

  // ==================== 辅助方法 ====================

  /**
   * 格式化日期时间为 YYYY-MM-DD HH:mm:ss 格式
   */
  formatDateTime(date: Date): string {
    const year: string = date.getFullYear().toString();
    const month: string = (date.getMonth() + 1 < 10 ? '0' : '') + (date.getMonth() + 1).toString();
    const day: string = (date.getDate() < 10 ? '0' : '') + date.getDate().toString();
    const hours: string = (date.getHours() < 10 ? '0' : '') + date.getHours().toString();
    const minutes: string = (date.getMinutes() < 10 ? '0' : '') + date.getMinutes().toString();
    const seconds: string = (date.getSeconds() < 10 ? '0' : '') + date.getSeconds().toString();
    return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
  }

  refreshSession(): void {
    this.session = new TrainingSessionModel(
      this.session.title, this.session.startTime, this.session.pausedTime,
      this.session.exercises, this.session.mood, this.session.notes,
      this.session.isRunning, this.session.planId
    );
  }

  selectMood(mood: string): void {
    this.session.mood = mood;
  }

  showNoteInput(): void {
    this.tempNote = this.session.notes;
    this.showNoteDialog = true;
  }

  saveNote(): void {
    this.session.notes = this.tempNote;
    this.showNoteDialog = false;
    toast('心得已保存');
  }

  getCurrentSetType(): string {
    if (this.currentEditExerciseIndex >= 0 && this.currentEditSetIndex >= 0) {
      return this.session.exercises[this.currentEditExerciseIndex].sets[this.currentEditSetIndex].setType;
    }
    return SetTypeConst.WORKING;
  }

  // ==================== 时间编辑相关 ====================

  /**
   * 打开时间编辑对话框
   */
  openTimeEditDialog(): void {
    const totalSeconds: number = this.session.getDurationInSeconds();
    const hours: number = Math.floor(totalSeconds / 3600);
    const minutes: number = Math.floor((totalSeconds % 3600) / 60);
    const secs: number = totalSeconds % 60;
    this.editHours = hours.toString();
    this.editMinutes = minutes.toString();
    this.editSeconds = secs.toString();
    this.showTimeEditDialog = true;
  }

  /**
   * 保存编辑的时间
   */
  saveEditedTime(): void {
    const hours: number = parseInt(this.editHours) || 0;
    const minutes: number = parseInt(this.editMinutes) || 0;
    const seconds: number = parseInt(this.editSeconds) || 0;
    const totalSeconds: number = hours * 3600 + minutes * 60 + seconds;
    const totalMs: number = totalSeconds * 1000;

    // 调整 startTime 使得显示的时间为用户输入的值
    this.session.startTime = Date.now() - totalMs - this.session.pausedTime;
    this.showTimeEditDialog = false;
    this.updateTimer();
    toast('时间已更新');
  }

  /**
   * 重置时间为0
   */
  resetTimer(): void {
    promptAction.showDialog({
      title: '重置时间',
      message: '确定要将训练时间重置为 00:00:00 吗？',
      buttons: [{ text: '取消', color: '#646A73' }, { text: '重置', color: '#F54A45' }]
    }).then((data: promptAction.ShowDialogSuccessResponse): void => {
      if (data.index === 1) {
        this.session.startTime = Date.now();
        this.session.pausedTime = 0;
        this.pauseStartTime = 0;
        this.updateTimer();
        toast('时间已重置');
      }
    }).catch((): void => {});
  }

  // ==================== 顶部栏回调 ====================

  private getTopBarCallbacks(): TrainingTopBarCallbacks {
    const callbacks: TrainingTopBarCallbacks = {
      onClose: (): void => { this.pathStack.pop(); },
      onTitleChange: (value: string): void => { this.session.title = value; },
      onFinish: (): void => { this.finishTraining(); },
      onTimeClick: (): void => { this.openTimeEditDialog(); },
      onToggleTimer: (): void => { this.toggleTimer(); },
      onResetTimer: (): void => { this.resetTimer(); }
    };
    return callbacks;
  }

  private getTopBarParams(): TrainingTopBarParams {
    const params: TrainingTopBarParams = {
      title: this.session.title,
      currentTime: this.currentTime,
      isRunning: this.session.isRunning,
      totalSets: this.session.getTotalCompletedSets(),
      completedExercises: this.session.getCompletedExercisesCount(),
      totalVolume: this.session.getTotalVolume(),
      topRectHeight: this.topRectHeight
    };
    return params;
  }

  // ==================== UI 构建 ====================

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          TrainingTopBar({
            params: this.getTopBarParams(),
            callbacks: this.getTopBarCallbacks()
          })

          if (this.isLoadingRecord) {
            // 加载训练记录中
            Column({ space: 16 }) {
              LoadingProgress()
                .width(48)
                .height(48)
                .color($r('app.color.brand_primary'))
              Text('加载训练记录中...')
                .fontSize(14)
                .fontColor($r('app.color.text_hint'))
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            Scroll() {
              Column({ space: 16 }) {
                if (this.session.exercises.length === 0) {
                  TrainingEmptyState()
                } else {
                  ForEach(this.session.exercises, (exercise: SessionExerciseModel, index: number) => {
                    SessionExerciseCard({
                      exercise: exercise,
                      exerciseIndex: index,
                      onRemoveExercise: (idx: number): void => { this.removeExercise(idx); },
                      onAddSet: (idx: number): void => { this.addSet(idx); },
                      onToggleSetComplete: (eIdx: number, sIdx: number): void => { this.toggleSetComplete(eIdx, sIdx); },
                      onRemoveSet: (eIdx: number, sIdx: number): void => { this.removeSet(eIdx, sIdx); },
                      onShowSetTypeSelector: (eIdx: number, sIdx: number): void => { this.showSetTypeSelector(eIdx, sIdx); }
                    })
                  })
                }

                TrainingFeedbackSection({
                  selectedMood: this.session.mood,
                  onSelect: (m: string): void => { this.selectMood(m); }
                })

                Column().height(100)
              }
              .width('100%')
              .padding(16)
            }
            .layoutWeight(1)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.page_background'))

        TrainingBottomBar({
          bottomRectHeight: this.bottomRectHeight,
          onAddExercise: (): void => { this.addExercise(); },
          onShowNote: (): void => { this.showNoteInput(); }
        })

        if (this.showNoteDialog) {
          NoteDialog({
            tempNote: this.tempNote,
            onSave: (): void => { this.saveNote(); },
            onCancel: (): void => { this.showNoteDialog = false; }
          })
        }

        if (this.showSetTypeMenu) {
          SetTypeSelectDialog({
            currentSetType: this.getCurrentSetType(),
            onSelect: (setType: string): void => { this.changeSetType(setType); },
            onCancel: (): void => {
              this.showSetTypeMenu = false;
              this.currentEditExerciseIndex = -1;
              this.currentEditSetIndex = -1;
            }
          })
        }

        if (this.showTimeEditDialog) {
          TimeEditDialog({
            editHours: this.editHours,
            editMinutes: this.editMinutes,
            editSeconds: this.editSeconds,
            onSave: (): void => { this.saveEditedTime(); },
            onCancel: (): void => { this.showTimeEditDialog = false; }
          })
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      // 获取路由参数
      const params: NavRouteParams | undefined = context.pathInfo.param as NavRouteParams | undefined
      if (params !== undefined) {
        // 检查继续训练
        if (params.recordId !== undefined && params.recordId.length > 0) {
          this.existingRecordId = params.recordId
          this.loadExistingRecord(params.recordId)
          return
        }

        // 检查复制到今天
        if (params.copyFromRecord === true) {
          this.loadCopiedActions()
          return
        }

        // 检查选中的日期（从日历进入）
        if (params.selectedDate !== undefined && params.selectedDate.length > 0) {
          this.selectedDate = params.selectedDate
        }
      }

      // 新训练
      this.initNewSession()
    })
    .onShown(() => {
      this.checkSelectedActions()
    })
  }
}
