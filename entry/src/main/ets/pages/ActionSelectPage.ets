/**
 * 动作选择页面 - Action Select
 * 支持多选动作（最多5个），用于训练时添加动作
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { ActionModel, MuscleGroupModel, ActionDataService, toast } from '@tbs/common';

const MAX_SELECT_COUNT: number = 5;

/**
 * 选中动作数据类
 */
class SelectedActionData {
  id: string = '';
  name: string = '';
  muscleGroup: string = '';
  thumbnailUrl: string = '';

  constructor(id: string, name: string, muscleGroup: string, thumbnailUrl: string) {
    this.id = id;
    this.name = name;
    this.muscleGroup = muscleGroup;
    this.thumbnailUrl = thumbnailUrl;
  }
}

/**
 * 系统路由表构建函数
 */
@Builder
export function ActionSelectPageBuilder(): void {
  ActionSelectPage()
}

@Component
export struct ActionSelectPage {
  @State muscleGroups: MuscleGroupModel[] = []
  @State currentGroupIndex: number = 0
  @State currentActions: ActionModel[] = []
  @State selectedActions: ActionModel[] = []
  @State selectedActionIds: Set<string> = new Set()
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.loadData();
  }

  /**
   * 加载数据
   */
  loadData(): void {
    this.muscleGroups = ActionDataService.getAllMuscleGroups();
    if (this.muscleGroups.length > 0) {
      this.currentActions = this.muscleGroups[0].actions;
    }
  }

  /**
   * 切换肌肉部位
   */
  switchMuscleGroup(index: number): void {
    this.currentGroupIndex = index;
    if (index < this.muscleGroups.length) {
      this.currentActions = this.muscleGroups[index].actions;
    }
  }

  /**
   * 切换动作选中状态
   */
  toggleActionSelection(action: ActionModel): void {
    if (this.selectedActionIds.has(action.id)) {
      // 取消选中
      this.selectedActionIds.delete(action.id);
      const newSelected: ActionModel[] = [];
      for (let i: number = 0; i < this.selectedActions.length; i++) {
        if (this.selectedActions[i].id !== action.id) {
          newSelected.push(this.selectedActions[i]);
        }
      }
      this.selectedActions = newSelected;
      // 触发重新渲染
      this.selectedActionIds = new Set(this.selectedActionIds);
    } else {
      // 检查是否超过最大数量
      if (this.selectedActions.length >= MAX_SELECT_COUNT) {
        toast('最多只能选择 ' + MAX_SELECT_COUNT.toString() + ' 个动作');
        return;
      }
      // 添加选中
      this.selectedActionIds.add(action.id);
      this.selectedActions.push(action);
      // 触发重新渲染
      this.selectedActionIds = new Set(this.selectedActionIds);
    }
  }

  /**
   * 检查动作是否被选中
   */
  isActionSelected(actionId: string): boolean {
    return this.selectedActionIds.has(actionId);
  }

  /**
   * 确认选择
   */
  confirmSelection(): void {
    if (this.selectedActions.length === 0) {
      toast('请至少选择一个动作');
      return;
    }

    // 将选中的动作序列化为 JSON 字符串传递
    const selectedData: SelectedActionData[] = [];
    for (let i: number = 0; i < this.selectedActions.length; i++) {
      const action: ActionModel = this.selectedActions[i];
      const actionData: SelectedActionData = new SelectedActionData(
        action.id,
        action.name,
        action.muscleGroup,
        action.thumbnailUrl
      );
      selectedData.push(actionData);
    }

    // 使用 JSON 字符串传递数据，确保类型兼容
    const jsonStr: string = JSON.stringify(selectedData);
    AppStorage.setOrCreate<string>('selectedActionsJson', jsonStr);

    this.pathStack.pop();
  }

  build() {
    NavDestination() {
      Column() {
        // 主内容区域 - 左右布局
        Row() {
          // 左侧：肌肉部位列表
          this.MuscleGroupList()

          // 右侧：动作列表
          this.ActionList()
        }
        .width('100%')
        .layoutWeight(1)

        // 底部确认栏
        this.BottomBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('选择动作')
    .menus([
      {
        value: this.selectedActions.length.toString() + '/' + MAX_SELECT_COUNT.toString(),
        action: (): void => {}
      }
    ])
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }

  @Builder
  MuscleGroupList() {
    Scroll() {
      Column({ space: 0 }) {
        ForEach(this.muscleGroups, (group: MuscleGroupModel, index: number) => {
          this.MuscleGroupItem(group, index)
        })
      }
      .width('100%')
    }
    .width(100)
    .height('100%')
    .backgroundColor(Color.White)
    .scrollBar(BarState.Off)
  }

  @Builder
  MuscleGroupItem(group: MuscleGroupModel, index: number) {
    Column({ space: 4 }) {
      Text(group.icon)
        .fontSize(24)

      Text(group.name)
        .fontSize(12)
        .fontColor(this.currentGroupIndex === index ? '#007AFF' : '#666666')
        .fontWeight(this.currentGroupIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(80)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.currentGroupIndex === index ? '#E3F2FD' : Color.White)
    .onClick(() => {
      this.switchMuscleGroup(index);
    })
  }

  @Builder
  ActionList() {
    Scroll() {
      Column({ space: 12 }) {
        // 部位标题
        Row() {
          Text(this.muscleGroups[this.currentGroupIndex]?.name ?? '')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Blank()
          Text(this.currentActions.length.toString() + ' 个动作')
            .fontSize(13)
            .fontColor('#999999')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })

        // 动作列表
        Column({ space: 12 }) {
          ForEach(this.currentActions, (action: ActionModel) => {
            this.ActionItem(action)
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .width('100%')
    }
    .layoutWeight(1)
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  ActionItem(action: ActionModel) {
    Row({ space: 12 }) {
      // 选择框
      Text(this.isActionSelected(action.id) ? '✅' : '⭕')
        .fontSize(22)
        .fontColor(this.isActionSelected(action.id) ? '#007AFF' : '#CCCCCC')

      // 动作缩略图
      Column() {
        Text('🏋️')
          .fontSize(28)
      }
      .width(60)
      .height(60)
      .backgroundColor(this.isActionSelected(action.id) ? '#E3F2FD' : '#E8E8E8')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 动作信息
      Column({ space: 4 }) {
        Text(action.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isActionSelected(action.id) ? '#007AFF' : '#333333')

        Text(action.englishName)
          .fontSize(11)
          .fontColor('#999999')

        Row({ space: 8 }) {
          Text(action.difficulty)
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.getDifficultyColor(action.difficulty))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(3)

          if (action.equipment.length > 0) {
            Text(action.equipment)
              .fontSize(10)
              .fontColor('#666666')
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.isActionSelected(action.id) ? '#F0F7FF' : Color.White)
    .borderRadius(12)
    .border({ width: this.isActionSelected(action.id) ? 2 : 0, color: '#007AFF' })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.toggleActionSelection(action);
    })
  }

  @Builder
  BottomBar() {
    Column({ space: 8 }) {
      // 已选动作预览
      if (this.selectedActions.length > 0) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.selectedActions, (action: ActionModel) => {
              this.SelectedActionTag(action)
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .height(40)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }

      // 确认按钮
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .backgroundColor('#E0E0E0')
          .fontColor('#333333')
          .borderRadius(8)
          .onClick(() => {
            this.pathStack.pop();
          })

        Button('确认添加 (' + this.selectedActions.length.toString() + ')')
          .layoutWeight(2)
          .height(44)
          .fontSize(16)
          .backgroundColor(this.selectedActions.length > 0 ? '#007AFF' : '#CCCCCC')
          .borderRadius(8)
          .enabled(this.selectedActions.length > 0)
          .onClick(() => {
            this.confirmSelection();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      // 底部导航区域避让
      Row()
        .width('100%')
        .height(this.getUIContext().px2vp(this.bottomRectHeight))
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({ top: 12 })
  }

  @Builder
  SelectedActionTag(action: ActionModel) {
    Row({ space: 4 }) {
      Text(action.name)
        .fontSize(12)
        .fontColor('#007AFF')

      Text('✕')
        .fontSize(12)
        .fontColor('#999999')
        .onClick(() => {
          this.toggleActionSelection(action);
        })
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor('#E3F2FD')
    .borderRadius(16)
  }

  /**
   * 获取难度等级颜色
   */
  getDifficultyColor(difficulty: string): string {
    if (difficulty === '初级') {
      return '#4CAF50';
    } else if (difficulty === '中级') {
      return '#FF9800';
    } else if (difficulty === '高级') {
      return '#F44336';
    }
    return '#999999';
  }
}
