#!/bin/bash
# 官方训练模板种子数据脚本
# 使用方式: ./seed_official_templates.sh [admin_token]
# 
# 如果没有传入 token，脚本会尝试使用管理员账号登录获取 token
# 默认管理员账号: admin / admin123 (请根据实际情况修改)

API_BASE="http://127.0.0.1:8080/api"

# 检查是否传入了 token
if [ -n "$1" ]; then
    TOKEN="$1"
    echo "📝 使用传入的 Token"
else
    echo "🔐 正在登录管理员账号..."
    # 登录获取 token (请根据实际管理员账号修改)
    LOGIN_RESPONSE=$(curl -s -X POST "$API_BASE/auth/login" \
      -H "Content-Type: application/json" \
      -d '{"username": "admin", "password": "admin123"}')
    
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$TOKEN" ]; then
        echo "❌ 登录失败，请检查管理员账号密码或手动传入 token"
        echo "使用方式: ./seed_official_templates.sh <your_token>"
        exit 1
    fi
    echo "✅ 登录成功"
fi

echo ""
echo "🏋️ 开始创建官方训练模板..."

# 模板1: 新手全身训练计划 (初级)
curl -X POST "$API_BASE/admin/templates" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "新手全身入门计划",
    "description": "专为健身新手设计的全身训练计划，每周3次训练，循序渐进建立运动习惯，学习基础动作模式。",
    "goal": "综合健身",
    "splitType": "全身训练",
    "level": "初级",
    "equipment": "混合",
    "durationWeeks": 4,
    "trainingDaysPerWeek": 3,
    "author": "FitEasy官方",
    "tags": ["新手友好", "全身训练", "基础入门"],
    "recommendedIntensity": "RPE 5-6",
    "isOfficial": true,
    "trainingDays": [
      {
        "dayNumber": 1,
        "dayName": "全身训练A",
        "isRestDay": false,
        "intensityHint": "RPE 5-6",
        "warmupTips": "5分钟慢跑或跳绳热身",
        "cooldownTips": "5分钟拉伸放松",
        "exercises": [
          {"name": "深蹲", "sets": 3, "reps": 10, "weight": 20, "restTime": 90, "muscleGroup": "腿部"},
          {"name": "俯卧撑", "sets": 3, "reps": 10, "weight": 0, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "哑铃俯身划船", "sets": 3, "reps": 10, "weight": 10, "restTime": 60, "muscleGroup": "背部"},
          {"name": "哑铃推举", "sets": 3, "reps": 10, "weight": 8, "restTime": 60, "muscleGroup": "肩部"},
          {"name": "仰卧抬腿", "sets": 3, "reps": 15, "weight": 0, "restTime": 45, "muscleGroup": "核心"}
        ],
        "notes": "注意动作标准，重量轻一些没关系"
      },
      {
        "dayNumber": 2,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "充分休息，可以进行轻度拉伸"
      },
      {
        "dayNumber": 3,
        "dayName": "全身训练B",
        "isRestDay": false,
        "intensityHint": "RPE 5-6",
        "warmupTips": "5分钟慢跑或跳绳热身",
        "cooldownTips": "5分钟拉伸放松",
        "exercises": [
          {"name": "哑铃罗马尼亚硬拉", "sets": 3, "reps": 10, "weight": 20, "restTime": 90, "muscleGroup": "腿部"},
          {"name": "上斜卧推", "sets": 3, "reps": 10, "weight": 10, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "高位下拉", "sets": 3, "reps": 10, "weight": 25, "restTime": 60, "muscleGroup": "背部"},
          {"name": "侧平举", "sets": 3, "reps": 12, "weight": 5, "restTime": 45, "muscleGroup": "肩部"},
          {"name": "仰卧起坐", "sets": 3, "reps": 15, "weight": 0, "restTime": 45, "muscleGroup": "核心"}
        ],
        "notes": "注意呼吸节奏"
      },
      {
        "dayNumber": 4,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "充分休息"
      },
      {
        "dayNumber": 5,
        "dayName": "全身训练C",
        "isRestDay": false,
        "intensityHint": "RPE 5-6",
        "warmupTips": "5分钟慢跑或跳绳热身",
        "cooldownTips": "5分钟拉伸放松",
        "exercises": [
          {"name": "腿举", "sets": 3, "reps": 12, "weight": 40, "restTime": 90, "muscleGroup": "腿部"},
          {"name": "哑铃飞鸟", "sets": 3, "reps": 12, "weight": 8, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "下拉绳索划船", "sets": 3, "reps": 10, "weight": 30, "restTime": 60, "muscleGroup": "背部"},
          {"name": "绳索面拉", "sets": 3, "reps": 15, "weight": 15, "restTime": 45, "muscleGroup": "肩部"},
          {"name": "俄罗斯转体", "sets": 3, "reps": 20, "weight": 5, "restTime": 45, "muscleGroup": "核心"}
        ],
        "notes": "本周最后一练，全力以赴"
      },
      {
        "dayNumber": 6,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "周末休息"
      },
      {
        "dayNumber": 7,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "周末休息，为下周做准备"
      }
    ]
  }'

echo ""
echo "✅ 模板1创建完成"

# 模板2: 推拉腿三分化 (中级)
curl -X POST "$API_BASE/admin/templates" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "经典推拉腿三分化",
    "description": "最经典的训练分化方式，将肌群按推、拉、腿划分，每周训练6次，适合有一定基础的训练者。",
    "goal": "增肌",
    "splitType": "推拉腿",
    "level": "中级",
    "equipment": "器械",
    "durationWeeks": 8,
    "trainingDaysPerWeek": 6,
    "author": "FitEasy官方",
    "tags": ["增肌", "经典分化", "推拉腿"],
    "recommendedIntensity": "RPE 7-8",
    "isOfficial": true,
    "trainingDays": [
      {
        "dayNumber": 1,
        "dayName": "推日(胸肩三头)",
        "isRestDay": false,
        "intensityHint": "RPE 7-8",
        "warmupTips": "肩部环绕，轻重量卧推热身2组",
        "cooldownTips": "胸肩拉伸5分钟",
        "exercises": [
          {"name": "器械推胸", "sets": 4, "reps": 8, "weight": 60, "restTime": 120, "muscleGroup": "胸部"},
          {"name": "上斜卧推", "sets": 3, "reps": 10, "weight": 22, "restTime": 90, "muscleGroup": "胸部"},
          {"name": "绳索夹胸", "sets": 3, "reps": 12, "weight": 15, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "哑铃推举", "sets": 4, "reps": 10, "weight": 16, "restTime": 90, "muscleGroup": "肩部"},
          {"name": "侧平举", "sets": 3, "reps": 15, "weight": 8, "restTime": 45, "muscleGroup": "肩部"},
          {"name": "绳索下压", "sets": 3, "reps": 12, "weight": 20, "restTime": 60, "muscleGroup": "手臂"}
        ],
        "notes": "卧推注意肩胛骨收紧下沉"
      },
      {
        "dayNumber": 2,
        "dayName": "拉日(背二头)",
        "isRestDay": false,
        "intensityHint": "RPE 7-8",
        "warmupTips": "肩部环绕，轻重量引体热身",
        "cooldownTips": "背部拉伸5分钟",
        "exercises": [
          {"name": "引体向上", "sets": 4, "reps": 8, "weight": 0, "restTime": 120, "muscleGroup": "背部"},
          {"name": "杠铃划船", "sets": 4, "reps": 8, "weight": 50, "restTime": 90, "muscleGroup": "背部"},
          {"name": "下拉绳索划船", "sets": 3, "reps": 10, "weight": 45, "restTime": 90, "muscleGroup": "背部"},
          {"name": "高位下拉", "sets": 3, "reps": 12, "weight": 25, "restTime": 60, "muscleGroup": "背部"},
          {"name": "杠铃弯举", "sets": 3, "reps": 10, "weight": 20, "restTime": 60, "muscleGroup": "手臂"},
          {"name": "交替哑铃弯举", "sets": 3, "reps": 12, "weight": 12, "restTime": 45, "muscleGroup": "手臂"}
        ],
        "notes": "划船动作注意背部发力感"
      },
      {
        "dayNumber": 3,
        "dayName": "腿日",
        "isRestDay": false,
        "intensityHint": "RPE 8",
        "warmupTips": "5分钟单车热身，空杠深蹲热身",
        "cooldownTips": "腿部拉伸10分钟",
        "exercises": [
          {"name": "深蹲", "sets": 4, "reps": 8, "weight": 80, "restTime": 180, "muscleGroup": "腿部"},
          {"name": "哑铃罗马尼亚硬拉", "sets": 4, "reps": 10, "weight": 60, "restTime": 120, "muscleGroup": "腿部"},
          {"name": "腿举", "sets": 3, "reps": 12, "weight": 120, "restTime": 90, "muscleGroup": "腿部"},
          {"name": "腿弯举", "sets": 3, "reps": 12, "weight": 35, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "器械坐姿提踵", "sets": 4, "reps": 15, "weight": 40, "restTime": 45, "muscleGroup": "腿部"}
        ],
        "notes": "深蹲注意膝盖跟踪脚尖方向"
      },
      {
        "dayNumber": 4,
        "dayName": "推日(胸肩三头)",
        "isRestDay": false,
        "intensityHint": "RPE 7-8",
        "warmupTips": "肩部环绕，轻重量热身",
        "cooldownTips": "胸肩拉伸5分钟",
        "exercises": [
          {"name": "上斜卧推", "sets": 4, "reps": 8, "weight": 50, "restTime": 120, "muscleGroup": "胸部"},
          {"name": "哑铃卧推", "sets": 3, "reps": 10, "weight": 24, "restTime": 90, "muscleGroup": "胸部"},
          {"name": "蝴蝶机夹胸", "sets": 3, "reps": 12, "weight": 40, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "哑铃推举", "sets": 3, "reps": 10, "weight": 14, "restTime": 90, "muscleGroup": "肩部"},
          {"name": "绳索面拉", "sets": 3, "reps": 15, "weight": 6, "restTime": 45, "muscleGroup": "肩部"},
          {"name": "仰卧哑铃臂屈伸", "sets": 3, "reps": 12, "weight": 25, "restTime": 60, "muscleGroup": "手臂"}
        ],
        "notes": "上斜角度30度左右"
      },
      {
        "dayNumber": 5,
        "dayName": "拉日(背二头)",
        "isRestDay": false,
        "intensityHint": "RPE 7-8",
        "warmupTips": "肩部热身，轻重量下拉",
        "cooldownTips": "背部拉伸5分钟",
        "exercises": [
          {"name": "高位下拉", "sets": 4, "reps": 10, "weight": 55, "restTime": 90, "muscleGroup": "背部"},
          {"name": "T杠划船", "sets": 4, "reps": 8, "weight": 40, "restTime": 90, "muscleGroup": "背部"},
          {"name": "哑铃单臂划船", "sets": 3, "reps": 10, "weight": 24, "restTime": 60, "muscleGroup": "背部"},
          {"name": "绳索面拉", "sets": 3, "reps": 15, "weight": 20, "restTime": 45, "muscleGroup": "肩部"},
          {"name": "哑铃弯举", "sets": 3, "reps": 10, "weight": 12, "restTime": 60, "muscleGroup": "手臂"},
          {"name": "牧师凳弯举", "sets": 3, "reps": 12, "weight": 15, "restTime": 45, "muscleGroup": "手臂"}
        ],
        "notes": "注意背部收缩感"
      },
      {
        "dayNumber": 6,
        "dayName": "腿日",
        "isRestDay": false,
        "intensityHint": "RPE 8",
        "warmupTips": "5分钟单车热身",
        "cooldownTips": "腿部拉伸10分钟",
        "exercises": [
          {"name": "腿举", "sets": 4, "reps": 10, "weight": 140, "restTime": 120, "muscleGroup": "腿部"},
          {"name": "弓步蹲", "sets": 3, "reps": 12, "weight": 20, "restTime": 90, "muscleGroup": "腿部"},
          {"name": "史密斯深蹲", "sets": 3, "reps": 12, "weight": 45, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "腿弯举", "sets": 3, "reps": 12, "weight": 35, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "臀桥", "sets": 3, "reps": 15, "weight": 40, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "站姿提踵", "sets": 4, "reps": 15, "weight": 60, "restTime": 45, "muscleGroup": "腿部"}
        ],
        "notes": "弓步蹲注意膝盖稳定"
      },
      {
        "dayNumber": 7,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "完全休息，准备下一周训练"
      }
    ]
  }'

echo ""
echo "✅ 模板2创建完成"

# 模板3: 上下肢二分化 (中级)
curl -X POST "$API_BASE/admin/templates" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "上下肢二分化计划",
    "description": "简单高效的二分化训练，将身体分为上肢和下肢训练，每周4次，适合时间有限的训练者。",
    "goal": "增肌",
    "splitType": "上下肢",
    "level": "中级",
    "equipment": "混合",
    "durationWeeks": 6,
    "trainingDaysPerWeek": 4,
    "author": "FitEasy官方",
    "tags": ["增肌", "二分化", "高效"],
    "recommendedIntensity": "RPE 7-8",
    "isOfficial": true,
    "trainingDays": [
      {
        "dayNumber": 1,
        "dayName": "上肢A(推为主)",
        "isRestDay": false,
        "intensityHint": "RPE 7-8",
        "warmupTips": "肩部热身，轻重量卧推",
        "cooldownTips": "上肢拉伸",
        "exercises": [
          {"name": "器械推胸", "sets": 4, "reps": 8, "weight": 60, "restTime": 120, "muscleGroup": "胸部"},
          {"name": "哑铃推举", "sets": 4, "reps": 10, "weight": 18, "restTime": 90, "muscleGroup": "肩部"},
          {"name": "上斜哑铃飞鸟", "sets": 3, "reps": 12, "weight": 12, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "侧平举", "sets": 3, "reps": 15, "weight": 8, "restTime": 45, "muscleGroup": "肩部"},
          {"name": "绳索下压", "sets": 3, "reps": 12, "weight": 22, "restTime": 60, "muscleGroup": "手臂"},
          {"name": "仰卧哑铃臂屈伸", "sets": 3, "reps": 12, "weight": 20, "restTime": 60, "muscleGroup": "手臂"}
        ],
        "notes": "注意胸肌发力感"
      },
      {
        "dayNumber": 2,
        "dayName": "下肢A(股四为主)",
        "isRestDay": false,
        "intensityHint": "RPE 8",
        "warmupTips": "5分钟单车，空杠深蹲",
        "cooldownTips": "腿部拉伸10分钟",
        "exercises": [
          {"name": "深蹲", "sets": 4, "reps": 8, "weight": 80, "restTime": 180, "muscleGroup": "腿部"},
          {"name": "腿举", "sets": 3, "reps": 12, "weight": 120, "restTime": 90, "muscleGroup": "腿部"},
          {"name": "史密斯深蹲", "sets": 3, "reps": 12, "weight": 40, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "腿弯举", "sets": 3, "reps": 12, "weight": 30, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "器械坐姿提踵", "sets": 4, "reps": 15, "weight": 40, "restTime": 45, "muscleGroup": "腿部"}
        ],
        "notes": "深蹲保持核心稳定"
      },
      {
        "dayNumber": 3,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "休息恢复"
      },
      {
        "dayNumber": 4,
        "dayName": "上肢B(拉为主)",
        "isRestDay": false,
        "intensityHint": "RPE 7-8",
        "warmupTips": "肩部热身，轻重量下拉",
        "cooldownTips": "背部拉伸",
        "exercises": [
          {"name": "引体向上", "sets": 4, "reps": 8, "weight": 0, "restTime": 120, "muscleGroup": "背部"},
          {"name": "杠铃划船", "sets": 4, "reps": 8, "weight": 50, "restTime": 90, "muscleGroup": "背部"},
          {"name": "下拉绳索划船", "sets": 3, "reps": 10, "weight": 45, "restTime": 60, "muscleGroup": "背部"},
          {"name": "绳索面拉", "sets": 3, "reps": 15, "weight": 18, "restTime": 45, "muscleGroup": "肩部"},
          {"name": "杠铃弯举", "sets": 3, "reps": 10, "weight": 20, "restTime": 60, "muscleGroup": "手臂"},
          {"name": "交替哑铃弯举", "sets": 3, "reps": 12, "weight": 12, "restTime": 45, "muscleGroup": "手臂"}
        ],
        "notes": "划船注意背部夹紧"
      },
      {
        "dayNumber": 5,
        "dayName": "下肢B(臀腿为主)",
        "isRestDay": false,
        "intensityHint": "RPE 8",
        "warmupTips": "5分钟单车热身",
        "cooldownTips": "腿部拉伸",
        "exercises": [
          {"name": "哑铃罗马尼亚硬拉", "sets": 4, "reps": 10, "weight": 60, "restTime": 120, "muscleGroup": "腿部"},
          {"name": "保加利亚分腿蹲", "sets": 3, "reps": 10, "weight": 16, "restTime": 90, "muscleGroup": "腿部"},
          {"name": "臀桥", "sets": 4, "reps": 12, "weight": 60, "restTime": 90, "muscleGroup": "腿部"},
          {"name": "腿弯举", "sets": 3, "reps": 12, "weight": 35, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "站姿提踵", "sets": 4, "reps": 15, "weight": 50, "restTime": 45, "muscleGroup": "腿部"}
        ],
        "notes": "硬拉保持背部平直"
      },
      {
        "dayNumber": 6,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "周末休息"
      },
      {
        "dayNumber": 7,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "为下周做准备"
      }
    ]
  }'

echo ""
echo "✅ 模板3创建完成"

# 模板4: 减脂力量计划 (中级)
curl -X POST "$API_BASE/admin/templates" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "高效减脂力量计划",
    "description": "结合力量训练和高强度训练的减脂计划，每周5次训练，高效燃脂，适合有基础的训练者。",
    "goal": "减脂",
    "splitType": "全身训练",
    "level": "中级",
    "equipment": "混合",
    "durationWeeks": 6,
    "trainingDaysPerWeek": 5,
    "author": "FitEasy官方",
    "tags": ["减脂", "力量", "燃脂"],
    "recommendedIntensity": "RPE 8-9",
    "isOfficial": true,
    "trainingDays": [
      {
        "dayNumber": 1,
        "dayName": "力量训练(上肢)",
        "isRestDay": false,
        "intensityHint": "RPE 8",
        "warmupTips": "5分钟动态热身",
        "cooldownTips": "5分钟拉伸",
        "exercises": [
          {"name": "哑铃卧推", "sets": 4, "reps": 12, "weight": 18, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "哑铃俯身划船", "sets": 4, "reps": 12, "weight": 16, "restTime": 60, "muscleGroup": "背部"},
          {"name": "哑铃推举", "sets": 4, "reps": 12, "weight": 12, "restTime": 60, "muscleGroup": "肩部"},
          {"name": "俯卧撑", "sets": 4, "reps": 15, "weight": 0, "restTime": 30, "muscleGroup": "胸部"},
          {"name": "交替卷腹", "sets": 4, "reps": 20, "weight": 0, "restTime": 30, "muscleGroup": "核心"}
        ],
        "notes": "力量训练保持较短休息时间"
      },
      {
        "dayNumber": 2,
        "dayName": "力量训练(下肢)",
        "isRestDay": false,
        "intensityHint": "RPE 8",
        "warmupTips": "5分钟单车热身",
        "cooldownTips": "10分钟腿部拉伸",
        "exercises": [
          {"name": "徒手深蹲", "sets": 4, "reps": 15, "weight": 0, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "哑铃罗马尼亚硬拉", "sets": 4, "reps": 12, "weight": 40, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "弓步蹲", "sets": 4, "reps": 12, "weight": 14, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "腿举", "sets": 4, "reps": 15, "weight": 80, "restTime": 45, "muscleGroup": "腿部"},
          {"name": "仰卧抬腿", "sets": 4, "reps": 15, "weight": 0, "restTime": 30, "muscleGroup": "核心"}
        ],
        "notes": "注意膝盖保护"
      },
      {
        "dayNumber": 3,
        "dayName": "活动恢复",
        "isRestDay": false,
        "intensityHint": "RPE 5-6",
        "exercises": [
          {"name": "山羊挺身", "sets": 3, "reps": 15, "weight": 0, "restTime": 60, "muscleGroup": "背部", "notes": "低强度恢复"},
          {"name": "器械背部伸展", "sets": 3, "reps": 15, "weight": 0, "restTime": 60, "muscleGroup": "背部", "notes": "放松脊柱"}
        ],
        "notes": "低强度恢复日，促进血液循环"
      },
      {
        "dayNumber": 4,
        "dayName": "全身力量训练",
        "isRestDay": false,
        "intensityHint": "RPE 8-9",
        "warmupTips": "5分钟动态热身",
        "cooldownTips": "5分钟拉伸",
        "exercises": [
          {"name": "哑铃罗马尼亚硬拉", "sets": 4, "reps": 12, "weight": 16, "restTime": 45, "muscleGroup": "全身"},
          {"name": "俯卧撑", "sets": 4, "reps": 12, "weight": 0, "restTime": 30, "muscleGroup": "胸部"},
          {"name": "哑铃推举", "sets": 4, "reps": 12, "weight": 10, "restTime": 45, "muscleGroup": "肩部"},
          {"name": "俄罗斯转体", "sets": 4, "reps": 20, "weight": 5, "restTime": 30, "muscleGroup": "核心"},
          {"name": "仰卧起坐", "sets": 3, "reps": 20, "weight": 0, "restTime": 30, "muscleGroup": "核心"}
        ],
        "notes": "循环进行，尽量减少休息时间"
      },
      {
        "dayNumber": 5,
        "dayName": "力量训练(全身)",
        "isRestDay": false,
        "intensityHint": "RPE 8",
        "warmupTips": "5分钟动态热身",
        "cooldownTips": "5分钟拉伸",
        "exercises": [
          {"name": "硬拉", "sets": 4, "reps": 10, "weight": 60, "restTime": 90, "muscleGroup": "全身"},
          {"name": "引体向上", "sets": 4, "reps": 8, "weight": 0, "restTime": 60, "muscleGroup": "背部"},
          {"name": "哑铃卧推", "sets": 4, "reps": 10, "weight": 18, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "徒手深蹲", "sets": 4, "reps": 20, "weight": 0, "restTime": 30, "muscleGroup": "腿部"},
          {"name": "俯卧撑", "sets": 4, "reps": 12, "weight": 0, "restTime": 30, "muscleGroup": "胸部"}
        ],
        "notes": "本周最后一练，全力以赴"
      },
      {
        "dayNumber": 6,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "完全休息"
      },
      {
        "dayNumber": 7,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "准备下周训练"
      }
    ]
  }'

echo ""
echo "✅ 模板4创建完成"

# 模板5: 力量提升5x5计划 (高级)
curl -X POST "$API_BASE/admin/templates" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "力量提升5x5计划",
    "description": "经典的5x5力量训练计划，专注于复合动作，渐进式增加重量，快速提升基础力量。",
    "goal": "力量提升",
    "splitType": "全身训练",
    "level": "高级",
    "equipment": "器械",
    "durationWeeks": 12,
    "trainingDaysPerWeek": 3,
    "author": "FitEasy官方",
    "tags": ["力量", "5x5", "复合动作"],
    "recommendedIntensity": "RPE 8-9",
    "isOfficial": true,
    "trainingDays": [
      {
        "dayNumber": 1,
        "dayName": "训练A",
        "isRestDay": false,
        "intensityHint": "RPE 8-9",
        "warmupTips": "空杠热身3组，逐渐加重",
        "cooldownTips": "全身拉伸10分钟",
        "exercises": [
          {"name": "深蹲", "sets": 5, "reps": 5, "weight": 100, "restTime": 180, "muscleGroup": "腿部"},
          {"name": "器械推胸", "sets": 5, "reps": 5, "weight": 70, "restTime": 180, "muscleGroup": "胸部"},
          {"name": "杠铃划船", "sets": 5, "reps": 5, "weight": 60, "restTime": 180, "muscleGroup": "背部"}
        ],
        "notes": "5x5核心训练，专注于动作质量"
      },
      {
        "dayNumber": 2,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "肌肉恢复生长"
      },
      {
        "dayNumber": 3,
        "dayName": "训练B",
        "isRestDay": false,
        "intensityHint": "RPE 8-9",
        "warmupTips": "空杠热身3组，逐渐加重",
        "cooldownTips": "全身拉伸10分钟",
        "exercises": [
          {"name": "深蹲", "sets": 5, "reps": 5, "weight": 100, "restTime": 180, "muscleGroup": "腿部"},
          {"name": "杠铃推举", "sets": 5, "reps": 5, "weight": 45, "restTime": 180, "muscleGroup": "肩部"},
          {"name": "硬拉", "sets": 1, "reps": 5, "weight": 120, "restTime": 300, "muscleGroup": "全身"}
        ],
        "notes": "硬拉只做1组5次，注意腰背保护"
      },
      {
        "dayNumber": 4,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "充分休息"
      },
      {
        "dayNumber": 5,
        "dayName": "训练A",
        "isRestDay": false,
        "intensityHint": "RPE 8-9",
        "warmupTips": "空杠热身3组",
        "cooldownTips": "全身拉伸10分钟",
        "exercises": [
          {"name": "深蹲", "sets": 5, "reps": 5, "weight": 102.5, "restTime": 180, "muscleGroup": "腿部", "notes": "+2.5kg"},
          {"name": "器械推胸", "sets": 5, "reps": 5, "weight": 72.5, "restTime": 180, "muscleGroup": "胸部", "notes": "+2.5kg"},
          {"name": "杠铃划船", "sets": 5, "reps": 5, "weight": 62.5, "restTime": 180, "muscleGroup": "背部", "notes": "+2.5kg"}
        ],
        "notes": "每次训练增加2.5kg，渐进超负荷"
      },
      {
        "dayNumber": 6,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "周末休息"
      },
      {
        "dayNumber": 7,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "准备下周训练"
      }
    ]
  }'

echo ""
echo "✅ 模板5创建完成"

# 模板6: 居家徒手训练 (初级)
curl -X POST "$API_BASE/admin/templates" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "居家徒手健身计划",
    "description": "无需器械，在家即可完成的全身训练计划，适合没有健身房条件的训练者。",
    "goal": "综合健身",
    "splitType": "全身训练",
    "level": "初级",
    "equipment": "徒手",
    "durationWeeks": 4,
    "trainingDaysPerWeek": 4,
    "author": "FitEasy官方",
    "tags": ["居家", "徒手", "无器械"],
    "recommendedIntensity": "RPE 6-7",
    "isOfficial": true,
    "trainingDays": [
      {
        "dayNumber": 1,
        "dayName": "上肢训练",
        "isRestDay": false,
        "intensityHint": "RPE 6-7",
        "warmupTips": "手臂环绕，肩部热身",
        "cooldownTips": "上肢拉伸5分钟",
        "exercises": [
          {"name": "俯卧撑", "sets": 4, "reps": 12, "weight": 0, "restTime": 60, "muscleGroup": "胸部"},
          {"name": "俯卧撑", "sets": 3, "reps": 10, "weight": 0, "restTime": 60, "muscleGroup": "胸部", "notes": "窄距俯卧撑"},
          {"name": "俯卧撑", "sets": 3, "reps": 12, "weight": 0, "restTime": 60, "muscleGroup": "胸部", "notes": "宽距俯卧撑"},
          {"name": "双杠臂屈伸", "sets": 3, "reps": 10, "weight": 0, "restTime": 60, "muscleGroup": "手臂"},
          {"name": "山羊挺身", "sets": 3, "reps": 15, "weight": 0, "restTime": 45, "muscleGroup": "背部"}
        ],
        "notes": "注意俯卧撑的身体保持一条直线"
      },
      {
        "dayNumber": 2,
        "dayName": "下肢训练",
        "isRestDay": false,
        "intensityHint": "RPE 6-7",
        "warmupTips": "原地踏步热身",
        "cooldownTips": "腿部拉伸8分钟",
        "exercises": [
          {"name": "徒手深蹲", "sets": 4, "reps": 20, "weight": 0, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "弓步蹲", "sets": 3, "reps": 12, "weight": 0, "restTime": 60, "muscleGroup": "腿部"},
          {"name": "臀桥", "sets": 4, "reps": 15, "weight": 0, "restTime": 45, "muscleGroup": "腿部"},
          {"name": "臀桥", "sets": 3, "reps": 12, "weight": 0, "restTime": 45, "muscleGroup": "腿部", "notes": "单腿臀桥"},
          {"name": "徒手深蹲", "sets": 3, "reps": 30, "weight": 0, "restTime": 45, "muscleGroup": "腿部", "notes": "保持30秒"}
        ],
        "notes": "深蹲注意膝盖不要内扣"
      },
      {
        "dayNumber": 3,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "休息或轻度拉伸"
      },
      {
        "dayNumber": 4,
        "dayName": "核心训练",
        "isRestDay": false,
        "intensityHint": "RPE 6-7",
        "warmupTips": "身体激活热身",
        "cooldownTips": "全身拉伸",
        "exercises": [
          {"name": "仰卧抬腿", "sets": 4, "reps": 15, "weight": 0, "restTime": 45, "muscleGroup": "核心"},
          {"name": "仰卧起坐", "sets": 4, "reps": 20, "weight": 0, "restTime": 45, "muscleGroup": "核心"},
          {"name": "俄罗斯转体", "sets": 3, "reps": 20, "weight": 0, "restTime": 45, "muscleGroup": "核心"},
          {"name": "交替卷腹", "sets": 3, "reps": 20, "weight": 0, "restTime": 45, "muscleGroup": "核心"},
          {"name": "剪刀腿", "sets": 3, "reps": 20, "weight": 0, "restTime": 45, "muscleGroup": "核心"}
        ],
        "notes": "核心训练保持呼吸稳定"
      },
      {
        "dayNumber": 5,
        "dayName": "全身训练",
        "isRestDay": false,
        "intensityHint": "RPE 7-8",
        "warmupTips": "5分钟动态热身",
        "cooldownTips": "5分钟拉伸放松",
        "exercises": [
          {"name": "徒手深蹲", "sets": 4, "reps": 20, "weight": 0, "restTime": 30, "muscleGroup": "腿部"},
          {"name": "俯卧撑", "sets": 4, "reps": 12, "weight": 0, "restTime": 30, "muscleGroup": "胸部"},
          {"name": "仰卧抬腿", "sets": 4, "reps": 15, "weight": 0, "restTime": 30, "muscleGroup": "核心"},
          {"name": "弓步蹲", "sets": 4, "reps": 12, "weight": 0, "restTime": 30, "muscleGroup": "腿部"},
          {"name": "臀桥", "sets": 4, "reps": 15, "weight": 0, "restTime": 30, "muscleGroup": "臀部"}
        ],
        "notes": "全身训练，保持较短休息时间"
      },
      {
        "dayNumber": 6,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "周末休息"
      },
      {
        "dayNumber": 7,
        "dayName": "休息日",
        "isRestDay": true,
        "notes": "为下周做准备"
      }
    ]
  }'

echo ""
echo "✅ 模板6创建完成"

echo ""
echo "🎉 所有官方训练模板创建完成！共6个模板"
echo "- 新手全身入门计划 (初级)"
echo "- 经典推拉腿三分化 (中级)"
echo "- 上下肢二分化计划 (中级)"
echo "- 高效减脂力量计划 (中级)"
echo "- 力量提升5x5计划 (高级)"
echo "- 居家徒手健身计划 (初级)"

