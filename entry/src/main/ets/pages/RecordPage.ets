/**
 * 训练记录页面 - Record
 * 日历视图显示历史训练记录，支持年月切换，点击查看详情
 */

import { TrainingRecordModel, TrainingApiService, toast, ExerciseModel } from '@tbs/common';
import { promptAction, router } from '@kit.ArkUI';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

/**
 * 日历格子数据模型
 */
class CalendarDayModel {
  day: number = 0                               // 日期（0表示空格子）
  isCurrentMonth: boolean = false               // 是否为当前显示月份
  isToday: boolean = false                      // 是否为今天
  dateStr: string = ''                          // 日期字符串（YYYY-MM-DD）
  records: TrainingRecordModel[] = []           // 当天的训练记录

  constructor(day: number, isCurrentMonth: boolean, isToday: boolean, dateStr: string) {
    this.day = day;
    this.isCurrentMonth = isCurrentMonth;
    this.isToday = isToday;
    this.dateStr = dateStr;
  }
}

/**
 * 复制动作数据模型
 */
class CopyActionData {
  id: string = '';
  name: string = '';
  muscleGroup: string = '';
  thumbnailUrl: string = '';
  sets: number = 0;
  reps: number = 0;
  weight: number = 0;

  constructor(id: string, name: string, muscleGroup: string, sets: number, reps: number, weight: number) {
    this.id = id;
    this.name = name;
    this.muscleGroup = muscleGroup;
    this.thumbnailUrl = '';
    this.sets = sets;
    this.reps = reps;
    this.weight = weight;
  }
}

@Component
export struct RecordPage {
  @State records: TrainingRecordModel[] = []
  @State isLoading: boolean = false
  @State currentYear: number = new Date().getFullYear()
  @State currentMonth: number = new Date().getMonth() + 1
  @State calendarDays: CalendarDayModel[] = []
  @State selectedDay: CalendarDayModel | null = null
  @State selectedDayRecords: TrainingRecordModel[] = []
  @State showDetailDialog: boolean = false
  @State currentRecordIndex: number = 0
  @Prop @Watch('onCurrentTabChange') currentTabIndex: number = 1
  @StorageProp('needRefreshRecordPage') @Watch('onNeedRefreshChange') needRefresh: boolean = false

  // Swiper控制器
  private swiperController: SwiperController = new SwiperController()
  // 星期标题
  private weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六']

  aboutToAppear(): void {
    console.log('[RecordPage] aboutToAppear called');
    this.generateCalendarDays();
    this.loadMonthRecords();
  }

  onCurrentTabChange(): void {
    console.log('[RecordPage] onCurrentTabChange - currentTabIndex:', this.currentTabIndex);
    if (this.currentTabIndex === 1) {
      this.loadMonthRecords();
    }
  }

  /**
   * 监听刷新标志变化，当从训练页面返回时刷新数据
   */
  onNeedRefreshChange(): void {
    console.log('[RecordPage] onNeedRefreshChange - needRefresh:', this.needRefresh);
    if (this.needRefresh) {
      // 清除刷新标志
      AppStorage.setOrCreate<boolean>('needRefreshRecordPage', false);
      // 刷新当月记录
      this.loadMonthRecords();
    }
  }

  /**
   * 生成日历格子数据
   */
  generateCalendarDays(): void {
    const days: CalendarDayModel[] = [];
    const today: Date = new Date();
    const todayYear: number = today.getFullYear();
    const todayMonth: number = today.getMonth() + 1;
    const todayDay: number = today.getDate();

    // 当月第一天是星期几
    const firstDay: Date = new Date(this.currentYear, this.currentMonth - 1, 1);
    const firstDayWeek: number = firstDay.getDay();

    // 当月天数
    const daysInMonth: number = new Date(this.currentYear, this.currentMonth, 0).getDate();

    // 上月天数（用于填充前面的空格）
    const daysInPrevMonth: number = new Date(this.currentYear, this.currentMonth - 1, 0).getDate();

    // 填充上月的日期
    for (let i: number = firstDayWeek - 1; i >= 0; i--) {
      const prevDay: number = daysInPrevMonth - i;
      const prevMonth: number = this.currentMonth === 1 ? 12 : this.currentMonth - 1;
      const prevYear: number = this.currentMonth === 1 ? this.currentYear - 1 : this.currentYear;
      const dateStr: string = `${prevYear}-${prevMonth.toString().padStart(2, '0')}-${prevDay.toString().padStart(2, '0')}`;
      days.push(new CalendarDayModel(prevDay, false, false, dateStr));
    }

    // 填充当月的日期
    for (let d: number = 1; d <= daysInMonth; d++) {
      const dateStr: string = `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}-${d.toString().padStart(2, '0')}`;
      const isToday: boolean = todayYear === this.currentYear && todayMonth === this.currentMonth && todayDay === d;
      days.push(new CalendarDayModel(d, true, isToday, dateStr));
    }

    // 填充下月的日期（确保总共有6行）
    const totalCells: number = 42; // 6行 x 7列
    let nextDay: number = 1;
    while (days.length < totalCells) {
      const nextMonth: number = this.currentMonth === 12 ? 1 : this.currentMonth + 1;
      const nextYear: number = this.currentMonth === 12 ? this.currentYear + 1 : this.currentYear;
      const dateStr: string = `${nextYear}-${nextMonth.toString().padStart(2, '0')}-${nextDay.toString().padStart(2, '0')}`;
      days.push(new CalendarDayModel(nextDay, false, false, dateStr));
      nextDay++;
    }

    this.calendarDays = days;
  }

  /**
   * 加载当月训练记录
   */
  async loadMonthRecords(): Promise<void> {
    this.isLoading = true;
    try {
      const startDate: string = `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}-01`;
      const daysInMonth: number = new Date(this.currentYear, this.currentMonth, 0).getDate();
      const endDate: string = `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}-${daysInMonth.toString().padStart(2, '0')}`;

      console.log('[RecordPage] Loading records from', startDate, 'to', endDate);

      const res: ResponseResult = await TrainingApiService.getTrainingRecords(1, 100, startDate, endDate);
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const recordsArray: Object = apiData['records'] ?? [];
        this.records = recordsArray as TrainingRecordModel[];
        console.log('[RecordPage] Loaded', this.records.length, 'records');
        this.mapRecordsToCalendar();
      } else {
        toast(res.message ?? '加载失败');
      }
    } catch (err) {
      console.error('[RecordPage] 加载训练记录失败:', JSON.stringify(err));
      toast('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 将训练记录映射到日历格子
   */
  mapRecordsToCalendar(): void {
    // 清空之前的记录
    for (let i: number = 0; i < this.calendarDays.length; i++) {
      this.calendarDays[i].records = [];
    }

    // 映射记录到对应日期
    for (let r: number = 0; r < this.records.length; r++) {
      const record: TrainingRecordModel = this.records[r];
      for (let d: number = 0; d < this.calendarDays.length; d++) {
        if (this.calendarDays[d].dateStr === record.date) {
          this.calendarDays[d].records.push(record);
          break;
        }
      }
    }

    // 触发刷新
    this.calendarDays = [...this.calendarDays];
  }

  /**
   * 切换到上个月
   */
  goToPrevMonth(): void {
    if (this.currentMonth === 1) {
      this.currentMonth = 12;
      this.currentYear--;
    } else {
      this.currentMonth--;
    }
    this.generateCalendarDays();
    this.loadMonthRecords();
  }

  /**
   * 切换到下个月
   */
  goToNextMonth(): void {
    if (this.currentMonth === 12) {
      this.currentMonth = 1;
      this.currentYear++;
    } else {
      this.currentMonth++;
    }
    this.generateCalendarDays();
    this.loadMonthRecords();
  }

  /**
   * 回到今天
   */
  goToToday(): void {
    const today: Date = new Date();
    this.currentYear = today.getFullYear();
    this.currentMonth = today.getMonth() + 1;
    this.generateCalendarDays();
    this.loadMonthRecords();
  }

  /**
   * 点击日期
   */
  onDayClick(day: CalendarDayModel): void {
    this.selectedDay = day;
    // 复制记录到独立数组
    this.selectedDayRecords = [...day.records];
    this.currentRecordIndex = 0;

    if (day.records.length > 0) {
      this.showDetailDialog = true;
    } else {
      // 无训练记录，显示提示
      promptAction.showDialog({
        title: day.dateStr,
        message: '今天还没有训练安排哦，快去训练吧~',
        buttons: [
          { text: '取消', color: '#666666' },
          { text: '开始训练', color: '#007AFF' }
        ]
      }).then((result: promptAction.ShowDialogSuccessResponse) => {
        if (result.index === 1) {
          // 传递选中的日期，用于设置训练的开始时间
          router.pushUrl({
            url: 'pages/TrainingSessionPage',
            params: { selectedDate: day.dateStr }
          });
        }
      }).catch((err: Error) => {
        console.error('Dialog error:', JSON.stringify(err));
      });
    }
  }

  /**
   * 获取训练名称缩写
   */
  getTrainingAbbr(record: TrainingRecordModel): string {
    const title: string = record.title;
    if (title.length <= 2) {
      return title;
    }
    // 取前2个字符
    return title.substring(0, 2);
  }

  /**
   * 获取训练容量（总组数或总重量的简写）
   */
  getTrainingVolume(record: TrainingRecordModel): string {
    if (record.totalWeight > 0) {
      if (record.totalWeight >= 1000) {
        return (record.totalWeight / 1000).toFixed(1) + 'T';
      }
      return record.totalWeight.toString() + 'kg';
    }
    return record.totalSets.toString() + '组';
  }

  /**
   * 删除训练记录
   */
  async deleteRecord(recordId: string): Promise<void> {
    try {
      const res: ResponseResult = await TrainingApiService.deleteTrainingRecord(recordId);
      if (res.code === 0) {
        toast('删除成功');
        this.showDetailDialog = false;
        this.loadMonthRecords();
      } else {
        toast(res.message ?? '删除失败');
      }
    } catch (err) {
      console.error('删除训练记录失败:', JSON.stringify(err));
      toast('删除失败，请重试');
    }
  }

  /**
   * 复制到今天 - 将记录中的动作添加到今天的训练
   */
  copyToToday(record: TrainingRecordModel): void {
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
    router.pushUrl({
      url: 'pages/TrainingSessionPage',
      params: { copyFromRecord: true }
    });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 主内容
      Column() {
        // 年月选择器
        this.MonthSelector()

        // 日历视图
        if (this.isLoading) {
          Column({ space: 16 }) {
            LoadingProgress()
              .width(40)
              .height(40)
              .color('#007AFF')
            Text('加载中...')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Scroll() {
            Column() {
              // 星期标题行
              this.WeekHeader()

              // 日历格子
              this.CalendarGrid()
            }
            .width('100%')
            .padding({ left: 8, right: 8, bottom: 16 })
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 训练详情弹窗
      if (this.showDetailDialog && this.selectedDay !== null) {
        this.RecordDetailSheet()
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  MonthSelector() {
    Row() {
      // 上月按钮
      Text('<')
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.goToPrevMonth();
        })

      // 年月显示
      Row({ space: 4 }) {
        Text(this.currentYear.toString() + '年' + this.currentMonth.toString() + '月')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.goToToday();
      })

      // 下月按钮
      Text('>')
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.goToNextMonth();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
    .backgroundColor(Color.White)
  }

  @Builder
  WeekHeader() {
    Row() {
      ForEach(this.weekDays, (day: string, index: number) => {
        Text(day)
          .fontSize(13)
          .fontColor(index === 0 || index === 6 ? '#F44336' : '#666666')
          .width('14.28%')
          .textAlign(TextAlign.Center)
          .padding({ top: 12, bottom: 8 })
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  CalendarGrid() {
    Column() {
      // 6行日历格子
      ForEach([0, 1, 2, 3, 4, 5], (rowIndex: number) => {
        Row() {
          ForEach([0, 1, 2, 3, 4, 5, 6], (colIndex: number) => {
            this.DayCell(this.calendarDays[rowIndex * 7 + colIndex])
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  DayCell(day: CalendarDayModel) {
    Column({ space: 2 }) {
      // 日期数字
      Text(day.day.toString())
        .fontSize(14)
        .fontColor(day.isCurrentMonth ? (day.isToday ? Color.White : '#333333') : '#CCCCCC')
        .fontWeight(day.isToday ? FontWeight.Medium : FontWeight.Normal)
        .width(28)
        .height(28)
        .textAlign(TextAlign.Center)
        .borderRadius(14)
        .backgroundColor(day.isToday ? '#007AFF' : Color.Transparent)

      // 训练信息
      if (day.records.length > 0 && day.isCurrentMonth) {
        Column({ space: 1 }) {
          ForEach(day.records.slice(0, 2), (record: TrainingRecordModel) => {
            Row({ space: 2 }) {
              Text(this.getTrainingAbbr(record))
                .fontSize(9)
                .fontColor(Color.White)
                .maxLines(1)
              Text(this.getTrainingVolume(record))
                .fontSize(8)
                .fontColor('rgba(255,255,255,0.8)')
                .maxLines(1)
            }
            .width('100%')
            .height(14)
            .padding({ left: 2, right: 2 })
            .backgroundColor('#4CAF50')
            .borderRadius(3)
            .justifyContent(FlexAlign.Center)
          })

          // 如果有更多记录
          if (day.records.length > 2) {
            Text('+' + (day.records.length - 2).toString())
              .fontSize(8)
              .fontColor('#666666')
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('14.28%')
    .height(80)
    .padding(2)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      if (day.isCurrentMonth) {
        this.onDayClick(day);
      }
    })
  }

  @Builder
  RecordDetailSheet() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('关闭')
          .fontSize(15)
          .fontColor('#007AFF')
          .onClick(() => {
            this.showDetailDialog = false;
          })

        Blank()

        Text(this.selectedDay?.dateStr ?? '')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank()

        // 页码指示
        if (this.selectedDayRecords.length > 1) {
          Text((this.currentRecordIndex + 1).toString() + '/' + this.selectedDayRecords.length.toString())
            .fontSize(14)
            .fontColor('#666666')
        } else {
          Text('')
            .fontSize(14)
            .width(40)
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

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
    .backgroundColor('#F5F5F5')
  }

  @Builder
  RecordDetailContent(record: TrainingRecordModel) {
    Scroll() {
      Column({ space: 16 }) {
        // 训练标题卡片
        Column({ space: 12 }) {
          Row() {
            Column({ space: 4 }) {
              Text(record.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Text(this.extractTimeFromDateTime(record.startTime) + ' - ' + this.extractTimeFromDateTime(record.endTime))
                .fontSize(13)
                .fontColor('#999999')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (record.mood.length > 0) {
              Text(record.mood)
                .fontSize(12)
                .fontColor(Color.White)
                .backgroundColor(this.getMoodColor(record.mood))
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .borderRadius(4)
            }
          }
          .width('100%')

          // 训练数据统计
          Row({ space: 8 }) {
            this.DataTag('时长', record.duration.toString() + '分钟', '#4CAF50')
            this.DataTag('组数', record.totalSets.toString() + '组', '#FF9800')
            this.DataTag('容量', (record.totalWeight / 1000).toFixed(1) + 'T', '#2196F3')
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)

        // 训练动作详情
        if (record.exercises.length > 0) {
          Column({ space: 12 }) {
            Text('训练动作')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            ForEach(record.exercises, (exercise: ExerciseModel, index: number) => {
              this.ExerciseDetailItem(exercise, index)
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
        }

        // 训练备注
        if (record.notes.length > 0) {
          Column({ space: 8 }) {
            Text('训练心得')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Text(record.notes)
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
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
  ExerciseDetailItem(exercise: ExerciseModel, index: number) {
    Row({ space: 12 }) {
      // 序号
      Text((index + 1).toString())
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)
        .backgroundColor('#007AFF')
        .borderRadius(12)

      // 动作信息
      Column({ space: 4 }) {
        Text(exercise.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Row({ space: 16 }) {
          Text(exercise.sets.toString() + '组')
            .fontSize(13)
            .fontColor('#666666')
          Text(exercise.reps.toString() + '次/组')
            .fontSize(13)
            .fontColor('#666666')
          Text(exercise.weight.toString() + 'kg')
            .fontSize(13)
            .fontColor('#007AFF')
            .fontWeight(FontWeight.Medium)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 肌群标签
      if (exercise.muscleGroup.length > 0) {
        Text(exercise.muscleGroup)
          .fontSize(11)
          .fontColor('#999999')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F5F5F5')
          .borderRadius(4)
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F9F9F9')
    .borderRadius(8)
  }

  @Builder
  BottomActionBar(record: TrainingRecordModel) {
    Row({ space: 12 }) {
      // 编辑/继续训练
      Button('继续训练')
        .fontSize(14)
        .height(44)
        .layoutWeight(1)
        .backgroundColor('#007AFF')
        .borderRadius(8)
        .onClick(() => {
          this.showDetailDialog = false;
          router.pushUrl({
            url: 'pages/TrainingSessionPage',
            params: { recordId: record.id }
          });
        })

      // 复制到今天
      Button('复制到今天')
        .fontSize(14)
        .height(44)
        .layoutWeight(1)
        .backgroundColor('#4CAF50')
        .borderRadius(8)
        .onClick(() => {
          this.copyToToday(record);
        })

      // 删除
      Button('删除')
        .fontSize(14)
        .height(44)
        .width(70)
        .backgroundColor('#FF4444')
        .borderRadius(8)
        .onClick(() => {
          promptAction.showDialog({
            title: '确认删除',
            message: '确定要删除这条训练记录吗？',
            buttons: [
              { text: '取消', color: '#666666' },
              { text: '删除', color: '#FF0000' }
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
    .backgroundColor(Color.White)
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.08)', offsetX: 0, offsetY: -2 })
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
    .layoutWeight(1)
    .padding(8)
    .backgroundColor(Color.White)
    .borderRadius(6)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 获取训练项目摘要
   */
  getExercisesSummary(exercises: ExerciseModel[]): string {
    const names: string[] = [];
    for (let i: number = 0; i < Math.min(exercises.length, 3); i++) {
      names.push(exercises[i].name);
    }
    let summary: string = names.join('、');
    if (exercises.length > 3) {
      summary += ' 等' + exercises.length.toString() + '项';
    }
    return summary;
  }

  /**
   * 从完整日期时间字符串中提取时间部分 (HH:mm)
   * 支持格式: "YYYY-MM-DD HH:mm:ss" 或 "HH:mm" 或 "HH:mm:ss"
   */
  extractTimeFromDateTime(dateTimeStr: string): string {
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
  getMoodColor(mood: string): string {
    if (mood === '优秀') {
      return '#4CAF50';
    } else if (mood === '良好') {
      return '#8BC34A';
    } else if (mood === '一般') {
      return '#FF9800';
    } else if (mood === '疲劳') {
      return '#F44336';
    }
    return '#999999';
  }
}
