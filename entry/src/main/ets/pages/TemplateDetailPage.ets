/**
 * 模板详情页面
 * 展示模板内容，支持使用模板创建计划
 */
import {
  PlanTemplateModel,
  TrainingDayModel,
  ExerciseModel,
  PlanApiService,
  toast,
  RouterManager,
  NavRouteParams
} from '@tbs/common';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

@Builder
export function TemplateDetailPageBuilder() {
  TemplateDetailPage()
}

@Component
struct TemplateDetailPage {
  @State template: PlanTemplateModel | null = null;
  @State isLoading: boolean = true;
  @State showDatePicker: boolean = false;
  @State startDate: Date = new Date();
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  private templateId: string = '';

  aboutToAppear(): void {
    // 获取路由参数
    const params: NavRouteParams | undefined = RouterManager.getLatestParamByName('TemplateDetailPage');
    if (params?.templateId !== undefined && params.templateId !== null) {
      this.templateId = params.templateId.toString();
      this.loadTemplateDetail();
    }
  }

  /**
   * 加载模板详情
   */
  async loadTemplateDetail(): Promise<void> {
    this.isLoading = true;
    this.template = null;
    try {
      const res: ResponseResult = await PlanApiService.getPlanTemplate(this.templateId);
      if (res.code === 0 && res.data) {
        this.template = res.data as PlanTemplateModel;
      }
    } catch (err) {
      console.error('加载模板详情失败:', JSON.stringify(err));
      toast('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 使用模板创建计划
   */
  async createPlanFromTemplate(): Promise<void> {
    if (this.template === null) {
      return;
    }

    try {
      const dateStr: string = this.formatDate(this.startDate);
      const res: ResponseResult =
        await PlanApiService.createPlanFromTemplate(this.template.id, dateStr);
      if (res.code === 0) {
        toast('计划创建成功');
        AppStorage.setOrCreate<number>('refreshDashboardTimestamp', Date.now());
        RouterManager.pop();
      } else {
        toast('创建失败: ' + res.message);
      }
    } catch (err) {
      console.error('创建计划失败:', JSON.stringify(err));
      toast('创建失败');
    }
  }

  /**
   * 格式化日期
   */
  formatDate(date: Date): string {
    const year: string = date.getFullYear().toString();
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    return year + '-' + month + '-' + day;
  }

  build() {
    NavDestination() {
      Column() {
        this.TopBar()

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('app.color.brand_primary'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.template !== null) {
          Column() {
            Scroll() {
              Column({ space: 16 }) {
                // 模板信息卡片
                this.TemplateInfoCard()

                // 训练理念
                this.PhilosophyCard()

                // 训练安排
                this.TrainingDaysSection()
              }
              .width('100%')
              .padding(16)
            }
            .layoutWeight(1)
            .align(Alignment.Top)

            // 底部操作栏
            this.BottomActionBar()
          }
          .width('100%')
          .layoutWeight(1)
        } else {
          Column({ space: 12 }) {
            Text('模板不存在')
              .fontSize(15)
              .fontColor($r('app.color.text_hint'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_background'))
    .onBackPressed(() => {
      RouterManager.pop();
      return true;
    })
  }

  @Builder
  TopBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([$r('app.color.text_primary')])
        .onClick(() => {
          RouterManager.pop();
        })

      Text(this.template?.name ?? '模板详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Column().width(24)
    }
    .width('100%')
    .height(70)
    .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  TemplateInfoCard() {
    Column({ space: 12 }) {
      // 标题和等级
      Row() {
        Text(this.template?.name ?? '')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        Row({ space: 6 }) {
          if (this.template?.level) {
            Text(this.template.level)
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor(this.getLevelColor(this.template.level))
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(4)
          }

          if (this.template?.isOfficial ?? false) {
            Text('官方')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.brand_primary'))
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(4)
          }
        }
      }
      .width('100%')

      if (this.template?.goal) {
        Text(this.template.goal)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.brand_primary'))
          .width('100%')
      }

      // 属性标签
      Flex({ wrap: FlexWrap.Wrap }) {
        if (this.template?.splitType) {
          this.InfoTag(this.template.splitType)
        }
        if (this.template?.equipment) {
          this.InfoTag(this.template.equipment)
        }
        this.InfoTag((this.template?.durationWeeks ?? 0).toString() + '周')
        this.InfoTag('每周' + (this.template?.trainingDaysPerWeek ?? 0).toString() + '练')
        if (this.template?.recommendedIntensity) {
          this.InfoTag(this.template.recommendedIntensity)
        }
      }
      .width('100%')

      // 计划信息
      Row({ space: 16 }) {
        if (this.template?.author) {
          this.MetaItem('作者', this.template.author)
        }
        this.MetaItem('计划天数', this.getTrainingDays().length.toString() + '天')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  InfoTag(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor($r('app.color.text_secondary'))
      .backgroundColor($r('app.color.card_background_secondary'))
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .borderRadius(6)
      .margin({ right: 8, bottom: 8 })
  }

  @Builder
  MetaItem(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
      Text(value)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  PhilosophyCard() {
    Column({ space: 10 }) {
      Text('训练理念')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(this.template?.description ?? '')
        .fontSize(14)
        .lineHeight(22)
        .textAlign(TextAlign.Start)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  TrainingDaysSection() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text('训练安排')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.getScheduleSummary())
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')

      ForEach(this.getTrainingDays(), (day: TrainingDayModel) => {
        this.TrainingDayCard(day)
      }, (day: TrainingDayModel): string => day.dayNumber.toString())
    }
    .width('100%')
  }

  @Builder
  TrainingDayCard(day: TrainingDayModel) {
    Column({ space: 8 }) {
      Row() {
        Text('Day ' + day.dayNumber.toString() + ' · ' + day.dayName)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        if (day.isRestDay) {
          Text('休息日')
            .fontSize(10)
            .fontColor($r('app.color.text_hint'))
            .backgroundColor($r('app.color.card_background_secondary'))
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(4)
        } else {
          Text(this.getExerciseCount(day).toString() + '个动作')
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))
        }
      }
      .width('100%')

      if (!day.isRestDay) {
        Text(this.getExerciseNames(day))
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(10)
  }

  @Builder
  BottomActionBar() {
    Column({ space: 0 }) {
      Row() {
        Button('使用模板训练')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(10)
          .onClick(() => {
            this.showDatePicker = true;
          })
          .bindSheet($$this.showDatePicker, this.DatePickerSheet(), {
            height: SheetSize.FIT_CONTENT,
            backgroundColor: $r('app.color.card_background'),
            dragBar: true
          })
      }
      .width('100%')

      Row()
        .width('100%')
        .height(this.getUIContext().px2vp(this.bottomRectHeight))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  DatePickerSheet() {
    Column({ space: 16 }) {
      Text('选择开始日期')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      DatePicker({
        start: new Date(),
        end: new Date(new Date().setFullYear(new Date().getFullYear() + 1)),
        selected: this.startDate
      })
        .onDateChange((value: Date) => {
          this.startDate = value;
        })

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(10)
          .onClick(() => {
            this.showDatePicker = false;
          })

        Button('确定创建')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(10)
          .onClick(() => {
            this.showDatePicker = false;
            this.createPlanFromTemplate();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
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

  getTrainingDays(): Array<TrainingDayModel> {
    if (this.template === null || this.template.trainingDays === null || this.template.trainingDays === undefined) {
      return [];
    }
    return this.template.trainingDays as Array<TrainingDayModel>;
  }

  getScheduleSummary(): string {
    if (this.template === null) {
      return '';
    }
    const durationWeeks: string = (this.template.durationWeeks ?? 0).toString() + '周';
    const trainingDaysPerWeek: string = '每周' + (this.template.trainingDaysPerWeek ?? 0).toString() + '练';
    const totalDays: number = this.getTrainingDays().length;
    if (totalDays > 0) {
      return durationWeeks + ' · ' + trainingDaysPerWeek + ' · ' + totalDays.toString() + '天循环';
    }
    return durationWeeks + ' · ' + trainingDaysPerWeek;
  }

  getExerciseCount(day: TrainingDayModel): number {
    if (day.exercises === null || day.exercises === undefined) {
      return 0;
    }
    return day.exercises.length;
  }

  getExerciseNames(day: TrainingDayModel): string {
    const exercises: Array<ExerciseModel> = this.getExercises(day);
    if (exercises.length === 0) {
      return '无训练动作';
    }
    let names: string = '';
    for (let i: number = 0; i < exercises.length; i += 1) {
      if (i === 0) {
        names = exercises[i].name;
      } else {
        names = names + ' · ' + exercises[i].name;
      }
    }
    return names;
  }

  getExercises(day: TrainingDayModel): Array<ExerciseModel> {
    if (day.exercises === null || day.exercises === undefined) {
      return [];
    }
    return day.exercises;
  }
}
