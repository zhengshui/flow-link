/**
 * 动作选择页面 - Action Select
 * 支持多选动作（最多5个），用于训练时添加动作
 * 使用 NavDestination 作为 Navigation 子页面
 */

import { ActionModel, MuscleGroupModel, ActionDataService, toast, MuscleGroupConst } from '@tbs/common';

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
        // 自定义标题栏
        Row() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(24)
            .fontColor([$r('app.color.text_primary')])
            .onClick(() => {
              this.pathStack.pop();
            })

          Text('选择动作')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          // 已选数量显示
          Text(this.selectedActions.length.toString() + '/' + MAX_SELECT_COUNT.toString())
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(70)
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topRectHeight) })
        .backgroundColor($r('app.color.card_background'))

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
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
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
    .backgroundColor($r('app.color.card_background'))
    .scrollBar(BarState.Off)
  }

  @Builder
  MuscleGroupItem(group: MuscleGroupModel, index: number) {
    Column({ space: 4 }) {
      Image(MuscleGroupConst.getImageIcon(group.id))
        .width(36)
        .height(36)
        .objectFit(ImageFit.Contain)
        .borderRadius(6)

      Text(group.name)
        .fontSize(12)
        .fontColor(this.currentGroupIndex === index ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
        .fontWeight(this.currentGroupIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(80)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
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
            .fontColor($r('app.color.text_primary'))
          Blank()
          Text(this.currentActions.length.toString() + ' 个动作')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
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
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  ActionItem(action: ActionModel) {
    Row({ space: 12 }) {
      // 选择框
      Text(this.isActionSelected(action.id) ? '✅' : '⭕')
        .fontSize(22)
        .fontColor(this.isActionSelected(action.id) ? $r('app.color.brand_primary') : $r('app.color.text_placeholder'))

      // 动作缩略图 - 优先使用GIF，否则显示占位符
      if (action.gifUrl.length > 0) {
        Image($rawfile('exercises/' + action.gifUrl))
          .width(60)
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .border({
            width: this.isActionSelected(action.id) ? 2 : 0,
            color: $r('app.color.brand_primary')
          })
      } else {
        Column() {
          Text('🏋️')
            .fontSize(28)
        }
        .width(60)
        .height(60)
        .backgroundColor(this.isActionSelected(action.id) ? $r('app.color.brand_primary_light') : $r('app.color.outline'))
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 动作信息
      Column({ space: 4 }) {
        Text(action.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isActionSelected(action.id) ? $r('app.color.brand_primary') : $r('app.color.text_primary'))

        Text(action.equipment)
          .fontSize(11)
          .fontColor($r('app.color.text_hint'))

        Row({ space: 8 }) {
          Text(action.difficulty)
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.getDifficultyColor(action.difficulty))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(3)

          if (action.muscleGroup.length > 0) {
            Text(action.muscleGroup)
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.isActionSelected(action.id) ? $r('app.color.brand_primary_light') : $r('app.color.card_background'))
    .borderRadius(12)
    .border({ width: this.isActionSelected(action.id) ? 2 : 0, color: $r('app.color.brand_primary') })
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
          .backgroundColor($r('app.color.outline'))
          .fontColor($r('app.color.text_primary'))
          .borderRadius(8)
          .onClick(() => {
            this.pathStack.pop();
          })

        Button('确认添加 (' + this.selectedActions.length.toString() + ')')
          .layoutWeight(2)
          .height(44)
          .fontSize(16)
          .backgroundColor(this.selectedActions.length > 0 ? $r('app.color.brand_primary') : $r('app.color.text_placeholder'))
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
    .backgroundColor($r('app.color.card_background'))
    .padding({ top: 12 })
    .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.06)', offsetX: 0, offsetY: -2 })
  }

  @Builder
  SelectedActionTag(action: ActionModel) {
    Row({ space: 4 }) {
      Text(action.name)
        .fontSize(12)
        .fontColor($r('app.color.brand_primary'))

      Text('✕')
        .fontSize(12)
        .fontColor($r('app.color.text_hint'))
        .onClick(() => {
          this.toggleActionSelection(action);
        })
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor($r('app.color.brand_primary_light'))
    .borderRadius(16)
  }

  /**
   * 获取难度等级颜色
   */
  getDifficultyColor(difficulty: string): Resource {
    if (difficulty === '初级') {
      return $r('app.color.color_success');
    } else if (difficulty === '中级') {
      return $r('app.color.color_warning');
    } else if (difficulty === '高级') {
      return $r('app.color.color_danger');
    }
    return $r('app.color.text_hint');
  }
}
