/**
 * FitEasy 主页面 - 应用入口
 * 使用 Navigation 作为路由容器
 * 根据登录状态显示：登录页 或 主页Tab
 */

import { DashboardPage } from '../pages/DashboardPage'
import { RecordPage } from '../pages/RecordPage'
import { ExercisePage } from '../pages/ExercisePage'
import { StatsPage } from '../pages/StatsPage'
import { ProfilePage } from '../pages/ProfilePage'
import { TabInfoModel, tabInfo } from './viewModel/homeData'
import { RouterManager, StorageConst, StorageUtils, NavRoutes } from '@tbs/common'

@Entry
@Component
struct HomePage {
  @State currentIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageLink('isLoggedIn') @Watch('onLoginStateChange') isLoggedIn: boolean = false
  private controller: TabsController = new TabsController()
  // Navigation 路由栈
  private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    // 初始化全局路由栈
    RouterManager.initNavPathStack(this.pathStack)
    // 检查登录状态
    this.checkLoginState()
  }

  /**
   * 检查登录状态
   */
  checkLoginState(): void {
    const token: string = StorageUtils.getStringValueSync(StorageConst.TOKEN, '')
    if (token.length > 0) {
      this.isLoggedIn = true
      AppStorage.setOrCreate<boolean>('isLoggedIn', true)
    } else {
      this.isLoggedIn = false
      AppStorage.setOrCreate<boolean>('isLoggedIn', false)
      // 未登录，跳转到登录页
      this.pathStack.pushPathByName(NavRoutes.LOGIN, undefined)
    }
  }

  /**
   * 监听登录状态变化
   */
  onLoginStateChange(): void {
    if (!this.isLoggedIn) {
      // 登出后，跳转到登录页
      this.pathStack.clear()
      this.pathStack.pushPathByName(NavRoutes.LOGIN, undefined)
    }
  }

  build() {
    Navigation(this.pathStack) {
      // 主内容：Tab 页面（仅在已登录时显示）
      if (this.isLoggedIn) {
        Column() {
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
          // 底部导航区域避让
          .padding({ bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.page_background'))
      }
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
  }

  /**
   * 自定义Tab项构建器
   * 使用 HarmonyOS Symbol 图标
   */
  @Builder
  TabBuilder(item: TabInfoModel) {
    Column({ space: 4 }) {
      if (item.icon !== null) {
        SymbolGlyph(this.currentIndex === item.index && item.iconFilled !== null ? item.iconFilled : item.icon)
          .fontSize(24)
          .fontColor([this.currentIndex === item.index ? $r('app.color.brand_primary') : $r('app.color.text_secondary')])
      }

      Text(item.title)
        .fontSize(11)
        .fontColor(this.currentIndex === item.index ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
        .fontWeight(this.currentIndex === item.index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
