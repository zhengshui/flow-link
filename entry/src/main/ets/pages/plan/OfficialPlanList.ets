/**
 * 官方计划列表组件
 * 展示官方训练模板列表，支持筛选
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
import { PlanFilterPanel, PlanFilterOptions } from './PlanFilterPanel';

@Component
export struct OfficialPlanList {
  @State templates: PlanTemplateModel[] = [];
  @State isLoading: boolean = false;
  @State showFilter: boolean = false;
  @State filterOptions: PlanFilterOptions = new PlanFilterOptions();
  @State currentPage: number = 1;
  @State hasMore: boolean = true;
  private pageSize: number = 10;

  aboutToAppear(): void {
    this.loadTemplates(true);
  }

  /**
   * 加载模板列表
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
        this.filterOptions.goal,
        this.filterOptions.level,
        this.filterOptions.splitType,
        this.filterOptions.equipment,
        0,
        0,
        true // 官方模板
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
      console.error('加载官方模板失败:', JSON.stringify(err));
      toast('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 筛选变化处理
   */
  onFilterChange(): void {
    this.loadTemplates(true);
  }

  /**
   * 使用模板
   */
  useTemplate(template: PlanTemplateModel): void {
    RouterManager.pushPath(NavRoutes.TEMPLATE_DETAIL, { templateId: template.id });
  }

  /**
   * 查看模板详情
   */
  viewTemplateDetail(template: PlanTemplateModel): void {
    RouterManager.pushPath(NavRoutes.TEMPLATE_DETAIL, { templateId: template.id });
  }

  build() {
    Column({ space: 12 }) {
      // 筛选按钮
      Row() {
        Text('筛选')
          .fontSize(14)
          .fontColor(this.showFilter ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
          .onClick(() => {
            this.showFilter = !this.showFilter;
          })

        if (this.hasActiveFilter()) {
          Text('清除')
            .fontSize(12)
            .fontColor($r('app.color.color_danger'))
            .margin({ left: 12 })
            .onClick(() => {
              this.filterOptions = new PlanFilterOptions();
              this.loadTemplates(true);
            })
        }

        Blank()

        Text(this.templates.length.toString() + '个模板')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')
      .padding({ left: 4, right: 4 })

      // 筛选面板
      if (this.showFilter) {
        PlanFilterPanel({
          filterOptions: this.filterOptions,
          onFilterChange: (): void => {
            this.onFilterChange();
          }
        })
      }

      // 模板列表
      if (this.templates.length > 0) {
        List({ space: 12 }) {
          ForEach(this.templates, (template: PlanTemplateModel) => {
            ListItem() {
              TemplateCard({
                template: template,
                onTap: (): void => {
                  this.viewTemplateDetail(template);
                },
                onUse: (): void => {
                  this.useTemplate(template);
                }
              })
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
        Column({ space: 12 }) {
          Text('暂无官方模板')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))
          Text('尝试调整筛选条件')
            .fontSize(12)
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

  /**
   * 判断是否有激活的筛选条件
   */
  hasActiveFilter(): boolean {
    return this.filterOptions.goal !== '' ||
      this.filterOptions.level !== '' ||
      this.filterOptions.splitType !== '' ||
      this.filterOptions.equipment !== '';
  }
}

