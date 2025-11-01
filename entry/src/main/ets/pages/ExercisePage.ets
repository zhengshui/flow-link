/**
 * 动作库页面 - Exercise
 * 按肌肉部位分组显示训练动作，左右布局
 */

import { ActionModel, MuscleGroupModel, ActionDataService } from '@tbs/common';
import { router } from '@kit.ArkUI';

@Component
export struct ExercisePage {
  @State muscleGroups: MuscleGroupModel[] = []
  @State currentGroupIndex: number = 0
  @State currentActions: ActionModel[] = []

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
    router.pushUrl({
      url: 'pages/ExerciseDetailPage',
      params: {
        actionId: action.id
      }
    }).catch((err: Error) => {
      console.error('跳转失败:', JSON.stringify(err));
    });
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
    .backgroundColor('#F5F5F5')
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
      // 动作缩略图
      Column() {
        Text('🏋️')
          .fontSize(32)
      }
      .width(80)
      .height(80)
      .backgroundColor('#E8E8E8')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 动作信息
      Column({ space: 6 }) {
        Text(action.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Text(action.englishName)
          .fontSize(12)
          .fontColor('#999999')

        Row({ space: 8 }) {
          Text(action.difficulty)
            .fontSize(11)
            .fontColor(Color.White)
            .backgroundColor(this.getDifficultyColor(action.difficulty))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(3)

          if (action.equipment.length > 0) {
            Text('器械: ' + action.equipment)
              .fontSize(11)
              .fontColor('#666666')
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 箭头图标
      Text('>')
        .fontSize(18)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
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
}
