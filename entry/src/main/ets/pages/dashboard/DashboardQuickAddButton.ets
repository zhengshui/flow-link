/**
 * Dashboard 快速添加按钮
 */

@Component
export struct DashboardQuickAddButton {
  onQuickAdd: () => void = () => {}

  build(): void {
    Button('快速添加训练')
      .width('100%')
      .height(48)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .backgroundColor($r('app.color.brand_primary'))
      .borderRadius(10)
      .onClick(() => {
        this.onQuickAdd();
      })
  }
}
