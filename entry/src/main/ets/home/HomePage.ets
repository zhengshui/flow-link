/**
 * FitEasy 主页面 - 包含底部Tab导航
 * 使用 Navigation 作为路由容器
 * 5个Tab：首页、记录、动作、数据、我的
 */

import { DashboardPage } from '../pages/DashboardPage'
import { RecordPage } from '../pages/RecordPage'
import { ExercisePage } from '../pages/ExercisePage'
import { StatsPage } from '../pages/StatsPage'
import { ProfilePage } from '../pages/ProfilePage'
import { TabInfoModel, tabInfo } from './viewModel/homeData'
import { RouterManager } from '@tbs/common'

@Entry
@Component
struct HomePage {
  @State currentIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  private controller: TabsController = new TabsController()
  // Navigation 路由栈
  private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    // 初始化全局路由栈
    RouterManager.initNavPathStack(this.pathStack)
  }

  build() {
    Navigation(this.pathStack) {
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
            RecordPage({ currentTabIndex: this.currentIndex })
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
        // 底部导航区域避让，防止底部Tab被系统导航条遮挡
        .padding({ bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
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
