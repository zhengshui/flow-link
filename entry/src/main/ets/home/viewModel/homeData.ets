/**
 * FitEasy 底部导航Tab数据模型
 */

export class TabInfoModel {
  index: number = 0;
  title: string = '';
  icon: string = '';
}

const tabInfo: TabInfoModel[] = [
  {
    index: 0,
    title: '首页',
    icon: '🏠'
  },
  {
    index: 1,
    title: '记录',
    icon: '📝'
  },
  {
    index: 2,
    title: '动作',
    icon: '💪'
  },
  {
    index: 3,
    title: '数据',
    icon: '📊'
  },
  {
    index: 4,
    title: '我的',
    icon: '👤'
  }
]

export { tabInfo }
