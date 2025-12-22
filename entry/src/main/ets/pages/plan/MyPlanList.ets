/**
 * 我的计划列表组件
 * 展示用户创建的健身计划
 */
import {
  FitnessPlanModel,
  PlanApiService,
  toast,
  RouterManager,
  NavRoutes
} from '@tbs/common';
import { ResponseResult } from '@tbs/common/src/main/ets/http/response';
import { PlanCard } from './PlanCard';

@Component
export struct MyPlanList {
  @State plans: FitnessPlanModel[] = [];
  @State isLoading: boolean = false;
  @State selectedStatus: string = '';
  @State currentPage: number = 1;
  @State hasMore: boolean = true;
  private pageSize: number = 10;

  // 状态选项
  private statusOptions: string[] = ['全部', '进行中', '已完成', '已暂停', '已归档'];

  aboutToAppear(): void {
    this.loadPlans(true);
  }

  /**
   * 加载计划列表
   */
  async loadPlans(refresh: boolean = false): Promise<void> {
    if (this.isLoading) {
      return;
    }

    if (refresh) {
      this.currentPage = 1;
      this.hasMore = true;
      this.plans = [];
    }

    if (!this.hasMore && !refresh) {
      return;
    }

    this.isLoading = true;
    try {
      const res: ResponseResult = await PlanApiService.getFitnessPlans(
        this.currentPage,
        this.pageSize,
        this.selectedStatus
      );

      if (res.code === 0 && res.data) {
        const apiData: Record<string, Object> = res.data as Record<string, Object>;
        const plansArray: Object[] = apiData['plans'] as Object[] ?? [];
        const total: number = apiData['total'] as number ?? 0;

        const newPlans: FitnessPlanModel[] = [];
        for (let i = 0; i < plansArray.length; i++) {
          newPlans.push(plansArray[i] as FitnessPlanModel);
        }

        if (refresh) {
          this.plans = newPlans;
        } else {
          this.plans = this.plans.concat(newPlans);
        }

        this.hasMore = this.plans.length < total;
        this.currentPage++;
      }
    } catch (err) {
      console.error('加载我的计划失败:', JSON.stringify(err));
      toast('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 状态筛选变化处理
   */
  onStatusChange(status: string): void {
    this.selectedStatus = status === '全部' ? '' : status;
    this.loadPlans(true);
  }

  /**
   * 查看计划详情
   */
  viewPlanDetail(plan: FitnessPlanModel): void {
    RouterManager.pushPath(NavRoutes.PLAN_DETAIL, { planId: plan.id });
  }

  build() {
    Column({ space: 12 }) {
      // 状态筛选
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.statusOptions, (status: string) => {
            Text(status)
              .fontSize(13)
              .fontColor(this.isStatusSelected(status) ? Color.White : $r('app.color.text_secondary'))
              .backgroundColor(this.isStatusSelected(status) ?
                $r('app.color.brand_primary') : $r('app.color.card_background_secondary'))
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .borderRadius(18)
              .onClick(() => {
                this.onStatusChange(status);
              })
          })
        }
        .padding({ left: 4, right: 4 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      // 计划列表
      if (this.plans.length > 0) {
        List({ space: 12 }) {
          ForEach(this.plans, (plan: FitnessPlanModel) => {
            ListItem() {
              PlanCard({
                plan: plan,
                onTap: (): void => {
                  this.viewPlanDetail(plan);
                }
              })
            }
          }, (plan: FitnessPlanModel): string => plan.id.toString())

          // 加载更多
          if (this.hasMore) {
            ListItem() {
              Row() {
                if (this.isLoading) {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                    .color($r('app.color.brand_primary'))
                  Text('加载中...')
                    .fontSize(13)
                    .fontColor($r('app.color.text_hint'))
                    .margin({ left: 8 })
                } else {
                  Text('加载更多')
                    .fontSize(13)
                    .fontColor($r('app.color.brand_primary'))
                }
              }
              .width('100%')
              .height(48)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                if (!this.isLoading) {
                  this.loadPlans(false);
                }
              })
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else if (!this.isLoading) {
        // 空状态
        Column({ space: 16 }) {
          Text('暂无训练计划')
            .fontSize(15)
            .fontColor($r('app.color.text_hint'))

          Text('从官方模板创建您的专属计划')
            .fontSize(13)
            .fontColor($r('app.color.text_placeholder'))

          Button('浏览官方计划')
            .width(140)
            .height(40)
            .fontSize(14)
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(20)
            .margin({ top: 8 })
            .onClick(() => {
              // 切换到官方计划 Tab（由父组件处理）
              toast('请切换到官方计划标签');
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 加载中
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color($r('app.color.brand_primary'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 判断状态是否被选中
   */
  isStatusSelected(status: string): boolean {
    if (status === '全部' && this.selectedStatus === '') {
      return true;
    }
    return status === this.selectedStatus;
  }
}

