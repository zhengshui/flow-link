/**
 * 动作库页面 - Exercise
 * 按肌肉部位分组显示训练动作，左右布局
 */

import { ActionModel, MuscleGroupModel, ActionDataService, RouterManager, NavRoutes, NavRouteParams } from '@tbs/common';

@Component
export struct ExercisePage {
  @State muscleGroups: MuscleGroupModel[] = []
  @State currentGroupIndex: number = 0
  @State currentActions: ActionModel[] = []
  @StorageProp('topRectHeight') topRectHeight: number = 0

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
   * 跳转到动作详情页
   */
  goToActionDetail(action: ActionModel): void {
    const params: NavRouteParams = {
      actionId: action.id
    };
    RouterManager.pushPath(NavRoutes.EXERCISE_DETAIL, params);
  }

  build() {
    Column() {
      // 主内容区域 - 左右布局
      Row() {
        // 左侧：肌肉部位列表
        this.MuscleGroupList()

        // 右侧：动作列表
        this.ActionList()
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    // 顶部状态栏避让
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
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
      .padding({ top: 8, bottom: 8 })
    }
    .width(80)
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }

  @Builder
  MuscleGroupItem(group: MuscleGroupModel, index: number) {
    Stack({ alignContent: Alignment.Start }) {
      // 选中指示条
      if (this.currentGroupIndex === index) {
        Column()
          .width(3)
          .height(20)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(2)
      }

      // 部位名称
      Text(group.name)
        .fontSize(13)
        .fontColor(this.currentGroupIndex === index ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
        .fontWeight(this.currentGroupIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(48)
    .backgroundColor(this.currentGroupIndex === index ? $r('app.color.brand_primary_light') : Color.Transparent)
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
    .align(Alignment.Top)
  }

  @Builder
  ActionItem(action: ActionModel) {
    Row({ space: 12 }) {
      // 动作缩略图 - 优先使用GIF，否则使用默认占位
      if (action.gifUrl.length > 0) {
        Image($rawfile('exercises/' + action.gifUrl))
          .width(56)
          .height(56)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
      } else {
        Column() {
          Text('🏋️')
            .fontSize(24)
        }
        .width(56)
        .height(56)
        .backgroundColor($r('app.color.outline'))
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 动作信息
      Column({ space: 4 }) {
        Text(action.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

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

          if (action.equipment.length > 0) {
            Text(action.equipment)
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 箭头图标
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([$r('app.color.text_placeholder')])
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.goToActionDetail(action);
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
