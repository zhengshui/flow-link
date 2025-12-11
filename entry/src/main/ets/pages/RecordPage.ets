/**
 * 训练记录页面 - Record
 * 日历视图显示历史训练记录，支持年月切换，点击查看详情
 */

import { TrainingRecordModel, TrainingApiService, toast, RouterManager, NavRoutes, NavRouteParams } from '@tbs/common';
import { promptAction } from '@kit.ArkUI';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';
import { CalendarDayModel, CalendarComponent, RecordDetailSheet } from './record/index';

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
  @StorageProp('topRectHeight') topRectHeight: number = 0

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

      const res: ResponseResult = await TrainingApiService.getTrainingRecords(1, 100, startDate, endDate);
      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const recordsArray: Object = apiData['records'] ?? [];
        this.records = recordsArray as TrainingRecordModel[];
        this.mapRecordsToCalendar();
      } else {
        toast(res.message ?? '加载失败');
      }
    } catch (err) {
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
          { text: '取消', color: '#646A73' },
          { text: '开始训练', color: '#3370FF' }
        ]
      }).then((result: promptAction.ShowDialogSuccessResponse) => {
        if (result.index === 1) {
          // 传递选中的日期，用于设置训练的开始时间
          const params: NavRouteParams = { selectedDate: day.dateStr };
          RouterManager.pushPath(NavRoutes.TRAINING_SESSION, params);
        }
      }).catch((err: Error) => {
        console.error('Dialog error:', JSON.stringify(err));
      });
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 主内容 - 日历组件
      Column() {
        CalendarComponent({
          currentYear: this.currentYear,
          currentMonth: this.currentMonth,
          calendarDays: this.calendarDays,
          isLoading: this.isLoading,
          onDayClick: (day: CalendarDayModel): void => {
            this.onDayClick(day);
          },
          onPrevMonth: (): void => {
            this.goToPrevMonth();
          },
          onNextMonth: (): void => {
            this.goToNextMonth();
          },
          onToday: (): void => {
            this.goToToday();
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
      // 顶部状态栏避让
      .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })

      // 训练详情弹窗
      if (this.showDetailDialog && this.selectedDay !== null) {
        RecordDetailSheet({
          showDetailDialog: this.showDetailDialog,
          selectedDay: this.selectedDay,
          selectedDayRecords: this.selectedDayRecords,
          currentRecordIndex: this.currentRecordIndex,
          onRecordDeleted: (): void => {
            this.loadMonthRecords();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
