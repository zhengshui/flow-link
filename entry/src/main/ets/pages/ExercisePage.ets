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
    }
    .width(100)
    .height('100%')
    .backgroundColor($r('app.color.card_background'))
    .scrollBar(BarState.Off)
  }

  @Builder
  MuscleGroupItem(group: MuscleGroupModel, index: number) {
    Column({ space: 4 }) {
      // 肌肉部位图标
      Text(group.icon)
        .fontSize(22)

      Text(group.name)
        .fontSize(12)
        .fontColor(this.currentGroupIndex === index ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
        .fontWeight(this.currentGroupIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(72)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.currentGroupIndex === index ? $r('app.color.brand_primary_light') : $r('app.color.card_background'))
    .borderRadius(this.currentGroupIndex === index ? 8 : 0)
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
      // 动作缩略图 - 使用肌群对应图标
      Column() {
        Text(this.getMuscleGroupIcon(action.muscleGroup))
          .fontSize(28)
      }
      .width(56)
      .height(56)
      .backgroundColor(this.getMuscleGroupColor(action.muscleGroup))
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 动作信息
      Column({ space: 4 }) {
        Text(action.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(action.englishName)
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

  /**
   * 获取难度等级背景色（较浅）
   */
  getDifficultyBgColor(difficulty: string): string {
    if (difficulty === '初级') {
      return '#66BB6A';
    } else if (difficulty === '中级') {
      return '#FFA726';
    } else if (difficulty === '高级') {
      return '#EF5350';
    }
    return '#BDBDBD';
  }

  /**
   * 根据肌肉部位名称获取对应图标
   */
  getMuscleGroupIcon(muscleGroup: string): string {
    if (muscleGroup === '胸肌') {
      return '💪';
    } else if (muscleGroup === '背肌') {
      return '🦾';
    } else if (muscleGroup === '腿部') {
      return '🦵';
    } else if (muscleGroup === '肩部') {
      return '🤸';
    } else if (muscleGroup === '二头肌') {
      return '💪';
    } else if (muscleGroup === '三头肌') {
      return '💪';
    } else if (muscleGroup === '小腿') {
      return '🦿';
    } else if (muscleGroup === '臀部') {
      return '🍑';
    } else if (muscleGroup === '腹肌') {
      return '🎯';
    }
    return '💪';
  }

  /**
   * 根据肌肉部位名称获取对应背景色
   */
  getMuscleGroupColor(muscleGroup: string): string {
    if (muscleGroup === '胸肌') {
      return '#E57373'; // 红色系
    } else if (muscleGroup === '背肌') {
      return '#64B5F6'; // 蓝色系
    } else if (muscleGroup === '腿部') {
      return '#81C784'; // 绿色系
    } else if (muscleGroup === '肩部') {
      return '#FFB74D'; // 橙色系
    } else if (muscleGroup === '二头肌') {
      return '#BA68C8'; // 紫色系
    } else if (muscleGroup === '三头肌') {
      return '#9575CD'; // 深紫色系
    } else if (muscleGroup === '小腿') {
      return '#4DB6AC'; // 青色系
    } else if (muscleGroup === '臀部') {
      return '#F06292'; // 粉色系
    } else if (muscleGroup === '腹肌') {
      return '#FFD54F'; // 黄色系
    }
    return '#90A4AE'; // 默认灰色
  }
}
