/**
 * 计划中心页面
 * 包含官方计划、我的计划、我的模板三个 Tab
 */
import { RouterManager } from '@tbs/common';
import { OfficialPlanList } from './plan/OfficialPlanList';
import { MyPlanList } from './plan/MyPlanList';
import { MyTemplateList } from './plan/MyTemplateList';

@Builder
export function PlanCenterPageBuilder() {
  PlanCenterPage()
}

@Component
struct PlanCenterPage {
  @State currentTabIndex: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  // Tab 配置
  private tabTitles: string[] = ['官方计划', '我的计划', '我的模板'];

  build() {
    NavDestination() {
      Column() {
        // 自定义 Tab 栏
        Row() {
          ForEach(this.tabTitles, (title: string, index: number) => {
            Column({ space: 6 }) {
              Text(title)
                .fontSize(15)
                .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(this.currentTabIndex === index ?
                  $r('app.color.text_primary') : $r('app.color.text_secondary'))

              // 指示器
              Row()
                .width(24)
                .height(3)
                .backgroundColor(this.currentTabIndex === index ?
                  $r('app.color.brand_primary') : Color.Transparent)
                .borderRadius(1.5)
            }
            .layoutWeight(1)
            .padding({ top: 12, bottom: 8 })
            .onClick(() => {
              this.currentTabIndex = index;
            })
          })
        }
        .width('100%')
        .backgroundColor($r('app.color.card_background'))

        // Tab 内容
        Tabs({ index: this.currentTabIndex }) {
          TabContent() {
            OfficialPlanList()
              .padding(16)
          }

          TabContent() {
            MyPlanList()
              .padding(16)
          }

          TabContent() {
            MyTemplateList()
              .padding(16)
          }
        }
        .barHeight(0)
        .layoutWeight(1)
        .animationDuration(200)
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .title('计划中心')
    .backgroundColor($r('app.color.page_background'))
    .onBackPressed(() => {
      RouterManager.pop();
      return true;
    })
  }
}

