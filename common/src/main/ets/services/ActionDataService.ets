/**
 * 动作数据服务 - ActionDataService
 * 基于 action.json5 提供训练动作数据
 */

import { ActionModel, MuscleGroupModel, MuscleGroupConst } from '../model/ActionModel';

export class ActionDataService {
  /**
   * 获取所有肌肉部位分组
   */
  static getAllMuscleGroups(): MuscleGroupModel[] {
    const groups: MuscleGroupModel[] = [];

    // 胸肌
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.CHEST,
      MuscleGroupConst.getChineseName(MuscleGroupConst.CHEST),
      'Chest',
      '',
      ActionDataService.getChestActions()
    ));

    // 背肌
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.BACK,
      MuscleGroupConst.getChineseName(MuscleGroupConst.BACK),
      'Back',
      '',
      ActionDataService.getBackActions()
    ));

    // 腿部
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.LEGS,
      MuscleGroupConst.getChineseName(MuscleGroupConst.LEGS),
      'Legs',
      '',
      ActionDataService.getLegsActions()
    ));

    // 肩部
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.SHOULDERS,
      MuscleGroupConst.getChineseName(MuscleGroupConst.SHOULDERS),
      'Shoulders',
      '',
      ActionDataService.getShouldersActions()
    ));

    // 二头肌
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.BICEPS,
      MuscleGroupConst.getChineseName(MuscleGroupConst.BICEPS),
      'Biceps',
      '',
      ActionDataService.getBicepsActions()
    ));

    // 三头肌
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.TRICEPS,
      MuscleGroupConst.getChineseName(MuscleGroupConst.TRICEPS),
      'Triceps',
      '',
      ActionDataService.getTricepsActions()
    ));

    // 小腿
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.CALVES,
      MuscleGroupConst.getChineseName(MuscleGroupConst.CALVES),
      'Calves',
      '',
      ActionDataService.getCalvesActions()
    ));

    // 臀部
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.GLUTES,
      MuscleGroupConst.getChineseName(MuscleGroupConst.GLUTES),
      'Glutes',
      '',
      ActionDataService.getGlutesActions()
    ));

    // 腹肌
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.ABS,
      MuscleGroupConst.getChineseName(MuscleGroupConst.ABS),
      'Abs',
      '',
      ActionDataService.getAbsActions()
    ));

    // 有氧
    groups.push(new MuscleGroupModel(
      MuscleGroupConst.CARDIO,
      MuscleGroupConst.getChineseName(MuscleGroupConst.CARDIO),
      'Cardio',
      '',
      ActionDataService.getCardioActions()
    ));

    return groups;
  }

  /**
   * 根据肌肉部位ID获取动作列表
   */
  static getActionsByMuscleGroup(muscleGroupId: string): ActionModel[] {
    if (muscleGroupId === MuscleGroupConst.CHEST) {
      return ActionDataService.getChestActions();
    } else if (muscleGroupId === MuscleGroupConst.BACK) {
      return ActionDataService.getBackActions();
    } else if (muscleGroupId === MuscleGroupConst.LEGS) {
      return ActionDataService.getLegsActions();
    } else if (muscleGroupId === MuscleGroupConst.SHOULDERS) {
      return ActionDataService.getShouldersActions();
    } else if (muscleGroupId === MuscleGroupConst.BICEPS) {
      return ActionDataService.getBicepsActions();
    } else if (muscleGroupId === MuscleGroupConst.TRICEPS) {
      return ActionDataService.getTricepsActions();
    } else if (muscleGroupId === MuscleGroupConst.CALVES) {
      return ActionDataService.getCalvesActions();
    } else if (muscleGroupId === MuscleGroupConst.GLUTES) {
      return ActionDataService.getGlutesActions();
    } else if (muscleGroupId === MuscleGroupConst.ABS) {
      return ActionDataService.getAbsActions();
    } else if (muscleGroupId === MuscleGroupConst.CARDIO) {
      return ActionDataService.getCardioActions();
    }
    return [];
  }

  /**
   * 根据动作ID获取动作详情
   */
  static getActionById(actionId: string): ActionModel | null {
    const allGroups: MuscleGroupModel[] = ActionDataService.getAllMuscleGroups();
    for (let i: number = 0; i < allGroups.length; i++) {
      const actions: ActionModel[] = allGroups[i].actions;
      for (let j: number = 0; j < actions.length; j++) {
        if (actions[j].id === actionId) {
          return actions[j];
        }
      }
    }
    return null;
  }

  // ===== 各部位动作 =====

  private static getChestActions(): ActionModel[] {
    return [
      new ActionModel('chest_1', '下斜哑铃飞鸟', 'Decline Dumbbell Fly', '胸肌', '', '', '下斜哑铃飞鸟针对下胸部，帮助塑造胸肌下沿线条和整体轮廓。', ['调整卧推凳至15-30度下斜角', '平躺后双手各持哑铃', '将哑铃举至胸部上方，掌心相对', '保持肘部微屈，向两侧展开手臂', '感受胸肌拉伸后，收缩胸肌将哑铃推回'], '中级', '哑铃', ['动作要缓慢控制', '专注下胸收缩'], 'chest/decline_dumbbell_fly.gif'),
      new ActionModel('chest_2', '哑铃卧推', 'Dumbbell Bench Press', '胸肌', '', '', '哑铃卧推相比杠铃卧推有更大的运动范围，能更好地刺激胸肌。', ['平躺在卧推凳上，双手各持一个哑铃', '将哑铃举至胸部上方，掌心相对', '缓慢下降哑铃至胸部两侧', '用力推起哑铃至起始位置'], '中级', '哑铃', ['保持核心稳定', '控制哑铃下降速度'], 'chest/dumbbell_bench_press.gif'),
      new ActionModel('chest_3', '上斜卧推', 'Incline Bench Press', '胸肌', '', '', '上斜卧推主要针对上胸部肌肉，帮助塑造完美的胸部线条。', ['调整卧推凳至30-45度角', '平躺后双手握杠，手距略宽于肩', '将杠铃推至胸部上方', '缓慢下降至上胸部位置', '用力推回起始位置'], '中级', '杠铃', ['角度不宜过大', '注意肩部稳定性'], 'chest/incline_bench_press.gif'),
      new ActionModel('chest_4', '下斜卧推', 'Decline Bench Press', '胸肌', '', '', '下斜卧推主要针对下胸部肌肉，增加胸肌的厚度。', ['调整卧推凳至15-30度下斜角', '固定双脚，平躺在凳上', '双手握杠推至胸部上方', '缓慢下降至下胸部', '用力推回起始位置'], '中级', '杠铃', ['确保身体稳定', '控制动作节奏'], 'chest/decline_bench_press.gif'),
      new ActionModel('chest_5', '哑铃飞鸟', 'Dumbbell Fly', '胸肌', '', '', '哑铃飞鸟是孤立训练胸肌的经典动作，能有效拉伸和收缩胸肌。', ['平躺在卧推凳上，双手各持哑铃', '将哑铃举至胸部上方，掌心相对', '保持肘部微屈，向两侧展开手臂', '感受胸肌拉伸后，收缩胸肌将哑铃推回'], '中级', '哑铃', ['动作要缓慢控制', '不要完全伸直手臂'], 'chest/dumbbell_fly.gif'),
      new ActionModel('chest_6', '上斜哑铃飞鸟', 'Incline Dumbbell Fly', '胸肌', '', '', '上斜哑铃飞鸟针对上胸部，帮助塑造饱满的上胸线条。', ['调整卧推凳至30-45度角', '平躺后双手各持哑铃', '将哑铃举至胸部上方', '保持肘部微屈，向两侧展开', '收缩上胸肌将哑铃推回'], '中级', '哑铃', ['保持肩部稳定', '专注上胸发力'], 'chest/incline_dumbbell_fly.gif'),
      new ActionModel('chest_7', '俯卧撑', 'Push-ups', '胸肌', '', '', '俯卧撑是经典的自重训练动作，随时随地都可以进行。', ['俯卧在地面，双手撑地，略宽于肩', '身体保持一条直线', '弯曲手臂，降低身体至接近地面', '用力撑起身体回到起始位置'], '初级', '自重', ['保持核心收紧', '身体不要塌腰'], 'chest/push_ups.gif'),
      new ActionModel('chest_8', '双杠臂屈伸', 'Dips', '胸肌', '', '', '双杠臂屈伸是训练下胸部和三头肌的复合动作。', ['双手撑在双杠上，身体悬空', '身体前倾约15-20度', '弯曲手臂，降低身体', '用力撑起身体回到起始位置'], '中级', '双杠', ['身体前倾针对胸肌', '下降不要过低'], 'chest/dips.gif'),
      new ActionModel('chest_9', '蝴蝶机夹胸', 'Pec Deck Fly', '胸肌', '', '', '蝴蝶机夹胸是孤立训练胸肌中缝的有效动作。', ['坐在蝴蝶机上，背部贴紧靠背', '双手握住把手，肘部放在垫片上', '用力将把手向中间夹紧', '缓慢还原至起始位置'], '初级', '器械', ['保持肘部固定', '专注胸肌收缩'], 'chest/pec_deck_fly.gif'),
      new ActionModel('chest_10', '绳索夹胸', 'Cable Crossover', '胸肌', '', '', '绳索夹胸通过绳索提供持续张力，有效训练胸肌中缝和整体胸部轮廓。', ['站在绳索机中间，双手各握一个把手', '身体微微前倾，保持核心稳定', '双臂向前下方夹紧，在胸前交叉', '缓慢还原至起始位置'], '中级', '器械', ['保持肘部微屈', '专注胸肌挤压'], 'chest/cable_crossover.gif'),
      new ActionModel('chest_11', '器械推胸', 'Chest Press Machine', '胸肌', '', '', '器械推胸是安全稳定的胸部训练动作，固定轨迹适合新手和大重量训练。', ['坐在器械上，背部贴紧靠背', '调整座椅高度，使把手与胸部齐平', '双手握住把手，向前推出', '缓慢还原至起始位置'], '初级', '器械', ['背部贴紧靠背', '不要完全锁死肘部'], 'chest/chest_press_machine.gif'),
      new ActionModel('chest_12', '低位绳索夹胸', 'Low Cable Fly', '胸肌', '', '', '低位绳索夹胸通过由下往上的弧线轨迹，重点刺激胸肌下沿和胸沟线条。', ['将绳索滑轮调至低位并安装手柄', '站在机器中央，一脚在前保持稳定', '双臂从身体两侧向前上方划弧合拢', '在顶点挤压胸肌停顿1秒', '保持张力缓慢还原至起始位置'], '中级', '绳索', ['肘部保持微屈', '全程控制动作速度'], 'chest/low_cable_fly.gif'),
      new ActionModel('chest_13', '器械蝴蝶夹胸', 'Machine Pec Fly', '胸肌', '', '', '器械蝴蝶夹胸借助固定轨迹孤立胸大肌，适合在训练末尾强化胸肌挤压。', ['调整座椅高度使手柄与胸同高', '前臂贴在垫片上，肘部约90度', '胸肌发力将手臂向前夹紧', '在胸前停顿感受收缩', '缓慢还原保持张力'], '初级', '器械', ['背部贴紧靠背', '顶点不要放松张力'], 'chest/machine_pec_fly.gif'),
      new ActionModel('chest_14', '悍马机推胸', 'Hammer Strength Chest Press', '胸肌', '', '', '悍马机推胸提供左右独立的推举轨迹，帮助平衡左右胸肌并安全使用大重量。', ['调整座椅让手柄与胸中线齐平', '背部贴靠垫，双脚稳踩地面', '双手握住手柄，胸肌发力向前推', '手臂接近伸直时停顿', '控制重量缓慢还原'], '中级', '悍马机', ['保持肩胛后缩', '不要锁死肘关节'], 'chest/hammer_strength_chest_press.gif'),
      new ActionModel('chest_15', '器械推胸（板式）', 'Plate Loaded Chest Press', '胸肌', '', '', '板式器械推胸拥有可加载杠片的稳定轨迹，适合安全地进行大重量胸部训练。', ['坐在器械上背部贴紧靠背', '调整座椅使手柄与胸部齐平', '双手握住手柄，掌心向前', '胸肌发力推至手臂伸直', '缓慢还原保持张力'], '中级', '器械', ['双脚稳踩地面', '整个动作保持肩胛收紧'], 'chest/plate_loaded_chest_press.gif'),
      new ActionModel('chest_16', '器械推胸（单臂）', 'Single-Arm Machine Chest Press', '胸肌', '', '', '单臂器械推胸可以专注单侧胸肌，矫正力量不均并提升稳定性。', ['坐在器械上，背部贴紧靠背', '单手握住手柄，另一手扶住大腿稳定身体', '保持肩胛后缩，胸肌发力推至手臂伸直', '在顶点停顿后缓慢还原', '完成次数后换另一侧'], '中级', '器械', ['避免身体扭转', '肘部保持与肩同高'], 'chest/single_arm_machine_chest_press.gif'),
      new ActionModel('chest_17', '坐姿绳索夹胸', 'Seated Cable Fly', '胸肌', '', '', '坐姿绳索夹胸利用凳子固定下半身，帮助集中感受胸肌挤压与持续张力。', ['将凳子置于两侧绳索正中并调至肩高', '坐下微微前倾，双手握住手柄', '胸肌发力将手臂在胸前合拢', '顶点停顿挤压胸肌', '缓慢展开手臂但保持张力'], '中级', '绳索', ['肩胛骨保持后缩', '不要让重量堆撞暂停'], 'chest/seated_cable_fly.gif'),
      new ActionModel('chest_18', '绳索夹胸', 'Cable Chest Fly', '胸肌', '', '', '绳索夹胸提供全程张力，能够塑造胸肌外沿并提升胸肌控制力。', ['将滑轮调至胸肩高度', '站在机器中央，双臂略弯', '沿弧线将手柄在胸前合拢', '停顿挤压后缓慢还原', '保持核心紧绷防止身体晃动'], '中级', '绳索', ['轨迹呈自然弧线', '肘部始终微屈'], 'chest/cable_chest_fly.gif'),
      new ActionModel('chest_19', '绳索十字夹胸', 'Cable Cross Fly', '胸肌', '', '', '绳索十字夹胸在胸前交叉手臂，能进一步强化胸肌内侧的挤压感。', ['站在绳索机中间，双手各握手柄', '身体略前倾保持核心稳定', '沿对角线向下划弧并在胸前交叉', '在交叉位置停顿挤压', '缓慢还原至起始位置'], '中级', '绳索', ['交叉幅度适中即可', '控制回程避免反弹'], 'chest/cable_cross_fly.gif'),
      new ActionModel('chest_20', '绳索夹胸（单臂）', 'Single-Arm Cable Fly', '胸肌', '', '', '单臂绳索夹胸能够单侧训练，加强胸肌与核心的协调控制。', ['站在绳索机侧面，单手握住手柄', '另一手扶住髋部保持稳定', '胸肌发力将手柄向身体前方划弧', '在顶点挤压胸肌停顿', '缓慢还原后换另一侧'], '中级', '绳索', ['躯干保持正直', '每次动作都集中挤压胸肌'], 'chest/single_arm_cable_fly.gif'),
      new ActionModel('chest_21', '单手俯卧撑', 'One-arm Push-up', '胸肌', '', '', '单手俯卧撑是高阶自重动作，能大幅提升胸肌与核心的稳定控制能力。', ['两脚分开加宽，双手撑地', '将重心移至支撑手，另一手可置于背后', '保持身体呈一直线缓慢下降', '胸部接近地面后用力推回', '换手训练另一侧'], '高级', '自重', ['收紧核心避免骨盆旋转', '下降节奏要可控'], 'chest/one_arm_push_up.gif'),
      new ActionModel('chest_22', '高位俯卧撑', 'Incline Push-up', '胸肌', '', '', '高位俯卧撑通过抬高手掌降低难度，适合作为胸肌热身或新手入门动作。', ['双手撑在训练凳或盒子上', '身体保持一直线，脚跟并拢', '弯曲手肘降低胸部靠近支撑面', '推回到起始位置并完全伸展手臂'], '初级', '自重', ['肩胛骨保持稳定', '避免腰部塌陷'], 'chest/elevated_push_up.gif')
    ];
  }

  private static getBackActions(): ActionModel[] {
    return [
      new ActionModel('back_1', '引体向上', 'Pull-ups', '背肌', '', '', '引体向上是训练背部肌肉的王牌动作，主要锻炼背阔肌和肱二头肌。', ['双手握杠，手距略宽于肩', '身体悬垂，保持核心稳定', '拉起身体直至下巴过杠', '缓慢下降至起始位置'], '高级', '单杠', ['避免身体摆动', '背部主动发力'], 'back/pull_ups.gif'),
      new ActionModel('back_2', '高位下拉', 'Lat Pulldown', '背肌', '', '', '高位下拉是引体向上的替代动作，适合力量不足的训练者。', ['坐在器械上，双手握住横杆', '身体微微后倾', '拉动横杆至胸部上方', '缓慢还原'], '初级', '器械', ['背部主导发力', '不要过度后仰'], 'back/lat_pulldown.gif'),
      new ActionModel('back_3', '杠铃划船', 'Barbell Row', '背肌', '', '', '杠铃划船是增加背部厚度的经典动作。', ['站立，膝盖微屈，上身前倾', '双手握杠，比肩略宽', '将杠铃拉向下腹部', '缓慢下放杠铃'], '中级', '杠铃', ['保持背部平直', '避免用腰发力'], 'back/barbell_row.gif'),
      new ActionModel('back_4', '哑铃单臂划船', 'One-arm Dumbbell Row', '背肌', '', '', '单臂划船能够孤立训练单侧背肌，纠正肌力不平衡。', ['一手撑在凳子上，另一手持哑铃', '上身与地面平行', '将哑铃拉向腰部', '缓慢下放哑铃'], '初级', '哑铃', ['保持身体稳定', '背肌主动收缩'], 'back/one_arm_dumbbell_row.gif'),
      new ActionModel('back_5', 'T杠划船', 'T-bar Row', '背肌', '', '', 'T杠划船能够使用较大重量，有效增加背部肌肉厚度。', ['站在T杠一端，双脚跨立', '俯身握住手柄', '将T杠拉向胸部', '缓慢下放'], '中级', 'T杠', ['核心保持稳定', '背部收紧发力'], 'back/t_bar_row.gif'),
      new ActionModel('back_6', '哑铃俯身划船', 'Bent Over Dumbbell Row', '背肌', '', '', '哑铃俯身划船双手同时训练，能有效增加背部厚度和宽度。', ['站立，膝盖微屈，上身前倾约45度', '双手各持哑铃，自然下垂', '将哑铃拉向腰部两侧', '缓慢下放还原'], '中级', '哑铃', ['保持背部平直', '肩胛骨主动收缩'], 'back/bent_over_dumbbell_row.gif'),
      new ActionModel('back_7', '器械背部伸展', 'Back Extension Machine', '背肌', '', '', '器械背部伸展训练下背部竖脊肌，增强脊柱稳定性。', ['俯卧在背部伸展机上', '双脚固定，髋部靠在垫子上', '上身下降至与地面垂直', '背部发力抬起上身至水平'], '初级', '器械', ['动作缓慢控制', '不要过度后仰'], 'back/back_extension_machine.gif'),
      new ActionModel('back_8', '硬拉', 'Deadlift', '背肌', '', '', '硬拉是力量训练的基础动作，训练整个后链肌群。', ['站立，双脚与肩同宽', '俯身握杠，手臂自然下垂', '挺胸收腹，腿部发力', '拉起杠铃至身体直立', '保持背部平直，缓慢下放'], '高级', '杠铃', ['保持背部平直', '用腿部发力，不是腰'], 'back/deadlift.gif'),
      new ActionModel('back_9', '下拉绳索划船', 'Cable Seated Row', '背肌', '', '', '坐姿绳索划船能够保持背部持续张力，提高训练效果。', ['坐在器械上，双脚踩住踏板', '双手握住把手', '保持背部直立，向腹部拉动绳索', '缓慢还原'], '初级', '器械', ['背部保持直立', '肩胛骨主动收缩'], 'back/cable_seated_row.gif'),
      new ActionModel('back_10', '坐姿绳索单臂划船', 'Seated Cable One-Arm Row', '背肌', '', '', '坐姿绳索单臂划船能够孤立训练单侧背肌，纠正两侧力量不平衡。', ['坐在绳索划船机上', '一手握住把手', '保持背部直立，向腰部拉动绳索', '缓慢还原后换另一侧'], '初级', '器械', ['保持核心稳定', '专注单侧背肌收缩'], 'back/seated_cable_one_arm_row.gif'),
      new ActionModel('back_11', '山羊挺身', 'Back Hyperextension', '背肌', '', '', '山羊挺身是训练下背部竖脊肌的经典动作，增强脊柱稳定性和核心力量。', ['俯卧在罗马椅上，髋部在垫子边缘', '双手交叉放在胸前或头后', '上身缓慢下降', '下背发力抬起上身至与腿部成一直线'], '初级', '器械', ['不要过度后仰', '动作缓慢控制'], 'back/back_hyperextension.gif'),
      new ActionModel('back_12', '负重背部伸展', 'Weighted Back Extension', '背肌', '', '', '负重背部伸展在山羊挺身基础上增加负重，更有效地增强下背部力量。', ['俯卧在罗马椅上，髋部在垫子边缘', '双手持重物置于胸前', '上身缓慢下降', '下背发力抬起上身'], '中级', '器械/哑铃', ['负重适中', '保持动作质量'], 'back/weighted_back_extension.gif'),
      new ActionModel('back_13', '固定山羊挺', 'Fixed Hyperextension', '背肌', '', '', '固定山羊挺借助固定支撑保护髋部，集中训练竖脊肌和臀后链，提升下背稳定性。', ['调整器械高度让髋骨贴在垫子上缘', '双脚固定于脚踏，双臂交叉抱胸', '保持背部中立缓慢下放上身', '下背与臀部发力抬起至身体成一直线', '在顶点停顿后重复动作'], '初级', '器械', ['腰椎保持中立', '全过程避免弹起反弹'], 'back/fixed_hyperextension.gif'),
      new ActionModel('back_14', '哑铃硬拉', 'Dumbbell Deadlift', '背肌', '', '', '哑铃硬拉能在保持自然轨迹的同时锻炼整个后链，适合家庭与小空间训练。', ['双脚与髋同宽站立，双手各握一只哑铃', '髋关节主导发力，向后坐臀并前倾', '保持脊柱中立，哑铃沿腿前下降至小腿中部', '感受腘绳肌拉伸后收紧臀背站起'], '中级', '哑铃', ['全程保持脊柱中立', '动作节奏要可控'], 'back/dumbbell_deadlift.gif')
    ];
  }

  private static getLegsActions(): ActionModel[] {
    return [
      new ActionModel('legs_1', '深蹲', 'Squat', '腿部', '', '', '深蹲是下肢训练的王牌动作，全面锻炼腿部肌群。', ['双脚与肩同宽站立', '杠铃放在斜方肌上', '保持背部挺直，向下蹲', '大腿与地面平行后站起'], '中级', '杠铃', ['膝盖不要超过脚尖', '保持核心收紧'], 'legs/squat.gif'),
      new ActionModel('legs_2', '弓步蹲', 'Lunge', '腿部', '', '', '弓步蹲能够单独训练每条腿，改善肌力不平衡。', ['站立，一脚向前迈出', '下蹲至前腿大腿与地面平行', '后腿膝盖接近地面', '站起回到起始位置'], '初级', '自重/哑铃', ['保持上身直立', '前膝不要超过脚尖'], 'legs/lunge.gif'),
      new ActionModel('legs_3', '颈前深蹲', 'Front Squat', '腿部', '', '', '颈前深蹲将杠铃置于身体前方，更多刺激股四头肌和核心肌群。', ['双脚与肩同宽站立', '杠铃放在锁骨和前三角肌上', '双臂交叉或架起固定杠铃', '保持背部挺直，下蹲至大腿与地面平行', '站起回到起始位置'], '高级', '杠铃', ['保持手肘抬高', '核心全程收紧'], 'legs/front_squat.gif'),
      new ActionModel('legs_4', '腿举', 'Leg Press', '腿部', '', '', '腿举能够使用大重量，有效增加腿部肌肉力量。', ['坐在腿举机上', '双脚放在踏板上，与肩同宽', '解除安全锁，下降踏板', '腿部发力推起踏板'], '初级', '器械', ['不要完全锁死膝盖', '下降时膝盖不要内扣'], 'legs/leg_press.gif'),
      new ActionModel('legs_5', '腿弯举', 'Leg Curl', '腿部', '', '', '腿弯举孤立训练腘绳肌，塑造腿部后侧线条。', ['俯卧在腿弯举机上', '脚踝钩住滚轮', '弯曲膝盖，将滚轮拉向臀部', '缓慢还原'], '初级', '器械', ['避免借力', '专注腘绳肌收缩'], 'legs/leg_curl.gif'),
      new ActionModel('legs_6', '直腿硬拉', 'Stiff-leg Deadlift', '腿部', '', '', '直腿硬拉强调腘绳肌的拉伸和收缩。', ['站立，双腿伸直', '俯身握杠', '保持腿部伸直，上身前倾', '感受腘绳肌拉伸后站起'], '中级', '杠铃', ['腿部不要完全锁死', '背部保持平直'], 'legs/stiff_leg_deadlift.gif'),
      new ActionModel('legs_7', '保加利亚分腿蹲', 'Bulgarian Split Squat', '腿部', '', '', '保加利亚分腿蹲能够更好地孤立训练单腿，提高平衡能力。', ['后脚放在凳子上', '前脚向前迈出', '下蹲至前腿大腿与地面平行', '站起回到起始位置'], '中级', '哑铃', ['保持身体平衡', '前膝对准脚尖'], 'legs/bulgarian_split_squat.gif'),
      new ActionModel('legs_8', '徒手深蹲', 'Bodyweight Squat', '腿部', '', '', '徒手深蹲是最基础的下肢训练动作，适合热身和新手入门。', ['双脚与肩同宽站立', '双手向前伸直或抱胸', '保持背部挺直，向下蹲', '大腿与地面平行后站起'], '初级', '自重', ['膝盖跟随脚尖方向', '保持核心收紧'], 'legs/bodyweight_squat.gif'),
      new ActionModel('legs_9', '坐姿腿弯举', 'Seated Leg Curl', '腿部', '', '', '坐姿腿弯举在坐姿下孤立训练腘绳肌，更安全稳定。', ['坐在腿弯举机上', '膝盖对齐转轴', '脚踝钩住滚轮', '弯曲膝盖向下拉', '缓慢还原'], '初级', '器械', ['保持上身稳定', '专注腘绳肌收缩'], 'legs/seated_leg_curl.gif'),
      new ActionModel('legs_10', '史密斯深蹲', 'Smith Machine Squat', '腿部', '', '', '史密斯深蹲使用固定轨迹，更安全稳定，适合新手和大重量训练。', ['站在史密斯机杠铃下', '杠铃放在斜方肌上', '双脚略向前站', '保持背部挺直，下蹲', '腿部发力站起'], '初级', '器械', ['脚位可以调整训练重点', '不要完全锁死膝盖'], 'legs/smith_machine_squat.gif'),
      new ActionModel('legs_11', '保加利亚蹲', 'Bulgarian Squat', '腿部', '', '', '保加利亚蹲是前侧脚落地、后脚抬高的分腿深蹲，能集中强化单腿力量和平衡。', ['前脚站稳，后脚放在凳子上', '保持胸口抬起向下屈膝', '前膝约90度时暂停', '通过前脚脚跟发力站起'], '中级', '自重/哑铃', ['前膝始终对准脚尖', '保持核心收紧避免摇晃'], 'legs/bulgarian_squat.gif'),
      new ActionModel('legs_12', '单腿深蹲', 'Pistol Squat', '腿部', '', '', '单腿深蹲对腿部力量和踝关节稳定性要求极高，可显著提升平衡能力。', ['站立抬起一条腿向前伸直', '双手向前伸保持平衡', '另一条腿缓慢下蹲至臀部接近脚跟', '脚跟发力站起并保持上身挺直'], '高级', '自重', ['动作全程保持脚跟着地', '必要时可扶物辅助'], 'legs/pistol_squat.gif'),
      new ActionModel('legs_13', '杠铃单腿蹲', 'Barbell Single-Leg Squat', '腿部', '', '', '杠铃单腿蹲在背上负重的同时训练单腿力量，对臀腿稳定性挑战较大。', ['杠铃置于斜方肌，单腿站立', '另一条腿向前伸直保持悬空', '控制身体下蹲至大腿接近平行', '脚跟发力站起并维持平衡'], '高级', '杠铃', ['全程收紧核心', '动作幅度以稳定为前提'], 'legs/barbell_single_leg_squat.gif'),
      new ActionModel('legs_14', '地雷单脚蹲', 'Landmine Single-Leg Squat', '腿部', '', '', '地雷单脚蹲借助地雷杆的引导轨迹，既能增加负重又可保持平衡。', ['将杠铃固定在地雷架上，双手抱住杠端', '单腿站立，另一腿前伸', '身体向下蹲同时让杠铃沿弧线下降', '脚跟发力回到起始位置'], '中级', '地雷杠', ['保持躯干直立', '杠铃贴近身体移动'], 'legs/landmine_single_leg_squat.gif'),
      new ActionModel('legs_15', '器械深蹲', 'Machine Squat', '腿部', '', '', '器械深蹲通过轨道限制提供额外支撑，适合作为大重量训练或新手入门。', ['进入器械深蹲机，肩部置于垫下', '双脚与肩同宽站在踏板上', '屈膝下蹲至大腿平行', '双腿发力推回起始位置'], '初级', '器械', ['膝盖方向与脚尖一致', '不要让重量撞击限位'], 'legs/machine_squat.gif'),
      new ActionModel('legs_16', '罗马蹲', 'Roman Squat', '腿部', '', '', '罗马蹲（Sissy Squat）专注锻炼股四头肌，能在小范围动作中提升股四头肌泵感。', ['将脚固定在罗马蹲器械或楔块上', '身体后倾并保持髋部伸直', '弯曲膝盖让身体向后下降', '大腿前侧发力将身体拉回'], '中级', '器械/自重', ['保持躯干与大腿呈一直线', '注意膝盖不要内扣'], 'legs/roman_squat.gif'),
      new ActionModel('legs_17', '直腿杠铃硬拉', 'Barbell Stiff-leg Deadlift', '腿部', '', '', '直腿杠铃硬拉以腿后肌群和臀部为主，适合在腿后链训练日加深拉伸刺激。', ['双脚与肩同宽站立，双手正握杠铃', '腿部几乎伸直，髋部后移前倾', '杠铃沿腿部下降至小腿中段', '收紧腘绳肌和臀部站起'], '中级', '杠铃', ['下放时保持杠铃贴近腿部', '避免下背弯曲'], 'legs/barbell_stiff_leg_deadlift.gif'),
      new ActionModel('legs_18', '地雷直腿硬拉', 'Landmine Stiff-leg Deadlift', '腿部', '', '', '地雷直腿硬拉利用地雷杠的固定轴，帮助在直腿硬拉中保持稳定轨迹。', ['将杠铃前端插入地雷架，双手握住杠端', '双脚与肩同宽，腿部微屈', '髋部后移前倾让杠端沿弧线下降', '收紧臀部与腘绳肌站起'], '中级', '地雷杠', ['核心保持紧绷', '保持杠端贴近身体'], 'legs/landmine_stiff_leg_deadlift.gif'),
      new ActionModel('legs_19', '相扑硬拉', 'Sumo Deadlift', '腿部', '', '', '相扑硬拉通过大开脚距强调内侧大腿和臀部力量，适合下肢力量发展。', ['双脚比肩更宽站立，脚尖外展', '双手窄握杠铃，髋部下沉', '保持背部平直向上发力', '顶点收紧臀部后控制下放'], '中级', '杠铃', ['膝盖朝向脚尖', '起拉时肩胛收紧'], 'legs/sumo_deadlift.gif'),
      new ActionModel('legs_20', '硬拉直腿硬拉', 'Deadlift & Stiff-leg Combo', '腿部', '', '', '硬拉直腿硬拉组合在同一组内完成常规硬拉与直腿硬拉，充分刺激前后腿肌。', ['先完成一次标准硬拉', '回到起始位后不放杠直接进入直腿硬拉', '根据计划交替重复两种动作', '保持小重量专注动作质量'], '高级', '杠铃', ['控制节奏避免借力', '核心持续收紧防止下背疲劳'], 'legs/deadlift_stiff_leg_combo.gif'),
      new ActionModel('legs_21', '俯卧腿弯举', 'Prone Leg Curl', '腿部', '', '', '俯卧腿弯举利用器械定位，有效孤立腘绳肌下段。', ['俯卧在腿弯举机上，脚踝置于滚轮下方', '收紧腘绳肌将滚轮卷向臀部', '在顶点停顿后缓慢下放'], '初级', '器械', ['骨盆紧贴垫面', '避免借力抬臀'], 'legs/prone_leg_curl.gif'),
      new ActionModel('legs_22', '单腿腿弯举', 'Single-Leg Leg Curl', '腿部', '', '', '单腿腿弯举能纠正左右腿肌力差异，提升神经肌肉控制。', ['将器械调至单腿模式', '脚踝牢固贴紧滚轮', '屈膝卷起重量并停顿', '缓慢还原后换另一条腿'], '中级', '器械', ['保持动作对称', '避免身体扭转'], 'legs/single_leg_leg_curl.gif'),
      new ActionModel('legs_23', '基础杠铃深蹲', 'Basic Barbell Squat', '腿部', '', '', '基础杠铃深蹲强调全程控制与均匀节奏，是巩固技术与耐力的好方法。', ['杠铃置于斜方肌，双脚与肩同宽', '吸气下蹲至大腿平行甚至更低', '脚跟发力站起并保持胸腔打开'], '中级', '杠铃', ['节奏采用3秒下降1秒上升', '不要急于加重量'], 'legs/basic_barbell_squat.gif'),
      new ActionModel('legs_24', '颈前深蹲（杠铃）', 'Barbell Front Squat', '腿部', '', '', '颈前深蹲（杠铃握姿版）更强调股四头肌与核心稳定，更适合作为力量型动作。', ['双手采用交叉或抓杠方式固定杠铃', '肘部抬至与地面平行', '保持躯干垂直向下蹲', '脚跟发力站起并维持肘部高度'], '高级', '杠铃', ['肘部不要塌下', '核心持续收紧防止前倾'], 'legs/front_squat_barbell.gif')
    ];
  }

  private static getShouldersActions(): ActionModel[] {
    return [
      new ActionModel('shoulders_1', '哑铃推举', 'Dumbbell Shoulder Press', '肩部', '', '', '哑铃推举是训练三角肌的基础动作。', ['坐在凳子上，背部挺直', '双手各持哑铃于肩部两侧', '向上推举哑铃至手臂伸直', '缓慢下降至起始位置'], '中级', '哑铃', ['核心保持稳定', '不要过度后仰'], 'shoulders/dumbbell_shoulder_press.gif'),
      new ActionModel('shoulders_2', '杠铃推举', 'Barbell Overhead Press', '肩部', '', '', '杠铃推举能够使用更大重量，全面发展肩部力量。', ['站立或坐姿，杠铃置于肩部', '向上推举杠铃至手臂伸直', '缓慢下降至起始位置'], '中级', '杠铃', ['保持核心收紧', '轨迹保持垂直'], 'shoulders/barbell_overhead_press.gif'),
      new ActionModel('shoulders_3', '侧平举', 'Lateral Raise', '肩部', '', '', '侧平举孤立训练三角肌中束，塑造宽阔肩膀。', ['站立，双手各持哑铃于身体两侧', '保持肘部微屈', '向两侧抬起哑铃至肩部高度', '缓慢下降'], '初级', '哑铃', ['不要耸肩', '控制下降速度'], 'shoulders/lateral_raise.gif'),
      new ActionModel('shoulders_4', '杠铃耸肩', 'Barbell Shrug', '肩部', '', '', '杠铃耸肩能使用更大重量训练斜方肌，快速增加肩颈厚度。', ['站立，双手握杠于大腿前', '手距与肩同宽', '保持手臂伸直，耸起肩膀', '在顶点稍作停留', '缓慢下降'], '初级', '杠铃', ['垂直上提', '不要弯曲手臂'], 'shoulders/barbell_shrug.gif'),
      new ActionModel('shoulders_5', '杠铃直立划船', 'Barbell Upright Row', '肩部', '', '', '杠铃直立划船训练三角肌中束和斜方肌，塑造宽阔肩膀。', ['站立，双手窄握杠铃于大腿前', '沿身体向上拉杠铃至下巴高度', '肘部向外展开，高于手腕', '缓慢下降还原'], '中级', '杠铃', ['肘部高于手腕', '不要耸肩'], 'shoulders/barbell_upright_row.gif'),
      new ActionModel('shoulders_6', '史密斯推肩', 'Smith Machine Shoulder Press', '肩部', '', '', '史密斯推肩使用固定轨迹，更安全地进行大重量肩部训练。', ['坐在史密斯机下，背部贴紧靠背', '双手握杠，略宽于肩', '向上推举杠铃至手臂伸直', '缓慢下降至肩部'], '中级', '器械', ['背部贴紧靠背', '控制下降速度'], 'shoulders/smith_machine_shoulder_press.gif'),
      new ActionModel('shoulders_7', '单臂侧平举', 'Single-Arm Lateral Raise', '肩部', '', '', '单臂侧平举能更专注单侧三角肌中束训练，纠正力量不平衡。', ['站立，一手扶住固定物', '另一手持哑铃于身侧', '保持肘部微屈，向侧面抬起', '缓慢下降后换另一侧'], '初级', '哑铃', ['不要借力摆动', '专注中束收缩'], 'shoulders/single_arm_lateral_raise.gif'),
      new ActionModel('shoulders_8', '绳索面拉', 'Face Pull', '肩部', '', '', '绳索面拉训练后三角肌和上背部肌肉。', ['站在绳索机前', '双手握住绳索把手', '向面部方向拉动绳索', '肘部向外展开', '缓慢还原'], '初级', '器械', ['拉向面部高度', '肩胛骨后缩'], 'shoulders/face_pull.gif'),
      new ActionModel('shoulders_9', '哑铃耸肩', 'Dumbbell Shrug', '肩部', '', '', '哑铃耸肩训练斜方肌，增加肩颈厚度。', ['站立，双手各持哑铃于身体两侧', '耸起肩膀至最高点', '在顶点稍作停留', '缓慢下降'], '初级', '哑铃', ['垂直上提', '不要转动肩膀'], 'shoulders/dumbbell_shrug.gif'),
      new ActionModel('shoulders_10', '器械推举', 'Machine Shoulder Press', '肩部', '', '', '器械推举是安全高效的肩部训练动作，固定轨迹减少受伤风险，适合新手和大重量训练。', ['坐在器械上，背部贴紧靠背', '调整座椅高度，使把手与肩部齐平', '双手握住把手，掌心向前', '向上推举至手臂伸直', '缓慢下降至起始位置'], '初级', '器械', ['保持背部贴紧靠背', '不要完全锁死肘部'], 'shoulders/machine_shoulder_press.gif'),
      new ActionModel('shoulders_11', '器械举', 'Machine Front Raise', '肩部', '', '', '器械前平举利用固定轨迹持续刺激前三角肌，减少借力更好感受肌肉收缩。', ['站立或坐在器械中，双手握住手柄', '保持肘部微屈，核心收紧', '将手柄抬至与肩同高', '在顶点停顿挤压后三角肌', '缓慢下降回到起始位置'], '初级', '器械', ['避免耸肩', '动作全程控制'], 'shoulders/machine_front_raise.gif'),
      new ActionModel('shoulders_12', '器械推肩', 'Plate Loaded Shoulder Press', '肩部', '', '', '板式器械推肩能够安全使用更大重量，全程刺激三角肌前中束。', ['调整座椅高度，让手柄与肩部齐平', '背部贴紧靠背，双脚稳踩地面', '双手握住手柄向上推举', '在顶部保持一秒后缓慢下降', '保持肩胛骨收紧避免耸肩'], '中级', '器械', ['不要锁死肘部', '核心收紧防止后仰'], 'shoulders/plate_loaded_shoulder_press.gif'),
      new ActionModel('shoulders_13', '卧式侧平举', 'Lying Lateral Raise', '肩部', '', '', '卧式侧平举利用凳面支撑隔离三角肌中束，提升肩部圆润度。', ['侧卧在凳子上，下侧手扶住凳面保持稳定', '上侧手持哑铃垂落在体前', '保持肘部微屈，沿弧线抬至肩部高度', '控制下降回到起始位置'], '初级', '哑铃', ['动作顶点停顿一秒', '躯干保持放松避免耸肩'], 'shoulders/lying_lateral_raise.gif'),
      new ActionModel('shoulders_14', '头拉', 'Head Pull', '肩部', '', '', '头拉强调后三角肌与斜方肌上束，可矫正圆肩和提升上背稳定。', ['面对绳索机站立，滑轮调至面部高度', '双手握住绳索端，手心相对', '肘部向外打开，将绳索拉向耳侧', '顶点时肩胛骨后缩并停留', '缓慢还原保持张力'], '中级', '绳索', ['肘部保持与肩同高', '拉动轨迹贴近耳朵'], 'shoulders/head_pull.gif')
    ];
  }

  private static getBicepsActions(): ActionModel[] {
    return [
      new ActionModel('biceps_1', '哑铃弯举', 'Dumbbell Curl', '二头肌', '', '', '哑铃弯举是训练肱二头肌的基础动作。', ['站立，双手各持哑铃于身体两侧', '保持上臂固定', '弯曲肘部，将哑铃举至肩部', '缓慢下降至起始位置'], '初级', '哑铃', ['上臂保持静止', '避免借力摆动'], 'biceps/dumbbell_curl.gif'),
      new ActionModel('biceps_2', '杠铃弯举', 'Barbell Curl', '二头肌', '', '', '杠铃弯举能够使用更大重量，有效增加二头肌力量。', ['站立，双手握杠，手距与肩同宽', '保持上臂固定', '弯曲肘部，将杠铃举至肩部', '缓慢下降'], '初级', '杠铃', ['核心保持稳定', '不要过度后仰'], 'biceps/barbell_curl.gif'),
      new ActionModel('biceps_3', '集中弯举', 'Concentration Curl', '二头肌', '', '', '集中弯举能够完全孤立肱二头肌，提高训练效果。', ['坐在凳子上，一手持哑铃', '肘部抵住大腿内侧', '弯曲肘部，将哑铃举至肩部', '缓慢下降'], '初级', '哑铃', ['完全孤立二头肌', '专注肌肉收缩'], 'biceps/seated_dumbbell_curl.gif'),
      new ActionModel('biceps_4', '牧师凳弯举', 'Preacher Curl', '二头肌', '', '', '牧师凳弯举能够防止借力，更好地刺激二头肌。', ['坐在牧师凳上', '上臂放在斜板上', '双手握杠或哑铃', '弯曲肘部向上举', '缓慢下降'], '初级', '杠铃/哑铃', ['上臂贴紧斜板', '避免抬起上臂'], 'biceps/preacher_curl.gif'),
      new ActionModel('biceps_5', '上斜卧姿弯举', 'Incline Lying Curl', '二头肌', '', '', '上斜卧姿弯举通过倾斜角度增加二头肌的拉伸幅度，更有效刺激长头。', ['坐在上斜凳上，背部贴紧靠背', '双手各持哑铃，自然下垂', '保持上臂固定，弯曲肘部举起哑铃', '在顶点收缩后缓慢下降'], '中级', '哑铃', ['充分拉伸二头肌', '不要摆动身体'], 'biceps/incline_lying_curl.gif'),
      new ActionModel('biceps_6', '器械弯举', 'Machine Bicep Curl', '二头肌', '', '', '器械弯举使用固定轨迹，能更安全地孤立训练二头肌。', ['坐在弯举机上，调整座椅高度', '双臂放在护垫上', '握住把手，弯曲肘部向上', '缓慢下降还原'], '初级', '器械', ['上臂贴紧护垫', '专注二头肌收缩'], 'biceps/machine_bicep_curl.gif'),
      new ActionModel('biceps_7', 'Z杠弯举', 'EZ Bar Curl', '二头肌', '', '', 'Z杠弯举能够减轻手腕压力，更舒适地训练二头肌。', ['站立，双手握住Z杠', '保持上臂固定', '弯曲肘部向上举', '缓慢下降'], '初级', 'Z杠', ['手腕更舒适', '保持动作标准'], 'biceps/ez_bar_curl.gif'),
      new ActionModel('biceps_8', '交替哑铃弯举', 'Alternating Dumbbell Curl', '二头肌', '', '', '交替弯举能够更专注于单侧二头肌的收缩。', ['站立，双手各持哑铃', '交替弯举左右手', '一侧举起，另一侧下降', '保持节奏'], '初级', '哑铃', ['保持身体稳定', '专注单侧收缩'], 'biceps/alternating_dumbbell_curl.gif'),
      new ActionModel('biceps_9', '平板卧姿弯举', 'Flat Lying Curl', '二头肌', '', '', '平板卧姿弯举在平躺状态下训练二头肌，能有效减少身体借力。', ['平躺在卧推凳上', '双手各持哑铃，自然垂于身体两侧', '保持上臂固定，弯曲肘部举起哑铃', '在顶点收缩后缓慢下降'], '中级', '哑铃', ['上臂保持固定', '避免身体借力'], 'biceps/flat_lying_curl.gif'),
    ];
  }

  private static getTricepsActions(): ActionModel[] {
    return [
      new ActionModel('triceps_1', '窄握卧推', 'Close-grip Bench Press', '三头肌', '', '', '窄握卧推是训练肱三头肌的复合动作。', ['平躺在卧推凳上', '双手握杠，手距略窄于肩', '将杠铃推至胸部上方', '缓慢下降至胸部', '用力推回起始位置'], '中级', '杠铃', ['手距不要过窄', '肘部贴近身体'], 'triceps/close_grip_bench_press.gif'),
      new ActionModel('triceps_2', '绳索下压', 'Cable Pushdown', '三头肌', '', '', '绳索下压是孤立训练三头肌的经典动作。', ['站在绳索机前', '双手握住把手', '保持上臂固定', '向下压绳索至手臂伸直', '缓慢还原'], '初级', '器械', ['肘部固定', '专注三头肌收缩'], 'triceps/cable_pushdown.gif'),
      new ActionModel('triceps_3', '哑铃后屈伸', 'Dumbbell Overhead Extension', '三头肌', '', '', '哑铃后屈伸能够充分拉伸三头肌长头。', ['站立或坐姿', '双手握住一个哑铃', '将哑铃举至头顶', '保持上臂固定，屈肘下降', '用力伸直手臂'], '初级', '哑铃', ['上臂保持垂直', '充分拉伸三头肌'], 'triceps/dumbbell_overhead_extension.gif'),
      new ActionModel('triceps_4', '器械臂屈伸', 'Tricep Dip Machine', '三头肌', '', '', '器械臂屈伸在固定轨迹下训练三头肌，更安全且能精准控制负重。', ['坐在臂屈伸机上', '双手握住把手', '保持上臂固定', '向下压把手至手臂伸直', '缓慢还原'], '初级', '器械', ['肘部固定', '专注三头肌收缩'], 'triceps/tricep_dip_machine.gif'),
      new ActionModel('triceps_5', '仰卧杠铃臂屈伸', 'Lying Barbell Tricep Extension', '三头肌', '', '', '仰卧臂屈伸能够孤立训练三头肌。', ['仰卧在凳子上', '双手握杠举至头顶上方', '保持上臂固定，屈肘下降', '用力伸直手臂'], '中级', '杠铃', ['上臂保持固定', '控制下降速度'], 'triceps/lying_barbell_tricep_extension.gif'),
      new ActionModel('triceps_6', '单臂绳索下压', 'Single-Arm Cable Extension', '三头肌', '', '', '单臂绳索下压能够纠正三头肌力量不平衡，专注单侧发力。', ['站在绳索机前', '一手握住把手', '保持上臂固定贴近身体', '向下压绳索至手臂伸直', '缓慢还原后换另一侧'], '初级', '器械', ['专注单侧发力', '保持身体稳定'], 'triceps/single_arm_cable_extension.gif'),
      new ActionModel('triceps_7', '坐姿单臂过顶臂屈伸', 'Seated Single-Arm Overhead Extension', '三头肌', '', '', '坐姿单臂过顶臂屈伸能充分拉伸三头肌长头，单侧训练更精准。', ['坐姿，一手持哑铃举至头顶', '保持上臂垂直固定', '屈肘下降哑铃至颈后', '用力伸直手臂', '完成后换另一侧'], '初级', '哑铃', ['肘部指向天花板', '充分拉伸三头肌'], 'triceps/seated_single_arm_overhead_extension.gif'),
      new ActionModel('triceps_8', '直杆绳索下压', 'Straight Bar Pushdown', '三头肌', '', '', '直杆绳索下压使用直杆能更大程度激活三头肌外侧头。', ['站在绳索机前', '双手正握直杆把手', '保持上臂固定贴近身体', '向下压直杆至手臂伸直', '缓慢还原'], '初级', '器械', ['肘部固定', '顶峰收缩'], 'triceps/straight_bar_pushdown.gif'),
      new ActionModel('triceps_9', '碎颅者', 'Skull Crusher', '三头肌', '', '', '碎颅者是经典的三头肌孤立动作，能有效刺激三头肌长头。', ['仰卧在卧推凳上', '双手握杠铃或哑铃举至头顶上方', '保持上臂固定，屈肘下降重量至额头上方', '用力伸直手臂推回'], '中级', '杠铃/哑铃', ['上臂保持垂直', '下降时控制速度'], 'triceps/skull_crusher.gif'),
      new ActionModel('triceps_10', '仰卧哑铃臂屈伸', 'Lying Dumbbell Tricep Extension', '三头肌', '', '', '仰卧哑铃臂屈伸能充分拉伸三头肌长头，提高肌肉刺激效果。', ['仰卧在卧推凳上', '双手各持一个哑铃举至头顶上方', '保持上臂固定，屈肘下降哑铃至头部两侧', '用力伸直手臂'], '中级', '哑铃', ['上臂保持固定', '下降时充分拉伸'], 'triceps/lying_dumbbell_tricep_extension.gif')
    ];
  }

  private static getCalvesActions(): ActionModel[] {
    return [
      new ActionModel('calves_1', '站姿提踵', 'Standing Calf Raise', '小腿', '', '', '站姿提踵是训练小腿肌肉的基础动作。', ['站立，前脚掌踩在台阶边缘', '保持身体直立', '脚跟向上提起至最高点', '缓慢下降至脚跟低于台阶'], '初级', '器械/自重', ['充分拉伸和收缩', '保持平衡'], 'calves/standing_calf_raise.gif'),
      new ActionModel('calves_2', '器械坐姿提踵', 'Machine Seated Calf Raise', '小腿', '', '', '器械坐姿提踵主要训练比目鱼肌，坐姿能更孤立小腿肌肉。', ['坐在坐姿提踵机上', '前脚掌踩在踏板上', '膝盖放在护垫下方', '提起脚跟至最高点', '缓慢下降充分拉伸'], '初级', '器械', ['膝盖固定不动', '专注小腿收缩'], 'calves/machine_seated_calf_raise.gif'),
      new ActionModel('calves_3', '驴式提踵', 'Donkey Calf Raise', '小腿', '', '', '驴式提踵是经典的小腿训练动作，俯身姿势能更好地拉伸腓肠肌。', ['俯身，双手撑在器械或凳子上', '髋部弯曲约90度', '前脚掌踩在踏板边缘', '提起脚跟至最高点', '缓慢下降'], '中级', '器械', ['保持髋部弯曲', '充分拉伸和收缩'], 'calves/donkey_calf_raise.gif'),
      new ActionModel('calves_4', '哑铃提踵', 'Dumbbell Calf Raise', '小腿', '', '', '哑铃提踵增加训练强度。', ['双手各持哑铃', '前脚掌踩在台阶边缘', '提起脚跟', '缓慢下降'], '初级', '哑铃', ['保持身体稳定', '控制动作'], 'calves/dumbbell_calf_raise.gif'),
      new ActionModel('calves_5', '器械站姿提踵', 'Machine Standing Calf Raise', '小腿', '', '', '器械站姿提踵使用器械负重，更安全稳定地训练腓肠肌。', ['站在站姿提踵机上', '肩膀顶住护垫', '前脚掌踩在踏板边缘', '提起脚跟至最高点', '缓慢下降充分拉伸'], '初级', '器械', ['保持身体直立', '充分拉伸和收缩'], 'calves/machine_standing_calf_raise.gif'),
      new ActionModel('calves_6', '单腿哑铃提踵', 'Single-Leg Dumbbell Calf Raise', '小腿', '', '', '单腿哑铃提踵能纠正两侧小腿力量不平衡，更精准地训练每侧腓肠肌。', ['一手持哑铃，另一手扶住支撑物', '单脚前脚掌踩在台阶边缘', '提起脚跟至最高点', '缓慢下降后换另一侧'], '中级', '哑铃', ['保持平衡', '充分拉伸和收缩'], 'calves/dumbbell_single_leg_calf_raise.gif'),
      new ActionModel('calves_10', '杠铃提踵', 'Barbell Calf Raise', '小腿', '', '', '杠铃提踵能够使用较大重量训练小腿，有效增加肌肉力量和体积。', ['将杠铃放在斜方肌上', '前脚掌踩在踏板或台阶边缘', '保持身体直立', '提起脚跟至最高点', '缓慢下降'], '中级', '杠铃', ['保持平衡', '充分拉伸和收缩'], 'calves/barbell_calf_raise.gif')
    ];
  }

  private static getGlutesActions(): ActionModel[] {
    return [
      new ActionModel('glutes_1', '臀桥', 'Glute Bridge', '臀部', '', '', '臀桥是训练臀部肌肉的基础动作，有效激活臀大肌。', ['仰卧，双脚平放地面', '膝盖弯曲约90度', '臀部发力抬起身体至躯干与大腿成一线', '在顶点挤压臀部', '缓慢下降'], '初级', '自重', ['臀部主导发力', '在顶点充分收缩'], 'glutes/glute_bridge.gif'),
      new ActionModel('glutes_2', '早安式', 'Good Morning', '臀部', '', '', '早安式是训练臀部和腘绳肌的经典动作，同时增强下背部力量。', ['站立，杠铃放在斜方肌上', '双脚与肩同宽，膝盖微屈', '髋关节铰链，上身前倾至与地面接近平行', '臀部和腘绳肌发力站起'], '中级', '杠铃', ['背部保持平直', '髋关节主导动作'], 'glutes/good_morning.gif'),
      new ActionModel('glutes_3', '哑铃罗马尼亚硬拉', 'Dumbbell Romanian Deadlift', '臀部', '', '', '哑铃罗马尼亚硬拉训练臀部和腘绳肌，哑铃更灵活。', ['站立，双手各持哑铃于大腿前', '保持腿部微屈', '髋关节铰链前倾，哑铃沿腿部下降', '感受腘绳肌拉伸后臀部发力站起'], '中级', '哑铃', ['髋关节主导', '背部保持平直'], 'glutes/dumbbell_romanian_deadlift.gif'),
      new ActionModel('glutes_4', '弓步蹲', 'Lunge', '臀部', '', '', '弓步蹲全面训练臀部和腿部肌肉。', ['站立，一脚向前迈出', '下蹲至前腿大腿与地面平行', '臀部发力站起'], '初级', '自重/哑铃', ['前膝对准脚尖', '臀部主动发力'], 'legs/lunge.gif'),
      new ActionModel('glutes_5', '保加利亚分腿蹲', 'Bulgarian Split Squat', '臀部', '', '', '保加利亚分腿蹲强化臀部和股四头肌。', ['后脚放在凳子上', '前脚向前迈出', '下蹲至前腿大腿与地面平行', '臀部发力站起'], '中级', '哑铃', ['保持平衡', '专注臀部发力'], 'legs/bulgarian_split_squat.gif'),
      new ActionModel('glutes_6', '绳索臀拉', 'Cable Pull Through', '臀部', '', '', '绳索臀拉是训练臀部和腘绳肌的有效动作，绳索提供持续张力。', ['背对绳索机站立', '双手从胯下握住绳索把手', '髋关节铰链前倾', '臀部发力站直，将绳索拉起', '在顶点挤压臀部'], '中级', '器械', ['髋关节主导', '保持背部平直'], 'glutes/cable_pull_through.gif'),
      new ActionModel('glutes_7', '站姿驴踢', 'Standing Donkey Kick', '臀部', '', '', '站姿驴踢孤立训练臀大肌，单腿发力更精准。', ['站立，双手扶住支撑物', '一腿站稳，另一腿向后上方踢', '在顶点收缩臀部', '缓慢还原后换另一侧'], '初级', '自重', ['专注臀部收缩', '不要借力摆动'], 'glutes/standing_donkey_kick.gif'),
      new ActionModel('glutes_8', '深蹲', 'Squat', '臀部', '', '', '深蹲全面训练下肢包括臀部。', ['双脚与肩同宽', '杠铃放在斜方肌上', '下蹲至大腿与地面平行', '臀部和腿部发力站起'], '中级', '杠铃', ['深蹲至足够深度', '臀部充分参与'], 'legs/squat.gif'),
      new ActionModel('glutes_9', '器械臀部后踢', 'Machine Glute Kickback', '臀部', '', '', '器械臀部后踢使用固定轨迹孤立训练臀大肌，更安全有效。', ['站在器械上，一脚踩在踏板上', '另一脚放在后踢垫上', '臀部发力向后踢腿', '在顶点收缩臀部', '缓慢还原后换另一侧'], '初级', '器械', ['专注臀部收缩', '控制动作速度'], 'glutes/machine_glute_kickback.gif'),
      new ActionModel('glutes_10', '哑铃侧弓步', 'Dumbbell Side Lunge', '臀部', '', '', '哑铃侧弓步训练臀中肌和大腿内侧，提高侧向稳定性。', ['站立，双手各持哑铃', '一脚向侧面迈出一大步', '屈膝下蹲，重心移向迈出腿', '另一腿保持伸直', '推回起始位置'], '中级', '哑铃', ['膝盖对准脚尖', '保持背部挺直'], 'glutes/dumbbell_side_lunge.gif'),
      new ActionModel('glutes_11', '器械髋伸展', 'Machine Hip Extension', '臀部', '', '', '器械髋伸展使用固定轨迹孤立训练臀大肌和腘绳肌，安全有效。', ['站在器械上，胸部贴紧护垫', '一腿固定，另一腿放在踏板后方', '臀部发力向后伸展腿部', '在顶点收缩臀部', '缓慢还原后换另一侧'], '初级', '器械', ['髋关节主导动作', '专注臀部发力'], 'glutes/machine_hip_extension.gif'),
      new ActionModel('glutes_12', '坐姿髋外展', 'Seated Hip Abduction', '臀部', '', '', '坐姿髋外展主要锻炼臀中肌与臀小肌，帮助稳定骨盆并塑造臀部外侧线条。', ['坐在髋外展机上，膝盖抵住垫子', '保持背部贴靠，核心收紧', '用力向外推开垫子并停留一秒', '缓慢将双腿合回'], '初级', '器械', ['全程保持动作平稳', '避免借力前倾'], 'glutes/seated_hip_abduction.gif'),
      new ActionModel('glutes_13', '哑铃相扑硬拉', 'Dumbbell Sumo Deadlift', '臀部', '', '', '哑铃相扑硬拉可以更好地激活臀大肌和内收肌，是家用训练非常实用的动作。', ['双脚宽站，脚尖外展', '双手握住哑铃置于双腿之间', '髋部下沉保持背部平直', '伸髋伸膝站起并收紧臀部', '控制下放回到起始位置'], '中级', '哑铃', ['膝盖始终朝向脚尖', '下放时保持哑铃贴近身体'], 'glutes/dumbbell_sumo_deadlift.gif')
    ];
  }

  private static getAbsActions(): ActionModel[] {
    return [
      new ActionModel('abs_1', '负重卷腹', 'Weighted Crunch', '腹肌', '', '', '负重卷腹通过增加阻力更有效地刺激腹直肌，加速腹肌增长。', ['仰卧在卷腹机或地面上', '双手持重物置于胸前或头后', '腹肌发力卷起上身', '在顶点收缩腹肌', '缓慢还原'], '中级', '器械/哑铃', ['下背不要离地', '控制负重下降'], 'abs/weighted_crunch.gif'),
      new ActionModel('abs_2', '俄罗斯转体', 'Russian Twist', '腹肌', '', '', '俄罗斯转体训练腹斜肌和核心旋转力量。', ['坐在地上，上身后倾', '双脚离地', '双手握哑铃或药球', '向左右两侧旋转上身'], '中级', '哑铃/药球', ['保持平衡', '腹斜肌主导'], 'abs/russian_twist.gif'),
      new ActionModel('abs_3', '悬垂卷腹', 'Hanging Crunch', '腹肌', '', '', '悬垂卷腹是高强度的下腹训练动作，需要较强的核心力量。', ['双手悬挂在单杠上', '保持身体稳定', '腹肌发力卷起骨盆和双腿', '在顶点收缩腹肌', '缓慢下降'], '高级', '单杠', ['避免身体摆动', '下腹主导发力'], 'abs/hanging_crunch.gif'),
      new ActionModel('abs_4', '平板支撑转体', 'Plank Rotation', '腹肌', '', '', '平板支撑转体在稳定核心的同时训练腹斜肌，提升核心旋转力量。', ['从平板支撑姿势开始', '一手撑地，另一手向上伸展', '身体旋转至侧平板姿势', '还原后换另一侧'], '中级', '自重', ['保持核心收紧', '动作流畅控制'], 'abs/plank_rotation.gif'),
      new ActionModel('abs_5', '单侧卷腹', 'Oblique Crunch', '腹肌', '', '', '单侧卷腹专注训练腹斜肌，塑造清晰的腹部线条。', ['侧卧，下方手支撑头部', '上方手放在耳后', '腹斜肌发力卷起上身向侧方', '缓慢还原后换另一侧'], '初级', '自重', ['专注腹斜肌收缩', '不要借力'], 'abs/oblique_crunch.gif'),
      new ActionModel('abs_6', '站姿绳索转体', 'Standing Cable Twist', '腹肌', '', '', '站姿绳索转体通过绳索阻力有效训练腹斜肌和核心旋转力量。', ['站在绳索机侧方', '双手握住绳索把手', '保持下半身固定', '核心发力旋转上身', '缓慢还原后换另一侧'], '中级', '器械', ['下半身保持稳定', '控制旋转速度'], 'abs/standing_cable_twist.gif'),
      new ActionModel('abs_7', '交替卷腹', 'Bicycle Crunches', '腹肌', '', '', '交替卷腹训练腹直肌和腹斜肌。', ['仰卧，双手放耳后', '抬起双腿', '左肘向右膝，右肘向左膝', '交替进行'], '初级', '自重', ['保持节奏', '充分旋转'], 'abs/bicycle_crunches.gif'),
      new ActionModel('abs_8', '仰卧抬腿', 'Lying Leg Raise', '腹肌', '', '', '仰卧抬腿重点训练下腹部，是塑造下腹线条的有效动作。', ['仰卧在地面或卧推凳上', '双手放身体两侧或抓住固定物', '双腿伸直并拢', '抬起双腿至垂直', '缓慢下降但不触地'], '中级', '自重', ['下背贴地', '下腹主导发力'], 'abs/lying_leg_raise.gif'),
      new ActionModel('abs_9', '剪刀腿', 'Scissor Kicks', '腹肌', '', '', '剪刀腿通过交替抬腿持续刺激下腹部，提高核心耐力。', ['仰卧在地面上', '双手放身体两侧或臀部下方', '双腿伸直离地约15度', '交替上下摆动双腿', '保持下背贴地'], '初级', '自重', ['下背保持贴地', '控制摆动幅度'], 'abs/scissor_kicks.gif'),
      new ActionModel('abs_10', '坐姿杠铃转体', 'Seated Barbell Twist', '腹肌', '', '', '坐姿杠铃转体训练腹斜肌和核心旋转力量，增强躯干稳定性。', ['坐在凳子上，杠铃放在肩后', '双手握住杠铃两端', '保持下半身固定', '上身向左右两侧旋转'], '中级', '杠铃', ['下半身保持稳定', '动作缓慢控制'], 'abs/seated_barbell_twist.gif'),
      new ActionModel('abs_11', '仰卧起坐', 'Sit-ups', '腹肌', '', '', '仰卧起坐是经典的腹部训练动作，全面锻炼腹直肌。', ['仰卧，双膝弯曲，双脚平放地面', '双手放在耳后或交叉放在胸前', '腹肌发力将上身完全抬起', '身体前倾接近膝盖', '缓慢还原'], '初级', '自重', ['不要用手拉头部', '腹肌主导发力'], 'abs/sit_ups.gif'),
      new ActionModel('abs_12', '猎鸟狗', 'Bird Dog', '腹肌', '', '', '猎鸟狗动作能提升核心稳定与腰背控制能力，对改善日常姿态很有帮助。', ['四点跪姿，双手在肩下双膝在髋下', '同时伸展对侧手臂与腿保持水平', '停留2秒后缓慢收回', '换另一侧重复'], '初级', '自重', ['保持骨盆水平', '动作过程中不要塌腰'], 'abs/bird_dog.gif'),
      new ActionModel('abs_13', '猫式', 'Cat Pose Stretch', '腹肌', '', '', '猫式是一种温和的动态拉伸，能够放松脊柱并激活核心深层肌群。', ['四点跪姿，吸气时抬头塌腰', '呼气时低头拱背', '在两个动作之间平滑切换', '配合呼吸重复多次'], '初级', '自重', ['动作与呼吸配合', '强调脊柱逐节运动'], 'abs/cat_pose.gif'),
      new ActionModel('abs_14', '空中踩单车', 'Air Bicycle Crunch', '腹肌', '', '', '空中踩单车结合卷腹与交替抬腿，持续刺激腹直肌和腹斜肌。', ['仰卧，双手扶头部', '肩胛离地，双腿抬起呈90度', '交替伸直一条腿，同时让对侧肘靠向弯曲膝盖', '持续按照节奏完成'], '中级', '自重', ['下背紧贴地面', '动作范围要充分'], 'abs/air_bicycle_crunch.gif')
    ];
  }

  private static getCardioActions(): ActionModel[] {
    return [
      new ActionModel('cardio_1', '战绳', 'Battle Rope Waves', '有氧', '', '', '战绳波浪动作能快速提升心肺耐力，同时锻炼肩膀与核心稳定。', ['将战绳固定后双脚与肩同宽站立', '微屈髋膝，双手握住绳端', '交替或同时快速挥动绳索形成波浪', '保持胸口挺起与核心收紧', '按照设定时间维持节奏'], '中级', '战绳', ['动作要连续流畅', '呼吸与节奏同步'], 'shoulders/battle_rope_waves.gif'),
      new ActionModel('cardio_2', '室内跑', 'Treadmill Run', '有氧', '', '', '室内跑步机训练能在可控环境下提升下肢爆发与心肺表现。', ['先以慢走热身3-5分钟', '设定合适的速度与坡度', '迈步时轻落前脚掌，保持节奏', '摆臂配合、眼视前方', '结束前逐渐减速降速步行'], '初级', '跑步机', ['落脚轻柔减少冲击', '保持呼吸均匀'], 'legs/treadmill_run.gif'),
      new ActionModel('cardio_3', '动感单车', 'Spin Bike', '有氧', '', '', '动感单车结合坐姿与站姿踩踏，提升腿部耐力与心肺表现。', ['调整座椅与把手高度，使膝盖在最低点微屈', '脚掌固定在踏板绑带中', '保持背部挺直，核心收紧', '按照课程节奏均匀踩踏并适时调节阻力', '结束前逐渐降低阻力放松'], '初级', '动感单车', ['膝盖始终对准脚尖', '阻力调节循序渐进'], 'legs/spin_bike.gif'),
      new ActionModel('cardio_4', '踩单车', 'Stationary Bike', '有氧', '', '', '传统健身车踩踏能够长时间维持中等强度，提升下肢耐力。', ['调整座椅高度让膝盖在最低点微屈', '脚掌固定在踏板绑带内', '保持髋部稳定，均匀踩踏', '根据心率逐渐调节阻力', '维持设定时间完成训练'], '初级', '健身车', ['踏频保持平稳', '肩部放松不要耸肩'], 'legs/stationary_bike.gif'),
      new ActionModel('cardio_5', '踩单车间歇', 'Stationary Bike Intervals', '有氧', '', '', '踩单车间歇训练通过冲刺与恢复交替，提升腿部爆发力和心肺效率。', ['完成5分钟轻松骑行热身', '提高阻力冲刺30-60秒', '立即降低阻力做等长时间恢复踩踏', '根据计划重复多个冲刺回合', '最后以低阻力慢骑收操'], '中级', '健身车', ['冲刺时保持核心稳定', '间歇时间可依体能调整'], 'legs/stationary_bike_intervals.gif'),
      new ActionModel('cardio_6', '爬楼梯', 'Stair Climb', '有氧', '', '', '爬楼梯或登阶训练能强化臀腿力量并提升心肺耐力。', ['面对楼梯或登阶机站稳', '一脚踩上台阶，脚跟发力抬起身体', '另一脚跟上，保持胸口抬起', '交替腿部重复向上动作', '视情况握扶手保持平衡'], '初级', '楼梯/登阶机', ['整脚踩稳台阶', '避免身体前倾过度'], 'legs/stair_climb.gif'),
      new ActionModel('cardio_7', '高抬腿', 'High Knees', '有氧', '', '', '高抬腿是常见的原地跑变式，快速提升心率并激活髋屈肌。', ['站立，双脚与髋同宽', '抬起一侧膝盖至髋部高度', '落地同时抬起另一侧膝盖', '摆臂配合保持节奏', '按照设定时间持续交替'], '初级', '自重', ['脚尖轻落减少冲击', '核心收紧避免上身后仰'], 'legs/high_knees.gif'),
      new ActionModel('cardio_8', '高脚踢', 'High Kicks', '有氧', '', '', '高脚踢结合动态拉伸与力量输出，可改善髋关节灵活性并激活下肢。', ['站姿双脚与肩同宽，手臂自然下垂', '抬腿向前上方踢至可控高度', '落地后立刻换另一侧踢腿', '保持上身挺直，核心收紧', '全程控制摆腿速度防止晃动'], '初级', '自重', ['踢腿高度以可控为主', '下放时不要跺地'], 'legs/high_kicks.gif')
    ];
  }
}
