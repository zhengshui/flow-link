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
      new ActionModel('chest_1', '卧推', 'Barbell Bench Press', '胸肌', '', '', '杠铃卧推是训练胸部肌肉的经典动作，主要锻炼胸大肌、前三角肌和肱三头肌。', ['平躺在卧推凳上，双脚平放地面', '双手握杠，手距略宽于肩', '将杠铃从架子上推起，保持在胸部上方', '缓慢下降杠铃至胸部', '用力将杠铃推回起始位置'], '中级', '杠铃', ['保持肩胛骨收紧', '下降时吸气，上推时呼气']),
      new ActionModel('chest_2', '哑铃卧推', 'Dumbbell Bench Press', '胸肌', '', '', '哑铃卧推相比杠铃卧推有更大的运动范围，能更好地刺激胸肌。', ['平躺在卧推凳上，双手各持一个哑铃', '将哑铃举至胸部上方，掌心相对', '缓慢下降哑铃至胸部两侧', '用力推起哑铃至起始位置'], '中级', '哑铃', ['保持核心稳定', '控制哑铃下降速度']),
      new ActionModel('chest_3', '上斜卧推', 'Incline Bench Press', '胸肌', '', '', '上斜卧推主要针对上胸部肌肉，帮助塑造完美的胸部线条。', ['调整卧推凳至30-45度角', '平躺后双手握杠，手距略宽于肩', '将杠铃推至胸部上方', '缓慢下降至上胸部位置', '用力推回起始位置'], '中级', '杠铃', ['角度不宜过大', '注意肩部稳定性']),
      new ActionModel('chest_4', '下斜卧推', 'Decline Bench Press', '胸肌', '', '', '下斜卧推主要针对下胸部肌肉，增加胸肌的厚度。', ['调整卧推凳至15-30度下斜角', '固定双脚，平躺在凳上', '双手握杠推至胸部上方', '缓慢下降至下胸部', '用力推回起始位置'], '中级', '杠铃', ['确保身体稳定', '控制动作节奏']),
      new ActionModel('chest_5', '哑铃飞鸟', 'Dumbbell Fly', '胸肌', '', '', '哑铃飞鸟是孤立训练胸肌的经典动作，能有效拉伸和收缩胸肌。', ['平躺在卧推凳上，双手各持哑铃', '将哑铃举至胸部上方，掌心相对', '保持肘部微屈，向两侧展开手臂', '感受胸肌拉伸后，收缩胸肌将哑铃推回'], '中级', '哑铃', ['动作要缓慢控制', '不要完全伸直手臂']),
      new ActionModel('chest_6', '上斜哑铃飞鸟', 'Incline Dumbbell Fly', '胸肌', '', '', '上斜哑铃飞鸟针对上胸部，帮助塑造饱满的上胸线条。', ['调整卧推凳至30-45度角', '平躺后双手各持哑铃', '将哑铃举至胸部上方', '保持肘部微屈，向两侧展开', '收缩上胸肌将哑铃推回'], '中级', '哑铃', ['保持肩部稳定', '专注上胸发力']),
      new ActionModel('chest_7', '俯卧撑', 'Push-ups', '胸肌', '', '', '俯卧撑是经典的自重训练动作，随时随地都可以进行。', ['俯卧在地面，双手撑地，略宽于肩', '身体保持一条直线', '弯曲手臂，降低身体至接近地面', '用力撑起身体回到起始位置'], '初级', '自重', ['保持核心收紧', '身体不要塌腰']),
      new ActionModel('chest_8', '双杠臂屈伸', 'Dips', '胸肌', '', '', '双杠臂屈伸是训练下胸部和三头肌的复合动作。', ['双手撑在双杠上，身体悬空', '身体前倾约15-20度', '弯曲手臂，降低身体', '用力撑起身体回到起始位置'], '中级', '双杠', ['身体前倾针对胸肌', '下降不要过低']),
      new ActionModel('chest_9', '蝴蝶机夹胸', 'Pec Deck Fly', '胸肌', '', '', '蝴蝶机夹胸是孤立训练胸肌中缝的有效动作。', ['坐在蝴蝶机上，背部贴紧靠背', '双手握住把手，肘部放在垫片上', '用力将把手向中间夹紧', '缓慢还原至起始位置'], '初级', '器械', ['保持肘部固定', '专注胸肌收缩']),
      new ActionModel('chest_10', '哑铃地板卧推', 'Floor Press', '胸肌', '', '', '哑铃地板卧推限制了动作幅度，对肩部压力较小，适合肩部有伤的训练者。', ['平躺在地板上，双手各持哑铃', '将哑铃推至胸部上方', '缓慢下降至手臂触地', '用力推起哑铃'], '初级', '哑铃', ['手臂触地时暂停', '保持肩胛骨稳定'])
    ];
  }

  private static getBackActions(): ActionModel[] {
    return [
      new ActionModel('back_1', '引体向上', 'Pull-ups', '背肌', '', '', '引体向上是训练背部肌肉的王牌动作，主要锻炼背阔肌和肱二头肌。', ['双手握杠，手距略宽于肩', '身体悬垂，保持核心稳定', '拉起身体直至下巴过杠', '缓慢下降至起始位置'], '高级', '单杠', ['避免身体摆动', '背部主动发力']),
      new ActionModel('back_2', '高位下拉', 'Lat Pulldown', '背肌', '', '', '高位下拉是引体向上的替代动作，适合力量不足的训练者。', ['坐在器械上，双手握住横杆', '身体微微后倾', '拉动横杆至胸部上方', '缓慢还原'], '初级', '器械', ['背部主导发力', '不要过度后仰']),
      new ActionModel('back_3', '杠铃划船', 'Barbell Row', '背肌', '', '', '杠铃划船是增加背部厚度的经典动作。', ['站立，膝盖微屈，上身前倾', '双手握杠，比肩略宽', '将杠铃拉向下腹部', '缓慢下放杠铃'], '中级', '杠铃', ['保持背部平直', '避免用腰发力']),
      new ActionModel('back_4', '哑铃单臂划船', 'One-arm Dumbbell Row', '背肌', '', '', '单臂划船能够孤立训练单侧背肌，纠正肌力不平衡。', ['一手撑在凳子上，另一手持哑铃', '上身与地面平行', '将哑铃拉向腰部', '缓慢下放哑铃'], '初级', '哑铃', ['保持身体稳定', '背肌主动收缩']),
      new ActionModel('back_5', 'T杠划船', 'T-bar Row', '背肌', '', '', 'T杠划船能够使用较大重量，有效增加背部肌肉厚度。', ['站在T杠一端，双脚跨立', '俯身握住手柄', '将T杠拉向胸部', '缓慢下放'], '中级', 'T杠', ['核心保持稳定', '背部收紧发力']),
      new ActionModel('back_6', '反向飞鸟', 'Reverse Fly', '背肌', '', '', '反向飞鸟主要训练后三角肌和上背部肌肉。', ['俯身，上身与地面平行', '双手各持哑铃，自然下垂', '保持肘部微屈，向两侧展开', '缓慢还原'], '初级', '哑铃', ['控制动作速度', '专注肩胛骨收缩']),
      new ActionModel('back_7', '直立划船', 'Upright Row', '背肌', '', '', '直立划船训练上背部和肩部肌肉。', ['站立，双手握杠，手距与肩同宽', '将杠铃沿身体向上拉至胸部', '肘部向外展开', '缓慢下放杠铃'], '中级', '杠铃', ['不要耸肩', '肘部高于手腕']),
      new ActionModel('back_8', '硬拉', 'Deadlift', '背肌', '', '', '硬拉是力量训练的基础动作，训练整个后链肌群。', ['站立，双脚与肩同宽', '俯身握杠，手臂自然下垂', '挺胸收腹，腿部发力', '拉起杠铃至身体直立', '保持背部平直，缓慢下放'], '高级', '杠铃', ['保持背部平直', '用腿部发力，不是腰']),
      new ActionModel('back_9', '下拉绳索划船', 'Cable Seated Row', '背肌', '', '', '坐姿绳索划船能够保持背部持续张力，提高训练效果。', ['坐在器械上，双脚踩住踏板', '双手握住把手', '保持背部直立，向腹部拉动绳索', '缓慢还原'], '初级', '器械', ['背部保持直立', '肩胛骨主动收缩']),
      new ActionModel('back_10', '反手引体向上', 'Reverse Grip Pull-up', '背肌', '', '', '反手引体向上更多地刺激下背阔肌和肱二头肌。', ['反手握杠，手距与肩同宽', '身体悬垂', '拉起身体至下巴过杠', '缓慢下降'], '高级', '单杠', ['保持身体稳定', '避免过度借力'])
    ];
  }

  private static getLegsActions(): ActionModel[] {
    return [
      new ActionModel('legs_1', '深蹲', 'Squat', '腿部', '', '', '深蹲是下肢训练的王牌动作，全面锻炼腿部肌群。', ['双脚与肩同宽站立', '杠铃放在斜方肌上', '保持背部挺直，向下蹲', '大腿与地面平行后站起'], '中级', '杠铃', ['膝盖不要超过脚尖', '保持核心收紧']),
      new ActionModel('legs_2', '弓步蹲', 'Lunge', '腿部', '', '', '弓步蹲能够单独训练每条腿，改善肌力不平衡。', ['站立，一脚向前迈出', '下蹲至前腿大腿与地面平行', '后腿膝盖接近地面', '站起回到起始位置'], '初级', '自重/哑铃', ['保持上身直立', '前膝不要超过脚尖']),
      new ActionModel('legs_3', '罗马尼亚硬拉', 'Romanian Deadlift', '腿部', '', '', '罗马尼亚硬拉主要训练腘绳肌和臀部肌肉。', ['站立，双手握杠于大腿前', '保持腿部微屈', '上身前倾，杠铃沿腿部下降', '感受腘绳肌拉伸后站起'], '中级', '杠铃', ['背部保持平直', '动作缓慢控制']),
      new ActionModel('legs_4', '腿举', 'Leg Press', '腿部', '', '', '腿举能够使用大重量，有效增加腿部肌肉力量。', ['坐在腿举机上', '双脚放在踏板上，与肩同宽', '解除安全锁，下降踏板', '腿部发力推起踏板'], '初级', '器械', ['不要完全锁死膝盖', '下降时膝盖不要内扣']),
      new ActionModel('legs_5', '腿弯举', 'Leg Curl', '腿部', '', '', '腿弯举孤立训练腘绳肌，塑造腿部后侧线条。', ['俯卧在腿弯举机上', '脚踝钩住滚轮', '弯曲膝盖，将滚轮拉向臀部', '缓慢还原'], '初级', '器械', ['避免借力', '专注腘绳肌收缩']),
      new ActionModel('legs_6', '直腿硬拉', 'Stiff-leg Deadlift', '腿部', '', '', '直腿硬拉强调腘绳肌的拉伸和收缩。', ['站立，双腿伸直', '俯身握杠', '保持腿部伸直，上身前倾', '感受腘绳肌拉伸后站起'], '中级', '杠铃', ['腿部不要完全锁死', '背部保持平直']),
      new ActionModel('legs_7', '保加利亚分腿蹲', 'Bulgarian Split Squat', '腿部', '', '', '保加利亚分腿蹲能够更好地孤立训练单腿，提高平衡能力。', ['后脚放在凳子上', '前脚向前迈出', '下蹲至前腿大腿与地面平行', '站起回到起始位置'], '中级', '哑铃', ['保持身体平衡', '前膝对准脚尖']),
      new ActionModel('legs_8', '跳箱', 'Box Jump', '腿部', '', '', '跳箱是训练爆发力的经典动作。', ['站在跳箱前方', '屈膝准备', '全力跳上跳箱', '轻轻跳下或走下'], '中级', '跳箱', ['落地时屈膝缓冲', '确保安全稳定']),
      new ActionModel('legs_9', '弹力带侧步', 'Banded Side Step', '腿部', '', '', '弹力带侧步训练臀中肌，改善髋部稳定性。', ['弹力带套在膝盖上方', '半蹲姿势', '向一侧迈步', '保持张力来回移动'], '初级', '弹力带', ['保持半蹲姿势', '臀部主动发力']),
      new ActionModel('legs_10', '单腿臀桥', 'Single-leg Glute Bridge', '腿部', '', '', '单腿臀桥孤立训练臀部和腘绳肌。', ['仰卧，一腿屈膝脚掌着地', '另一腿伸直抬起', '臀部发力抬起身体', '缓慢下降'], '初级', '自重', ['臀部主导发力', '保持骨盆稳定'])
    ];
  }

  private static getShouldersActions(): ActionModel[] {
    return [
      new ActionModel('shoulders_1', '哑铃推举', 'Dumbbell Shoulder Press', '肩部', '', '', '哑铃推举是训练三角肌的基础动作。', ['坐在凳子上，背部挺直', '双手各持哑铃于肩部两侧', '向上推举哑铃至手臂伸直', '缓慢下降至起始位置'], '中级', '哑铃', ['核心保持稳定', '不要过度后仰']),
      new ActionModel('shoulders_2', '杠铃推举', 'Barbell Overhead Press', '肩部', '', '', '杠铃推举能够使用更大重量，全面发展肩部力量。', ['站立或坐姿，杠铃置于肩部', '向上推举杠铃至手臂伸直', '缓慢下降至起始位置'], '中级', '杠铃', ['保持核心收紧', '轨迹保持垂直']),
      new ActionModel('shoulders_3', '侧平举', 'Lateral Raise', '肩部', '', '', '侧平举孤立训练三角肌中束，塑造宽阔肩膀。', ['站立，双手各持哑铃于身体两侧', '保持肘部微屈', '向两侧抬起哑铃至肩部高度', '缓慢下降'], '初级', '哑铃', ['不要耸肩', '控制下降速度']),
      new ActionModel('shoulders_4', '前平举', 'Front Raise', '肩部', '', '', '前平举主要训练三角肌前束。', ['站立,双手持哑铃于大腿前', '保持手臂伸直', '向前抬起哑铃至肩部高度', '缓慢下降'], '初级', '哑铃', ['避免借力摆动', '保持肩部稳定']),
      new ActionModel('shoulders_5', '俯身后平举', 'Rear Delt Fly', '肩部', '', '', '俯身后平举训练三角肌后束，平衡肩部发展。', ['俯身，上身与地面平行', '双手持哑铃自然下垂', '向两侧抬起哑铃', '缓慢还原'], '初级', '哑铃', ['肩胛骨收缩', '专注后束发力']),
      new ActionModel('shoulders_6', '阿诺德推举', 'Arnold Press', '肩部', '', '', '阿诺德推举结合推举和旋转，全面刺激三角肌。', ['坐姿，哑铃置于胸前，掌心向内', '向上推举同时旋转手腕', '推至顶点时掌心向前', '反向旋转还原'], '中级', '哑铃', ['动作流畅', '控制旋转幅度']),
      new ActionModel('shoulders_7', '倾斜俯身飞鸟', 'Incline Reverse Fly', '肩部', '', '', '倾斜俯身飞鸟能更好地孤立三角肌后束。', ['俯卧在上斜凳上', '双手持哑铃自然下垂', '向两侧展开手臂', '缓慢还原'], '初级', '哑铃', ['保持肘部微屈', '后束主导发力']),
      new ActionModel('shoulders_8', '绳索面拉', 'Face Pull', '肩部', '', '', '绳索面拉训练后三角肌和上背部肌肉。', ['站在绳索机前', '双手握住绳索把手', '向面部方向拉动绳索', '肘部向外展开', '缓慢还原'], '初级', '器械', ['拉向面部高度', '肩胛骨后缩']),
      new ActionModel('shoulders_9', '哑铃耸肩', 'Dumbbell Shrug', '肩部', '', '', '哑铃耸肩训练斜方肌，增加肩颈厚度。', ['站立，双手各持哑铃于身体两侧', '耸起肩膀至最高点', '在顶点稍作停留', '缓慢下降'], '初级', '哑铃', ['垂直上提', '不要转动肩膀']),
      new ActionModel('shoulders_10', '单臂哑铃推举', 'Single-arm Dumbbell Press', '肩部', '', '', '单臂推举能够纠正力量不平衡，提高核心稳定性。', ['站立或坐姿，一手持哑铃于肩部', '向上推举哑铃', '缓慢下降', '完成一侧后换另一侧'], '中级', '哑铃', ['保持身体稳定', '避免侧向倾斜'])
    ];
  }

  private static getBicepsActions(): ActionModel[] {
    return [
      new ActionModel('biceps_1', '哑铃弯举', 'Dumbbell Curl', '二头肌', '', '', '哑铃弯举是训练肱二头肌的基础动作。', ['站立，双手各持哑铃于身体两侧', '保持上臂固定', '弯曲肘部，将哑铃举至肩部', '缓慢下降至起始位置'], '初级', '哑铃', ['上臂保持静止', '避免借力摆动']),
      new ActionModel('biceps_2', '杠铃弯举', 'Barbell Curl', '二头肌', '', '', '杠铃弯举能够使用更大重量，有效增加二头肌力量。', ['站立，双手握杠，手距与肩同宽', '保持上臂固定', '弯曲肘部，将杠铃举至肩部', '缓慢下降'], '初级', '杠铃', ['核心保持稳定', '不要过度后仰']),
      new ActionModel('biceps_3', '集中弯举', 'Concentration Curl', '二头肌', '', '', '集中弯举能够完全孤立肱二头肌，提高训练效果。', ['坐在凳子上，一手持哑铃', '肘部抵住大腿内侧', '弯曲肘部，将哑铃举至肩部', '缓慢下降'], '初级', '哑铃', ['完全孤立二头肌', '专注肌肉收缩']),
      new ActionModel('biceps_4', '牧师凳弯举', 'Preacher Curl', '二头肌', '', '', '牧师凳弯举能够防止借力，更好地刺激二头肌。', ['坐在牧师凳上', '上臂放在斜板上', '双手握杠或哑铃', '弯曲肘部向上举', '缓慢下降'], '初级', '杠铃/哑铃', ['上臂贴紧斜板', '避免抬起上臂']),
      new ActionModel('biceps_5', '斜板哑铃弯举', 'Incline Dumbbell Curl', '二头肌', '', '', '斜板弯举增加二头肌的拉伸幅度。', ['坐在上斜凳上，背部贴紧靠背', '双手各持哑铃，自然下垂', '弯曲肘部，将哑铃举起', '缓慢下降'], '中级', '哑铃', ['充分拉伸二头肌', '不要摆动身体']),
      new ActionModel('biceps_6', '反手弯举', 'Reverse Curl', '二头肌', '', '', '反手弯举训练肱肌和前臂肌肉。', ['站立，反手握杠', '保持上臂固定', '弯曲肘部向上举', '缓慢下降'], '初级', '杠铃', ['手腕保持固定', '专注前臂发力']),
      new ActionModel('biceps_7', 'Z杠弯举', 'EZ Bar Curl', '二头肌', '', '', 'Z杠弯举能够减轻手腕压力，更舒适地训练二头肌。', ['站立，双手握住Z杠', '保持上臂固定', '弯曲肘部向上举', '缓慢下降'], '初级', 'Z杠', ['手腕更舒适', '保持动作标准']),
      new ActionModel('biceps_8', '交替哑铃弯举', 'Alternating Dumbbell Curl', '二头肌', '', '', '交替弯举能够更专注于单侧二头肌的收缩。', ['站立，双手各持哑铃', '交替弯举左右手', '一侧举起，另一侧下降', '保持节奏'], '初级', '哑铃', ['保持身体稳定', '专注单侧收缩']),
      new ActionModel('biceps_9', '绳索弯举', 'Cable Curl', '二头肌', '', '', '绳索弯举能够保持二头肌持续张力。', ['站在绳索机前', '双手握住把手', '弯曲肘部向上拉', '缓慢还原'], '初级', '器械', ['保持张力', '顶点收缩']),
      new ActionModel('biceps_10', '哑铃锤式弯举', 'Hammer Curl', '二头肌', '', '', '锤式弯举同时训练肱二头肌和肱肌。', ['站立，双手各持哑铃', '掌心相对', '弯曲肘部向上举', '缓慢下降'], '初级', '哑铃', ['保持掌心相对', '肘部固定'])
    ];
  }

  private static getTricepsActions(): ActionModel[] {
    return [
      new ActionModel('triceps_1', '窄握卧推', 'Close-grip Bench Press', '三头肌', '', '', '窄握卧推是训练肱三头肌的复合动作。', ['平躺在卧推凳上', '双手握杠，手距略窄于肩', '将杠铃推至胸部上方', '缓慢下降至胸部', '用力推回起始位置'], '中级', '杠铃', ['手距不要过窄', '肘部贴近身体']),
      new ActionModel('triceps_2', '绳索下压', 'Cable Pushdown', '三头肌', '', '', '绳索下压是孤立训练三头肌的经典动作。', ['站在绳索机前', '双手握住把手', '保持上臂固定', '向下压绳索至手臂伸直', '缓慢还原'], '初级', '器械', ['肘部固定', '专注三头肌收缩']),
      new ActionModel('triceps_3', '哑铃后屈伸', 'Dumbbell Overhead Extension', '三头肌', '', '', '哑铃后屈伸能够充分拉伸三头肌长头。', ['站立或坐姿', '双手握住一个哑铃', '将哑铃举至头顶', '保持上臂固定，屈肘下降', '用力伸直手臂'], '初级', '哑铃', ['上臂保持垂直', '充分拉伸三头肌']),
      new ActionModel('triceps_4', '俯身臂屈伸', 'Bench Dips', '三头肌', '', '', '俯身臂屈伸使用自重训练三头肌。', ['双手撑在凳子边缘', '腿伸直或屈膝', '弯曲手臂，降低身体', '用力撑起身体'], '初级', '自重', ['肘部向后', '保持身体稳定']),
      new ActionModel('triceps_5', '仰卧杠铃臂屈伸', 'Lying Barbell Tricep Extension', '三头肌', '', '', '仰卧臂屈伸能够孤立训练三头肌。', ['仰卧在凳子上', '双手握杠举至头顶上方', '保持上臂固定，屈肘下降', '用力伸直手臂'], '中级', '杠铃', ['上臂保持固定', '控制下降速度']),
      new ActionModel('triceps_6', '单臂绳索下压', 'One-arm Cable Pushdown', '三头肌', '', '', '单臂下压能够纠正三头肌力量不平衡。', ['站在绳索机前', '一手握住把手', '保持上臂固定', '向下压绳索', '缓慢还原'], '初级', '器械', ['专注单侧发力', '保持身体稳定']),
      new ActionModel('triceps_7', '哑铃颈后伸', 'Overhead Dumbbell Extension', '三头肌', '', '', '颈后伸充分拉伸三头肌长头。', ['坐姿，一手持哑铃', '将哑铃举至头顶', '屈肘下降至颈后', '用力伸直手臂'], '初级', '哑铃', ['肘部指向天花板', '充分拉伸']),
      new ActionModel('triceps_8', '俯卧撑窄距', 'Close-grip Push-ups', '三头肌', '', '', '窄距俯卧撑使用自重训练三头肌。', ['俯卧撑姿势', '双手距离约与肩同宽或更窄', '弯曲手臂下降', '用力撑起身体'], '初级', '自重', ['肘部贴近身体', '保持核心稳定']),
      new ActionModel('triceps_9', '杠铃颈后臂屈伸', 'Barbell Overhead Extension', '三头肌', '', '', '杠铃颈后臂屈伸能够使用较大重量训练三头肌。', ['站立或坐姿', '双手握杠举至头顶', '屈肘下降杠铃至颈后', '用力伸直手臂'], '中级', '杠铃', ['保持上臂固定', '不要过度下降']),
      new ActionModel('triceps_10', '俯身臂屈伸机', 'Tricep Kickback', '三头肌', '', '', '臂屈伸机孤立训练三头肌。', ['俯身，一手撑凳', '另一手持哑铃', '上臂与身体平行', '伸直手臂向后', '缓慢还原'], '初级', '哑铃', ['上臂保持固定', '专注三头肌收缩'])
    ];
  }

  private static getCalvesActions(): ActionModel[] {
    return [
      new ActionModel('calves_1', '站姿提踵', 'Standing Calf Raise', '小腿', '', '', '站姿提踵是训练小腿肌肉的基础动作。', ['站立，前脚掌踩在台阶边缘', '保持身体直立', '脚跟向上提起至最高点', '缓慢下降至脚跟低于台阶'], '初级', '器械/自重', ['充分拉伸和收缩', '保持平衡']),
      new ActionModel('calves_2', '坐姿提踵', 'Seated Calf Raise', '小腿', '', '', '坐姿提踵主要训练比目鱼肌。', ['坐在提踵机上', '前脚掌踩在踏板上', '提起脚跟至最高点', '缓慢下降'], '初级', '器械', ['膝盖固定', '专注小腿收缩']),
      new ActionModel('calves_3', '单腿提踵', 'Single-leg Calf Raise', '小腿', '', '', '单腿提踵能够纠正小腿力量不平衡。', ['单脚站立在台阶边缘', '另一只脚悬空', '提起脚跟至最高点', '缓慢下降'], '初级', '自重', ['保持平衡', '充分收缩']),
      new ActionModel('calves_4', '哑铃提踵', 'Dumbbell Calf Raise', '小腿', '', '', '哑铃提踵增加训练强度。', ['双手各持哑铃', '前脚掌踩在台阶边缘', '提起脚跟', '缓慢下降'], '初级', '哑铃', ['保持身体稳定', '控制动作']),
      new ActionModel('calves_5', '负重提踵', 'Weighted Calf Raise', '小腿', '', '', '负重提踵能够有效增加小腿肌肉力量。', ['肩膀上放杠铃片或杠铃', '站在台阶边缘', '提起脚跟', '缓慢下降'], '中级', '杠铃', ['注意安全', '负重适中']),
      new ActionModel('calves_6', '跳绳', 'Jump Rope', '小腿', '', '', '跳绳是训练小腿爆发力和耐力的有效方式。', ['手持跳绳', '用前脚掌跳跃', '保持节奏', '持续训练'], '初级', '跳绳', ['用前脚掌着地', '保持轻快节奏']),
      new ActionModel('calves_7', '跳箱小腿跳', 'Box Calf Jump', '小腿', '', '', '跳箱小腿跳训练小腿爆发力。', ['站在低矮跳箱前', '用小腿力量跳上跳箱', '轻轻跳下', '重复'], '中级', '跳箱', ['专注小腿发力', '落地缓冲']),
      new ActionModel('calves_8', '踮脚行走', 'Toe Walk', '小腿', '', '', '踮脚行走增强小腿耐力。', ['踮起脚尖', '保持脚跟离地', '向前行走', '保持平衡'], '初级', '自重', ['保持高位', '持续张力']),
      new ActionModel('calves_9', '跑步机坡度走', 'Incline Treadmill Walk', '小腿', '', '', '坡度行走训练小腿耐力和力量。', ['站上跑步机', '设置较大坡度', '快走或慢跑', '保持姿势'], '初级', '跑步机', ['使用合适坡度', '保持节奏']),
      new ActionModel('calves_10', '弹力带提踵', 'Banded Calf Raise', '小腿', '', '', '弹力带提踵提供持续张力。', ['弹力带绕过前脚掌', '双手拉紧弹力带', '提起脚跟', '缓慢下降'], '初级', '弹力带', ['保持张力', '充分收缩'])
    ];
  }

  private static getGlutesActions(): ActionModel[] {
    return [
      new ActionModel('glutes_1', '臀桥', 'Glute Bridge', '臀部', '', '', '臀桥是训练臀部肌肉的基础动作。', ['仰卧，双脚平放地面', '膝盖弯曲约90度', '臀部发力抬起身体', '在顶点收缩臀部', '缓慢下降'], '初级', '自重', ['臀部主导发力', '在顶点挤压臀部']),
      new ActionModel('glutes_2', '单腿臀桥', 'Single-leg Glute Bridge', '臀部', '', '', '单腿臀桥增加训练强度，改善平衡。', ['仰卧，一腿屈膝脚掌着地', '另一腿伸直抬起', '臀部发力抬起身体', '缓慢下降'], '中级', '自重', ['保持骨盆稳定', '臀部充分收缩']),
      new ActionModel('glutes_3', '罗马尼亚硬拉', 'Romanian Deadlift', '臀部', '', '', '罗马尼亚硬拉训练臀部和腘绳肌。', ['站立，双手握杠', '保持腿部微屈', '髋关节铰链前倾', '臀部和腘绳肌发力站起'], '中级', '杠铃', ['髋关节主导', '背部保持平直']),
      new ActionModel('glutes_4', '弓步蹲', 'Lunge', '臀部', '', '', '弓步蹲全面训练臀部和腿部肌肉。', ['站立，一脚向前迈出', '下蹲至前腿大腿与地面平行', '臀部发力站起'], '初级', '自重/哑铃', ['前膝对准脚尖', '臀部主动发力']),
      new ActionModel('glutes_5', '保加利亚分腿蹲', 'Bulgarian Split Squat', '臀部', '', '', '保加利亚分腿蹲强化臀部和股四头肌。', ['后脚放在凳子上', '前脚向前迈出', '下蹲至前腿大腿与地面平行', '臀部发力站起'], '中级', '哑铃', ['保持平衡', '专注臀部发力']),
      new ActionModel('glutes_6', '臀推', 'Hip Thrust', '臀部', '', '', '臀推是最有效的臀部训练动作之一。', ['上背靠在凳子边缘', '双脚平放地面', '髋关节放杠铃或哑铃', '臀部发力向上推', '在顶点充分收缩'], '中级', '杠铃', ['肩胛骨靠凳子', '顶点挤压臀部']),
      new ActionModel('glutes_7', '弹力带侧步', 'Banded Side Walk', '臀部', '', '', '弹力带侧步训练臀中肌。', ['弹力带套在膝盖上方', '半蹲姿势', '向一侧迈步', '保持张力来回移动'], '初级', '弹力带', ['保持半蹲', '臀部持续张力']),
      new ActionModel('glutes_8', '深蹲', 'Squat', '臀部', '', '', '深蹲全面训练下肢包括臀部。', ['双脚与肩同宽', '杠铃放在斜方肌上', '下蹲至大腿与地面平行', '臀部和腿部发力站起'], '中级', '杠铃', ['深蹲至足够深度', '臀部充分参与']),
      new ActionModel('glutes_9', '臀部踢腿', 'Kickbacks', '臀部', '', '', '臀部踢腿孤立训练臀大肌。', ['四肢支撑在地面', '一腿向后上方踢', '在顶点收缩臀部', '缓慢还原'], '初级', '自重/器械', ['专注臀部收缩', '保持核心稳定']),
      new ActionModel('glutes_10', '跳箱', 'Box Jump', '臀部', '', '', '跳箱训练臀部爆发力。', ['站在跳箱前方', '屈膝准备', '全力跳上跳箱', '轻轻跳下'], '中级', '跳箱', ['臀部主导发力', '安全落地'])
    ];
  }

  private static getAbsActions(): ActionModel[] {
    return [
      new ActionModel('abs_1', '仰卧卷腹', 'Crunches', '腹肌', '', '', '仰卧卷腹是训练腹直肌的经典动作。', ['仰卧，双腿屈膝', '双手放在耳后或胸前', '腹肌发力卷起上身', '缓慢还原，但不完全放松'], '初级', '自重', ['下背不要离地', '专注腹肌收缩']),
      new ActionModel('abs_2', '俄罗斯转体', 'Russian Twist', '腹肌', '', '', '俄罗斯转体训练腹斜肌和核心旋转力量。', ['坐在地上，上身后倾', '双脚离地', '双手握哑铃或药球', '向左右两侧旋转上身'], '中级', '哑铃/药球', ['保持平衡', '腹斜肌主导']),
      new ActionModel('abs_3', '悬垂举腿', 'Hanging Leg Raise', '腹肌', '', '', '悬垂举腿训练下腹部和核心力量。', ['双手悬挂在单杠上', '保持身体稳定', '抬起双腿至与地面平行', '缓慢下降'], '高级', '单杠', ['避免摆动', '下腹主导发力']),
      new ActionModel('abs_4', '平板支撑', 'Plank', '腹肌', '', '', '平板支撑训练整个核心肌群的稳定性。', ['俯卧，前臂撑地', '身体保持一条直线', '收紧核心', '保持姿势'], '初级', '自重', ['不要塌腰', '保持呼吸']),
      new ActionModel('abs_5', '侧平板支撑', 'Side Plank', '腹肌', '', '', '侧平板支撑训练腹斜肌和侧核心。', ['侧卧，一侧前臂撑地', '身体保持一条直线', '髋部抬起离地', '保持姿势'], '初级', '自重', ['身体保持直线', '髋部不要下沉']),
      new ActionModel('abs_6', '腹肌轮', 'Ab Wheel Rollout', '腹肌', '', '', '腹肌轮是高强度核心训练动作。', ['跪姿，双手握腹肌轮', '向前滚动轮子', '身体尽量伸展', '腹肌发力拉回'], '高级', '腹肌轮', ['核心保持紧张', '不要塌腰']),
      new ActionModel('abs_7', '交替卷腹', 'Bicycle Crunches', '腹肌', '', '', '交替卷腹训练腹直肌和腹斜肌。', ['仰卧，双手放耳后', '抬起双腿', '左肘向右膝，右肘向左膝', '交替进行'], '初级', '自重', ['保持节奏', '充分旋转']),
      new ActionModel('abs_8', '仰卧抬腿', 'Leg Raise', '腹肌', '', '', '仰卧抬腿重点训练下腹部。', ['仰卧，双手放身体两侧', '双腿伸直', '抬起双腿至垂直', '缓慢下降但不触地'], '中级', '自重', ['下背贴地', '下腹主导']),
      new ActionModel('abs_9', '反向卷腹', 'Reverse Crunch', '腹肌', '', '', '反向卷腹重点训练下腹部。', ['仰卧，双手放身体两侧', '双腿屈膝抬起', '下腹发力卷起臀部', '缓慢还原'], '初级', '自重', ['下腹主导发力', '不要借力摆动']),
      new ActionModel('abs_10', '山羊式卷腹', 'V-up', '腹肌', '', '', '山羊式卷腹是高强度全腹训练。', ['仰卧，四肢伸直', '同时抬起上身和双腿', '在顶点手触脚', '缓慢还原'], '高级', '自重', ['保持控制', '腹肌持续收缩'])
    ];
  }
}
