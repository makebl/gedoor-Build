#!/bin/sh
# 应用用户提供的补丁文件
source $GITHUB_WORKSPACE/action_util.sh

# 假设补丁文件位于项目根目录下的 custom.patch
PATCH_FILE="$GITHUB_WORKSPACE/directlink_replacement.patch"

if [ -f "$PATCH_FILE" ]; then
    debug "正在应用补丁: $PATCH_FILE"
    # 使用 git apply 应用补丁
    git apply "$PATCH_FILE" || {
        error "补丁应用失败"
        exit 1
    }
    debug "补丁应用成功"
else
    error "未找到补丁文件: $PATCH_FILE"
    exit 1
fi