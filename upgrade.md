# FitEasy v1.3.0 升级实施指南（官方计划 / 个人模板 / 计划统计）

## 版本范围
- 从：v1.2.x
- 至：v1.3.0（2025-12-18）

## 变更摘要
- 新增官方计划与个人模板能力：模板查询筛选增强、个人模板创建/编辑/删除/复制。
- 计划进度增强：进度摘要、跳过日、临时调整计划日动作。
- 计划统计扩展：计划维度统计与进度概览接口。
- 数据模型新增字段：`splitType`、`equipment`、`recommendedIntensity`、`intensityHint`、`planDayId`、`completionStatus`、`durationWeeksOverride`、`trainingDaysOverride`、`skippedDays` 等。

## 后端改动清单
1) 接口新增/增强（详见 `API_DOCUMENTATION.md`）
   - 模板：`POST /api/templates/custom`、`POST /api/templates/{id}/duplicate`、`PUT /api/templates/{id}`、`DELETE /api/templates/{id}`，列表查询新增 `splitType/equipment/durationWeeksMin/durationWeeksMax`。
   - 计划：`GET /api/plans/{planId}/progress`、`POST /api/plans/{planId}/skip-day`、`POST /api/plans/{planId}/adjust-day`，`POST /api/plans/from-template` 支持 `durationWeeksOverride/trainingDaysOverride`。
   - 统计：`GET /api/stats/plan`、`GET /api/stats/plan-progress`。
2) 数据模型调整
   - Template: `splitType`、`equipment`、`recommendedIntensity`。
   - TrainingDay: `intensityHint`、`warmupTips`、`cooldownTips`。
   - TrainingRecord: `planDayId`、`completionStatus`。
   - FitnessPlan: `durationWeeksOverride`、`trainingDaysOverride`、`skippedDays`、`totalWeight/totalDuration/totalCalories`。
   - TrainingStats: 可选 `planStats`；新增 `PlanStats` 结构。
3) 数据库迁移建议
   - 模板表：新增字段 `split_type`、`equipment`、`recommended_intensity`。
   - 计划日表：新增 `intensity_hint`、`warmup_tips`、`cooldown_tips`。
   - 训练记录表：新增 `plan_day_id`、`completion_status`（枚举：completed/partial/skipped）。
   - 计划表：新增 `duration_weeks_override`、`training_days_override`（JSON）、`skipped_days`（JSON）、`total_weight`、`total_duration`、`total_calories`。

## 前端改动建议（ArkTS/HarmonyOS）
- 首页：官方计划卡片、个人模板卡片、今日训练/一键完成/跳过。
- 计划中心：官方计划 / 我的计划 / 我的模板 Tab；筛选支持 `goal/level/splitType/equipment/durationWeeks`。
- 计划详情：周/日视图，支持进度摘要、跳过日、临时调整动作，跳转创建训练记录并预填动作。
- 模板编辑：新建/编辑/复制官方模板为个人模板，配置强度提示与热身/放松建议。
- 统计：新增计划维度统计页与列表（完成率、趋势、累计重量/时长/卡路里）。

## 兼容性与回滚
- 新增字段均向后兼容，旧客户端可继续调用原有必需字段。
- 回滚：保留原字段，删除新增接口可能需清理新增表列/数据，建议以灰度方式发布。

## 测试要点
- 模板：创建/编辑/删除/复制官方 → 个人模板；筛选条件组合正确返回。
- 计划：从模板创建计划（覆盖周期/日程），完成日、跳过日、调整日动作，进度摘要正确。
- 训练记录：绑定 `planId/planDayId`，`completionStatus` 取值合法；统计累计正确。
- 统计：`/api/stats/plan` 与 `/api/stats/plan-progress` 数值、分页、状态过滤正确。
- 权限：个人模板接口需登录且仅所有者可修改；计划实例操作需登录。

## 部署步骤（建议）
1) 数据库迁移：按上文新增字段与枚举，确保默认值与非空策略。
2) 后端发布：实现/启用新增接口与查询参数，回归计划/模板/统计相关接口。
3) 前端联调：更新接口定义与模型，验证首页、计划中心、模板、统计全链路。
4) 验证：跑回归用例与新增用例，确认旧版本客户端仍可正常使用基础功能。

## 前端实施完成清单（ArkTS/HarmonyOS）

### 数据模型更新
- `PlanTemplateModel`: 新增 `splitType`、`equipment`、`recommendedIntensity`、`isOfficial`、`userId` 字段
- `TrainingDayModel`: 新增 `intensityHint`、`warmupTips`、`cooldownTips` 字段
- `FitnessPlanModel`: 新增 `durationWeeksOverride`、`trainingDaysOverride`、`skippedDays`、`totalWeight`、`totalDuration`、`totalCalories` 字段
- `TrainingRecordModel`: 新增 `planDayId`、`completionStatus` 字段
- 新增 `PlanProgressModel`、`PlanProgressItemModel` 模型
- 新增常量类：`SplitTypeConst`、`EquipmentTypeConst`、`CompletionStatusConst`

### API 服务更新
- `PlanApiService.getPlanTemplates`: 支持 `splitType`、`equipment`、`durationWeeksMin`、`durationWeeksMax`、`isOfficial` 查询参数
- 新增 `createCustomTemplate`: 创建个人模板
- 新增 `duplicateTemplate`: 复制官方模板为个人模板
- 新增 `updateTemplate`: 更新个人模板
- 新增 `deleteTemplate`: 删除个人模板
- 新增 `getPlanProgress`: 获取计划进度摘要
- 新增 `skipPlanDay`: 跳过计划日
- 新增 `adjustPlanDay`: 临时调整计划日动作

### 新增页面
- `PlanCenterPage`: 计划中心页面（官方计划/我的计划/我的模板 Tab）
- `PlanDetailPage`: 计划详情页（周/日视图、进度、跳过/完成/开始训练）
- `TemplateDetailPage`: 模板详情页（使用模板创建计划、复制为个人模板）
- `TemplateEditorPage`: 模板编辑页（创建/编辑个人模板）

### 新增组件
- `OfficialPlanList`: 官方计划列表（筛选、分页）
- `MyPlanList`: 我的计划列表（状态筛选）
- `MyTemplateList`: 我的模板列表（创建、编辑、删除）
- `PlanCard`: 计划卡片（进度条、统计信息）
- `TemplateCard`: 模板卡片（标签、使用按钮）
- `PlanFilterPanel`: 筛选面板（目标、等级、分化、器械）

### 首页增强
- 「我的训练计划」卡片：新增「查看详情」按钮，跳转计划详情页
- 「官方训练模板」卡片：点击跳转模板详情，新增「进入计划中心」按钮
- 模板卡片：展示 `splitType`、`equipment` 标签

### 路由注册
- `PlanCenterPage`、`PlanDetailPage`、`TemplateDetailPage`、`TemplateEditorPage` 已注册至 `route_map.json`
- `NavRoutes` 常量类已添加对应路由名

## 已更新文档
- `API_DOCUMENTATION.md` 版本号 v1.3.0，新增接口与模型字段已记录。
- `upgrade.md` 前端实施清单已记录。

