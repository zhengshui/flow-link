#!/bin/zsh

# 确保路径正确
cd "$(dirname "$0")" || exit

# 设置 DevEco SDK 环境变量
export DEVECO_SDK_HOME="/Applications/DevEco-Studio.app/Contents"
export HVIGOR_HOME="$DEVECO_SDK_HOME/tools/hvigor"
export PATH="$HVIGOR_HOME/bin:$PATH"

# 停止之前可能存在的 hvigor Daemon
hvigorw --stop-daemon

# 构建
echo "🚀 Building HarmonyOS Hap..."
hvigorw assembleHap
