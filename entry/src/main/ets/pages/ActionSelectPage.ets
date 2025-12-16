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
        // 顶部标题栏
        this.TopBar()

        // 主内容区域 - 左右布局
        Row() {
          // 左侧：肌肉部位列表
          this.MuscleGroupList()

          // 分隔线
          Divider()
            .vertical(true)
            .height('100%')
            .color($r('app.color.divider'))

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
  TopBar() {
    Row() {
      // 关闭按钮
      Row() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(20)
          .fontColor([$r('app.color.text_secondary')])
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .borderRadius(20)
      .backgroundColor($r('app.color.card_background_secondary'))
      .onClick(() => {
        this.pathStack.pop();
      })

      // 标题
      Column({ space: 2 }) {
        Text('选择动作')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('最多可选 ' + MAX_SELECT_COUNT.toString() + ' 个')
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      // 已选数量指示器
      Stack() {
        Progress({ value: this.selectedActions.length, total: MAX_SELECT_COUNT, type: ProgressType.Ring })
          .width(40)
          .height(40)
          .style({ strokeWidth: 3 })
          .color($r('app.color.brand_primary'))
          .backgroundColor($r('app.color.outline'))

        Text(this.selectedActions.length.toString())
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.brand_primary'))
      }
    }
    .width('100%')
    .height(56 + this.getUIContext().px2vp(this.topRectHeight))
    .padding({
      left: 16,
      right: 16,
      top: this.getUIContext().px2vp(this.topRectHeight)
    })
    .backgroundColor($r('app.color.card_background'))
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  MuscleGroupList() {
    List() {
      ForEach(this.muscleGroups, (group: MuscleGroupModel, index: number) => {
        ListItem() {
          this.MuscleGroupItem(group, index)
        }
      })
    }
    .width(88)
    .height('100%')
    .listDirection(Axis.Vertical)
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.card_background'))
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  MuscleGroupItem(group: MuscleGroupModel, index: number) {
    Row() {
      // 选中指示条
      Column()
        .width(3)
        .height(this.currentGroupIndex === index ? 24 : 0)
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(2)
        .animation({ duration: 200, curve: Curve.EaseOut })

      // 部位名称
      Text(group.name)
        .fontSize(14)
        .fontColor(this.currentGroupIndex === index ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
        .fontWeight(this.currentGroupIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ left: this.currentGroupIndex === index ? 8 : 0 })
        .animation({ duration: 200, curve: Curve.EaseOut })
    }
    .width('100%')
    .height(52)
    .padding({ left: 4, right: 12 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.currentGroupIndex === index ? $r('app.color.brand_primary_light') : Color.Transparent)
    .animation({ duration: 200, curve: Curve.EaseOut })
    .onClick(() => {
      this.switchMuscleGroup(index);
    })
  }

  @Builder
  ActionList() {
    Column() {
      // 部位标题
      Row() {
        Column({ space: 2 }) {
          Text(this.muscleGroups[this.currentGroupIndex]?.name ?? '')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text(this.currentActions.length.toString() + ' 个动作可选')
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      // 动作列表
      List({ space: 10 }) {
        ForEach(this.currentActions, (action: ActionModel) => {
          ListItem() {
            this.ActionItem(action)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .padding({ left: 16, right: 16, bottom: 16 })
      .edgeEffect(EdgeEffect.Spring)
    }
    .layoutWeight(1)
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  ActionItem(action: ActionModel) {
    Row({ space: 12 }) {
      // 动作缩略图
      Stack() {
        if (action.gifUrl.length > 0) {
          Image($rawfile('exercises/' + action.gifUrl))
            .width(64)
            .height(64)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
        } else {
          Column() {
            SymbolGlyph($r('sys.symbol.figure_run'))
              .fontSize(28)
              .fontColor([$r('app.color.text_hint')])
          }
          .width(64)
          .height(64)
          .backgroundColor($r('app.color.card_background_secondary'))
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }

        // 选中状态覆盖层
        if (this.isActionSelected(action.id)) {
          Column() {
            SymbolGlyph($r('sys.symbol.checkmark'))
              .fontSize(24)
              .fontColor([Color.White])
          }
          .width(64)
          .height(64)
          .borderRadius(12)
          .backgroundColor('rgba(51, 112, 255, 0.85)')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }

      // 动作信息
      Column({ space: 6 }) {
        Text(action.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(action.equipment)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)

        Row({ space: 6 }) {
          // 难度标签
          Text(action.difficulty)
            .fontSize(11)
            .fontColor(Color.White)
            .backgroundColor(this.getDifficultyColor(action.difficulty))
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(4)

          // 肌肉群标签
          if (action.muscleGroup.length > 0) {
            Text(action.muscleGroup)
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
              .backgroundColor($r('app.color.card_background_secondary'))
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(4)
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 选择指示器
      Column() {
        if (this.isActionSelected(action.id)) {
          SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
            .fontSize(24)
            .fontColor([$r('app.color.brand_primary')])
        } else {
          Column()
            .width(22)
            .height(22)
            .borderRadius(11)
            .border({ width: 2, color: $r('app.color.outline') })
        }
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(14)
    .border({
      width: this.isActionSelected(action.id) ? 1.5 : 0,
      color: $r('app.color.brand_primary')
    })
    .shadow({
      radius: this.isActionSelected(action.id) ? 12 : 4,
      color: this.isActionSelected(action.id) ? 'rgba(51, 112, 255, 0.15)' : 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 2
    })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.toggleActionSelection(action);
    })
    .animation({ duration: 150, curve: Curve.EaseOut })
  }

  @Builder
  BottomBar() {
    Column({ space: 12 }) {
      // 已选动作预览
      if (this.selectedActions.length > 0) {
        Column({ space: 8 }) {
          Row() {
            Text('已选动作')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_secondary'))
            Blank()
            Text('点击可移除')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.selectedActions, (action: ActionModel) => {
                this.SelectedActionChip(action)
              })
            }
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .height(36)
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
      }

      // 按钮区域
      Row({ space: 12 }) {
        // 取消按钮
        Button('取消')
          .layoutWeight(1)
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_secondary'))
          .border({ width: 1, color: $r('app.color.outline') })
          .borderRadius(12)
          .onClick(() => {
            this.pathStack.pop();
          })

        // 确认按钮
        Button() {
          Row({ space: 6 }) {
            Text('确认添加')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
            if (this.selectedActions.length > 0) {
              Text('(' + this.selectedActions.length.toString() + ')')
                .fontSize(15)
                .fontColor('rgba(255, 255, 255, 0.8)')
            }
          }
        }
        .layoutWeight(2)
        .height(48)
        .backgroundColor(this.selectedActions.length > 0 ? $r('app.color.brand_primary') : $r('app.color.text_placeholder'))
        .borderRadius(12)
        .enabled(this.selectedActions.length > 0)
        .onClick(() => {
          this.confirmSelection();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      // 底部安全区域
      Row()
        .width('100%')
        .height(this.getUIContext().px2vp(this.bottomRectHeight))
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .padding({ top: 16, bottom: 8 })
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: -4
    })
  }

  @Builder
  SelectedActionChip(action: ActionModel) {
    Row({ space: 6 }) {
      Text(action.name)
        .fontSize(13)
        .fontColor($r('app.color.brand_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)

      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(12)
        .fontColor([$r('app.color.text_hint')])
    }
    .padding({ left: 12, right: 10, top: 8, bottom: 8 })
    .backgroundColor($r('app.color.brand_primary_light'))
    .borderRadius(18)
    .onClick(() => {
      this.toggleActionSelection(action);
    })
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
