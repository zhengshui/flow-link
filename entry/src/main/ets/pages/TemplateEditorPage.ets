/**
 * 模板编辑页面
 * 用于创建或编辑个人训练模板
 */
import {
  PlanTemplateModel,
  TrainingDayModel,
  PlanApiService,
  toast,
  RouterManager,
  NavRouteParams
} from '@tbs/common';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';

@Builder
export function TemplateEditorPageBuilder() {
  TemplateEditorPage()
}

@Component
struct TemplateEditorPage {
  @State template: PlanTemplateModel = new PlanTemplateModel();
  @State isLoading: boolean = false;
  @State isSaving: boolean = false;
  private isEdit: boolean = false;
  private templateId: string = '';

  // 选项配置
  private goalOptions: string[] = ['增肌', '减脂', '力量提升', '耐力提升', '综合健身'];
  private levelOptions: string[] = ['初级', '中级', '高级'];
  private splitTypeOptions: string[] = ['二分化', '三分化', '推拉腿', '上下肢', '四分化', '五分化'];
  private equipmentOptions: string[] = ['徒手', '哑铃', '器械', '混合'];

  aboutToAppear(): void {
    // 获取路由参数
    const params: NavRouteParams | undefined = RouterManager.getLatestParamByName('TemplateEditorPage');
    if (params?.templateId !== undefined && params.templateId !== null) {
      this.templateId = params.templateId.toString();
      this.isEdit = params.isEdit ?? false;
      if (this.isEdit) {
        this.loadTemplateDetail();
      }
    }

    // 初始化默认值
    if (!this.isEdit) {
      this.template = new PlanTemplateModel();
      this.template.durationWeeks = 4;
      this.template.trainingDaysPerWeek = 4;
      this.template.level = '中级';
      this.template.goal = '综合健身';
      this.template.splitType = '四分化';
      this.template.equipment = '混合';
      this.initDefaultTrainingDays();
    }
  }

  /**
   * 初始化默认训练日程
   */
  initDefaultTrainingDays(): void {
    const days: TrainingDayModel[] = [];
    for (let i: number = 1; i <= 7; i++) {
      const day: TrainingDayModel = new TrainingDayModel();
      day.dayNumber = i;
      if (i <= 4) {
        day.dayName = '训练日' + i.toString();
        day.isRestDay = false;
      } else {
        day.dayName = '休息日';
        day.isRestDay = true;
      }
      day.exercises = [];
      days.push(day);
    }
    this.template.trainingDays = days;
  }

  /**
   * 加载模板详情（编辑模式）
   */
  async loadTemplateDetail(): Promise<void> {
    this.isLoading = true;
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
   * 保存模板
   */
  async saveTemplate(): Promise<void> {
    // 验证
    if (!this.template.name) {
      toast('请输入模板名称');
      return;
    }

    this.isSaving = true;
    try {
      let res: ResponseResult;
      if (this.isEdit) {
        res = await PlanApiService.updateTemplate(this.templateId, this.template);
      } else {
        res = await PlanApiService.createCustomTemplate(this.template);
      }

      if (res.code === 0) {
        toast(this.isEdit ? '保存成功' : '创建成功');
        RouterManager.pop();
      } else {
        toast('操作失败: ' + res.message);
      }
    } catch (err) {
      console.error('保存模板失败:', JSON.stringify(err));
      toast('保存失败');
    } finally {
      this.isSaving = false;
    }
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
      } else {
        Column() {
          Scroll() {
            Column({ space: 16 }) {
              // 基本信息
              this.BasicInfoSection()

              // 属性设置
              this.AttributesSection()

              // 训练日程
              this.TrainingDaysSection()
            }
            .width('100%')
            .padding(16)
          }
          .layoutWeight(1)
          .align(Alignment.Top)

          // 保存按钮
          this.SaveButton()
        }
        .width('100%')
        .height('100%')
      }
    }
    .title(this.isEdit ? '编辑模板' : '创建模板')
    .backgroundColor($r('app.color.page_background'))
    .onBackPressed(() => {
      RouterManager.pop();
      return true;
    })
  }

  @Builder
  BasicInfoSection() {
    Column({ space: 12 }) {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      // 模板名称
      Column({ space: 6 }) {
        Text('模板名称')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
        TextInput({ placeholder: '请输入模板名称', text: this.template.name })
          .height(44)
          .fontSize(14)
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(8)
          .onChange((value: string) => {
            this.template.name = value;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 描述
      Column({ space: 6 }) {
        Text('模板描述')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
        TextArea({ placeholder: '请输入模板描述', text: this.template.description })
          .height(80)
          .fontSize(14)
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(8)
          .onChange((value: string) => {
            this.template.description = value;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  AttributesSection() {
    Column({ space: 14 }) {
      Text('属性设置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      // 训练目标
      this.OptionSelector('训练目标', this.goalOptions, this.template.goal, (value: string) => {
        this.template.goal = value;
      })

      // 难度等级
      this.OptionSelector('难度等级', this.levelOptions, this.template.level, (value: string) => {
        this.template.level = value;
      })

      // 分化方式
      this.OptionSelector('分化方式', this.splitTypeOptions, this.template.splitType, (value: string) => {
        this.template.splitType = value;
      })

      // 主要器械
      this.OptionSelector('主要器械', this.equipmentOptions, this.template.equipment, (value: string) => {
        this.template.equipment = value;
      })

      // 周期设置
      Row({ space: 16 }) {
        Column({ space: 6 }) {
          Text('计划周期（周）')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Row({ space: 8 }) {
            Button('-')
              .width(36)
              .height(36)
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.card_background_secondary'))
              .borderRadius(8)
              .onClick(() => {
                if (this.template.durationWeeks > 1) {
                  this.template.durationWeeks--;
                }
              })
            Text(this.template.durationWeeks.toString())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width(40)
              .textAlign(TextAlign.Center)
            Button('+')
              .width(36)
              .height(36)
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.card_background_secondary'))
              .borderRadius(8)
              .onClick(() => {
                if (this.template.durationWeeks < 24) {
                  this.template.durationWeeks++;
                }
              })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('每周训练天')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Row({ space: 8 }) {
            Button('-')
              .width(36)
              .height(36)
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.card_background_secondary'))
              .borderRadius(8)
              .onClick(() => {
                if (this.template.trainingDaysPerWeek > 1) {
                  this.template.trainingDaysPerWeek--;
                }
              })
            Text(this.template.trainingDaysPerWeek.toString())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width(40)
              .textAlign(TextAlign.Center)
            Button('+')
              .width(36)
              .height(36)
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.card_background_secondary'))
              .borderRadius(8)
              .onClick(() => {
                if (this.template.trainingDaysPerWeek < 7) {
                  this.template.trainingDaysPerWeek++;
                }
              })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  OptionSelector(label: string, options: string[], selectedValue: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          ForEach(options, (option: string) => {
            Text(option)
              .fontSize(12)
              .fontColor(selectedValue === option ? Color.White : $r('app.color.text_secondary'))
              .backgroundColor(selectedValue === option ?
                $r('app.color.brand_primary') : $r('app.color.card_background_secondary'))
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                onChange(option);
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TrainingDaysSection() {
    Column({ space: 12 }) {
      Row() {
        Text('训练日程')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text('点击编辑')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')

      ForEach(this.template.trainingDays, (day: TrainingDayModel, index: number) => {
        this.TrainingDayItem(day, index)
      }, (day: TrainingDayModel, index: number): string => index.toString())
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  TrainingDayItem(day: TrainingDayModel, index: number) {
    Row({ space: 12 }) {
      Text('Day ' + day.dayNumber.toString())
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.brand_primary'))
        .width(50)

      TextInput({ placeholder: '训练日名称', text: day.dayName })
        .height(36)
        .fontSize(13)
        .backgroundColor($r('app.color.card_background_secondary'))
        .borderRadius(6)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.template.trainingDays[index].dayName = value;
        })

      Toggle({ type: ToggleType.Switch, isOn: day.isRestDay })
        .width(44)
        .height(24)
        .selectedColor($r('app.color.color_success'))
        .onChange((isOn: boolean) => {
          this.template.trainingDays[index].isRestDay = isOn;
          if (isOn) {
            this.template.trainingDays[index].dayName = '休息日';
          }
        })

      Text('休息')
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  SaveButton() {
    Button(this.isSaving ? '保存中...' : (this.isEdit ? '保存修改' : '创建模板'))
      .width('100%')
      .height(48)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .backgroundColor($r('app.color.brand_primary'))
      .borderRadius(10)
      .margin(16)
      .enabled(!this.isSaving)
      .onClick(() => {
        this.saveTemplate();
      })
  }
}
