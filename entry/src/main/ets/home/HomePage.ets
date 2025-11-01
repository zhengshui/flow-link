/**
 * FitEasy 主页面 - 包含底部Tab导航
 * 5个Tab：首页、记录、动作、数据、我的
 */

import { DashboardPage } from '../pages/DashboardPage'
import { RecordPage } from '../pages/RecordPage'
import { ExercisePage } from '../pages/ExercisePage'
import { StatsPage } from '../pages/StatsPage'
import { ProfilePage } from '../pages/ProfilePage'
import { TabInfoModel, tabInfo } from './viewModel/homeData'

@Entry
@Component
struct HomePage {
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()

  build() {
    Column() {
      // 主内容区域 - Tabs
      Tabs({
        barPosition: BarPosition.End,
        index: this.currentIndex,
        controller: this.controller
      }) {
        // 首页
        TabContent() {
          DashboardPage()
        }
        .tabBar(this.TabBuilder(tabInfo[0]))

        // 训练记录
        TabContent() {
          RecordPage()
        }
        .tabBar(this.TabBuilder(tabInfo[1]))

        // 动作库
        TabContent() {
          ExercisePage()
        }
        .tabBar(this.TabBuilder(tabInfo[2]))

        // 数据分析
        TabContent() {
          StatsPage()
        }
        .tabBar(this.TabBuilder(tabInfo[3]))

        // 我的
        TabContent() {
          ProfilePage()
        }
        .tabBar(this.TabBuilder(tabInfo[4]))
      }
      .width('100%')
      .height('100%')
      .barHeight(56)
      .barMode(BarMode.Fixed)
      .scrollable(false)
      .animationDuration(0)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 自定义Tab项构建器
   */
  @Builder
  TabBuilder(item: TabInfoModel) {
    Column({ space: 4 }) {
      Text(item.icon)
        .fontSize(24)
        .opacity(this.currentIndex === item.index ? 1.0 : 0.6)

      Text(item.title)
        .fontSize(12)
        .fontColor(this.currentIndex === item.index ? '#007AFF' : '#666666')
        .fontWeight(this.currentIndex === item.index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
