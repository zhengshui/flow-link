/**
 * FitEasy 底部导航Tab数据模型
 * 使用 HarmonyOS Symbol 图标
 */

export class TabInfoModel {
  index: number = 0;
  title: string = '';
  icon: Resource | null = null;
  iconFilled: Resource | null = null;
}

const tabInfo: TabInfoModel[] = [
  {
    index: 0,
    title: '首页',
    icon: $r('sys.symbol.house'),
    iconFilled: $r('sys.symbol.house_fill')
  },
  {
    index: 1,
    title: '记录',
    icon: $r('sys.symbol.calendar'),
    iconFilled: $r('sys.symbol.calendar')
  },
  {
    index: 2,
    title: '动作',
    icon: $r('sys.symbol.dumbbell'),
    iconFilled: $r('sys.symbol.dumbbell_fill')
  },
  {
    index: 3,
    title: '数据',
    icon: $r('sys.symbol.square_grid_2x2'),
    iconFilled: $r('sys.symbol.square_grid_2x2')
  },
  {
    index: 4,
    title: '我的',
    icon: $r('sys.symbol.person'),
    iconFilled: $r('sys.symbol.person_fill')
  }
]

export { tabInfo }
