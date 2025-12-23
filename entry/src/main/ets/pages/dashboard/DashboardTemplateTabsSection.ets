/**
 * Dashboard 模板列表
 */

import { PlanTemplateModel } from '@tbs/common';

@Component
export struct DashboardTemplateTabsSection {
  @Prop officialTemplates: PlanTemplateModel[] = []
  @Prop personalTemplates: PlanTemplateModel[] = []
  @Prop templateTabIndex: number = 0
  onViewTemplateDetail: (template: PlanTemplateModel) => void = () => {}
  onCreatePersonalTemplate: () => void = () => {}

  build(): void {
    Column({ space: 12 }) {
      Row() {
        Text('训练模板')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(this.officialTemplates.length.toString() + ' 个')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      if (this.officialTemplates.length > 0) {
        Column({ space: 12 }) {
          ForEach(this.splitTemplatesForGrid(this.officialTemplates, 3),
            (rowTemplates: PlanTemplateModel[], rowIndex: number) => {
            Row({ space: 12 }) {
              ForEach(rowTemplates, (template: PlanTemplateModel, columnIndex: number) => {
                Column() {
                  this.TemplateMiniCard(template, rowIndex * 3 + columnIndex)
                }
                .layoutWeight(1)
              }, (template: PlanTemplateModel, columnIndex: number): string => {
                const idKey: string = template.id && template.id.length > 0 ? template.id : 'template';
                return idKey + '_' + rowIndex.toString() + '_' + columnIndex.toString();
              })

              if (rowTemplates.length < 3) {
                ForEach(this.getPlaceholderArray(3 - rowTemplates.length), (placeholderIndex: number) => {
                  Blank()
                    .layoutWeight(1)
                }, (placeholderIndex: number): string => {
                  return 'placeholder_' + rowIndex.toString() + '_' + placeholderIndex.toString();
                })
              }
            }
            .width('100%')
          }, (rowTemplates: PlanTemplateModel[], rowIndex: number): string => {
            return 'template_row_' + rowIndex.toString();
          })
        }
        .width('100%')
      } else {
        Column({ space: 8 }) {
          Text(this.templateTabIndex === 1 ? '暂无个人模板' : '暂无官方模板')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
          if (this.templateTabIndex === 1) {
            Button('创建个人模板')
              .width('100%')
              .height(38)
              .fontSize(13)
              .backgroundColor($r('app.color.brand_primary'))
              .borderRadius(8)
              .onClick(() => {
                this.onCreatePersonalTemplate();
              })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
      }
    }
    .width('100%')
  }

  @Builder
  private TemplateMiniCard(template: PlanTemplateModel, index: number): void {
    Column() {
      Row()
        .width('100%')
        .height(4)
        .backgroundColor(this.getTemplateAccentColor())
        .borderRadius({ topLeft: 12, topRight: 12 })

      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text(template.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
        }
        .width('100%')

        if (template.description) {
          Text(template.description)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 8, bottom: 12 })
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: 3
    })
    .onClick(() => {
      this.onViewTemplateDetail(template);
    })
  }

  private getTemplateAccentColor(): Resource {
    return $r('app.color.brand_primary_light');
  }

  private splitTemplatesForGrid(templates: PlanTemplateModel[], columns: number): PlanTemplateModel[][] {
    const rows: PlanTemplateModel[][] = [];
    if (columns <= 0 || templates.length === 0) {
      return rows;
    }
    let currentRow: PlanTemplateModel[] = [];
    for (let i: number = 0; i < templates.length; i++) {
      currentRow.push(templates[i]);
      if (currentRow.length === columns) {
        rows.push(currentRow);
        currentRow = [];
      }
    }
    if (currentRow.length > 0) {
      rows.push(currentRow);
    }
    return rows;
  }

  private getPlaceholderArray(count: number): number[] {
    const result: number[] = [];
    for (let i: number = 0; i < count; i++) {
      result.push(i);
    }
    return result;
  }
}
