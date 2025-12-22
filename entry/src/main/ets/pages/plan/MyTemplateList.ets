/**
 * 我的模板列表组件
 * 展示用户创建/复制的个人训练模板
 */
import {
  PlanTemplateModel,
  PlanApiService,
  toast,
  RouterManager,
  NavRoutes
} from '@tbs/common';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';
import { TemplateCard } from './TemplateCard';

@Component
export struct MyTemplateList {
  @State templates: PlanTemplateModel[] = [];
  @State isLoading: boolean = false;
  @State currentPage: number = 1;
  @State hasMore: boolean = true;
  private pageSize: number = 10;

  aboutToAppear(): void {
    this.loadTemplates(true);
  }

  /**
   * 加载个人模板列表
   */
  async loadTemplates(refresh: boolean = false): Promise<void> {
    if (this.isLoading) {
      return;
    }

    if (refresh) {
      this.currentPage = 1;
      this.hasMore = true;
      this.templates = [];
    }

    if (!this.hasMore && !refresh) {
      return;
    }

    this.isLoading = true;
    try {
      const res: ResponseResult = await PlanApiService.getPlanTemplates(
        this.currentPage,
        this.pageSize,
        '',
        '',
        '',
        '',
        0,
        0,
        false // 个人模板
      );

      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const templatesArray: Object[] = apiData['templates'] as Object[] ?? [];
        const total: number = apiData['total'] as number ?? 0;

        const newTemplates: PlanTemplateModel[] = [];
        for (let i = 0; i < templatesArray.length; i++) {
          newTemplates.push(templatesArray[i] as PlanTemplateModel);
        }

        if (refresh) {
          this.templates = newTemplates;
        } else {
          this.templates = this.templates.concat(newTemplates);
        }

        this.hasMore = this.templates.length < total;
        this.currentPage++;
      }
    } catch (err) {
      console.error('加载个人模板失败:', JSON.stringify(err));
      toast('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 使用模板创建计划
   */
  useTemplate(template: PlanTemplateModel): void {
    RouterManager.pushPath(NavRoutes.TEMPLATE_DETAIL, { templateId: template.id });
  }

  /**
   * 编辑模板
   */
  editTemplate(template: PlanTemplateModel): void {
    RouterManager.pushPath(NavRoutes.TEMPLATE_EDITOR, { templateId: template.id, isEdit: true });
  }

  /**
   * 删除模板
   */
  async deleteTemplate(template: PlanTemplateModel): Promise<void> {
    try {
      const res: ResponseResult = await PlanApiService.deleteTemplate(template.id.toString());
      if (res.code === 0) {
        toast('删除成功');
        this.loadTemplates(true);
      } else {
        toast('删除失败');
      }
    } catch (err) {
      console.error('删除模板失败:', JSON.stringify(err));
      toast('删除失败');
    }
  }

  /**
   * 创建新模板
   */
  createNewTemplate(): void {
    RouterManager.pushPath(NavRoutes.TEMPLATE_EDITOR, { isEdit: false });
  }

  build() {
    Column({ space: 12 }) {
      // 创建按钮
      Button() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(18)
            .fontColor([Color.White])
          Text('创建个人模板')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .height(44)
      .backgroundColor($r('app.color.brand_primary'))
      .borderRadius(10)
      .onClick(() => {
        this.createNewTemplate();
      })

      // 模板列表
      if (this.templates.length > 0) {
        List({ space: 12 }) {
          ForEach(this.templates, (template: PlanTemplateModel) => {
            ListItem() {
              Column() {
                TemplateCard({
                  template: template,
                  showUseButton: false,
                  onTap: (): void => {
                    this.editTemplate(template);
                  },
                  onUse: (): void => {
                    this.useTemplate(template);
                  }
                })

                // 操作按钮
                Row({ space: 12 }) {
                  Button('使用')
                    .layoutWeight(1)
                    .height(36)
                    .fontSize(13)
                    .backgroundColor($r('app.color.brand_primary'))
                    .borderRadius(8)
                    .onClick(() => {
                      this.useTemplate(template);
                    })

                  Button('编辑')
                    .layoutWeight(1)
                    .height(36)
                    .fontSize(13)
                    .fontColor($r('app.color.brand_primary'))
                    .backgroundColor($r('app.color.brand_primary_light'))
                    .borderRadius(8)
                    .onClick(() => {
                      this.editTemplate(template);
                    })

                  Button('删除')
                    .layoutWeight(1)
                    .height(36)
                    .fontSize(13)
                    .fontColor($r('app.color.color_danger'))
                    .backgroundColor($r('app.color.color_danger_light'))
                    .borderRadius(8)
                    .onClick(() => {
                      this.deleteTemplate(template);
                    })
                }
                .width('100%')
                .margin({ top: 8 })
              }
            }
          }, (template: PlanTemplateModel): string => template.id.toString())

          // 加载更多
          if (this.hasMore) {
            ListItem() {
              Row() {
                if (this.isLoading) {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                    .color($r('app.color.brand_primary'))
                  Text('加载中...')
                    .fontSize(13)
                    .fontColor($r('app.color.text_hint'))
                    .margin({ left: 8 })
                } else {
                  Text('加载更多')
                    .fontSize(13)
                    .fontColor($r('app.color.brand_primary'))
                }
              }
              .width('100%')
              .height(48)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                if (!this.isLoading) {
                  this.loadTemplates(false);
                }
              })
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else if (!this.isLoading) {
        // 空状态
        Column({ space: 16 }) {
          Text('暂无个人模板')
            .fontSize(15)
            .fontColor($r('app.color.text_hint'))

          Text('创建个人模板或从官方模板复制')
            .fontSize(13)
            .fontColor($r('app.color.text_placeholder'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 加载中
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color($r('app.color.brand_primary'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}

