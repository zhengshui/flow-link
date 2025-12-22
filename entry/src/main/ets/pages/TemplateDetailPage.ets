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
  NavRoutes,
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
  private templateId: number = 0;

  aboutToAppear(): void {
    // 获取路由参数
    const params: NavRouteParams | undefined =
      RouterManager.getNavPathStack()?.getParamByName('TemplateDetailPage') as NavRouteParams | undefined;
    if (params?.templateId) {
      this.templateId = params.templateId;
    }
    this.loadTemplateDetail();
  }

  /**
   * 加载模板详情
   */
  async loadTemplateDetail(): Promise<void> {
    this.isLoading = true;
    this.template = null;
    try {
      const res: ResponseResult = await PlanApiService.getPlanTemplate(this.templateId.toString());
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
   * 复制为个人模板
   */
  async duplicateTemplate(): Promise<void> {
    if (this.template === null) {
      return;
    }

    try {
      const res: ResponseResult = await PlanApiService.duplicateTemplate(this.template.id.toString());
      if (res.code === 0) {
        toast('已复制到我的模板');
      } else {
        toast('复制失败');
      }
    } catch (err) {
      console.error('复制模板失败:', JSON.stringify(err));
      toast('复制失败');
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
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color($r('app.color.brand_primary'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.template !== null) {
        Column() {
          Scroll() {
            Column({ space: 16 }) {
              // 模板信息卡片
              this.TemplateInfoCard()

              // 训练日程
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
        .height('100%')
      } else {
        Column({ space: 12 }) {
          Text('模板不存在')
            .fontSize(15)
            .fontColor($r('app.color.text_hint'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .title(this.template?.name ?? '模板详情')
    .backgroundColor($r('app.color.page_background'))
    .onBackPressed(() => {
      RouterManager.pop();
      return true;
    })
  }

  @Builder
  TemplateInfoCard() {
    Column({ space: 12 }) {
      // 标题和标签
      Row() {
        Text(this.template?.name ?? '')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        Row({ space: 6 }) {
          Text(this.template?.level ?? '')
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.getLevelColor(this.template?.level ?? ''))
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(4)

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

      // 描述
      Text(this.template?.description ?? '')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')

      // 属性标签
      Row({ space: 8 }) {
        if (this.template?.splitType) {
          this.InfoTag(this.template.splitType)
        }
        if (this.template?.equipment) {
          this.InfoTag(this.template.equipment)
        }
        this.InfoTag((this.template?.durationWeeks ?? 0).toString() + '周')
        this.InfoTag('每周' + (this.template?.trainingDaysPerWeek ?? 0).toString() + '天')
      }
      .width('100%')

      Divider()
        .color($r('app.color.divider'))

      // 统计信息
      Row({ space: 16 }) {
        this.StatItem('#' + (this.template?.goal ?? ''), '训练目标')
        this.StatItem(this.template?.author ?? '', '作者')
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
      .borderRadius(4)
      .margin({ bottom: 4 })
  }

  @Builder
  StatItem(value: string, label: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.brand_primary'))
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TrainingDaysSection() {
    Column({ space: 12 }) {
      Text('训练日程')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      ForEach(this.template?.trainingDays ?? [], (day: TrainingDayModel) => {
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
        }
      }
      .width('100%')

      if (!day.isRestDay) {
        // 训练项目
        ForEach(day.exercises, (exercise: ExerciseModel, index: number) => {
          Row() {
            Text(exercise.name)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .layoutWeight(1)
            Text(exercise.sets.toString() + '组×' + exercise.reps.toString() + '次')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
            if (exercise.weight > 0) {
              Text(' · ' + exercise.weight.toString() + 'kg')
                .fontSize(12)
                .fontColor($r('app.color.text_hint'))
            }
          }
          .width('100%')
          .padding({ top: 4, bottom: 4 })
        }, (exercise: ExerciseModel, index: number): string => index.toString())

        // 强度提示
        if (day.intensityHint) {
          Row({ space: 4 }) {
            Text('强度:')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
            Text(day.intensityHint)
              .fontSize(11)
              .fontColor($r('app.color.color_warning'))
          }
          .width('100%')
          .margin({ top: 4 })
        }
      }

      // 备注
      if (day.notes) {
        Text(day.notes)
          .fontSize(12)
          .fontColor($r('app.color.text_placeholder'))
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
    Row({ space: 12 }) {
      // 复制到我的模板（仅官方模板显示）
      if (this.template?.isOfficial ?? false) {
        Button('复制为个人模板')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor($r('app.color.brand_primary'))
          .backgroundColor($r('app.color.brand_primary_light'))
          .borderRadius(10)
          .onClick(() => {
            this.duplicateTemplate();
          })
      }

      Button('使用此模板')
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
}

