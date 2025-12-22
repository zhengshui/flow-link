/**
 * 计划/模板筛选面板组件
 */

/**
 * 筛选条件模型
 */
export class PlanFilterOptions {
  goal: string = '';
  level: string = '';
  splitType: string = '';
  equipment: string = '';
}

@Component
export struct PlanFilterPanel {
  @Link filterOptions: PlanFilterOptions;
  onFilterChange: () => void = () => {};

  // 筛选选项
  private goalOptions: string[] = ['全部', '增肌', '减脂', '力量提升', '耐力提升', '综合健身'];
  private levelOptions: string[] = ['全部', '初级', '中级', '高级'];
  private splitTypeOptions: string[] = ['全部', '二分化', '三分化', '推拉腿', '上下肢', '四分化', '五分化'];
  private equipmentOptions: string[] = ['全部', '徒手', '哑铃', '器械', '混合'];

  build() {
    Column({ space: 12 }) {
      // 目标筛选
      this.FilterRow('训练目标', this.goalOptions, this.filterOptions.goal, (value: string) => {
        this.filterOptions.goal = value === '全部' ? '' : value;
        this.onFilterChange();
      })

      // 难度筛选
      this.FilterRow('难度等级', this.levelOptions, this.filterOptions.level, (value: string) => {
        this.filterOptions.level = value === '全部' ? '' : value;
        this.onFilterChange();
      })

      // 分化方式筛选
      this.FilterRow('分化方式', this.splitTypeOptions, this.filterOptions.splitType, (value: string) => {
        this.filterOptions.splitType = value === '全部' ? '' : value;
        this.onFilterChange();
      })

      // 器械筛选
      this.FilterRow('主要器械', this.equipmentOptions, this.filterOptions.equipment, (value: string) => {
        this.filterOptions.equipment = value === '全部' ? '' : value;
        this.onFilterChange();
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  FilterRow(label: string, options: string[], selectedValue: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          ForEach(options, (option: string) => {
            Text(option)
              .fontSize(12)
              .fontColor(this.isSelected(option, selectedValue) ?
                Color.White : $r('app.color.text_secondary'))
              .backgroundColor(this.isSelected(option, selectedValue) ?
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

  /**
   * 判断选项是否被选中
   */
  isSelected(option: string, selectedValue: string): boolean {
    if (option === '全部' && selectedValue === '') {
      return true;
    }
    return option === selectedValue;
  }
}

