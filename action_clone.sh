#!/bin/sh
source $GITHUB_WORKSPACE/action_util.sh

function init_workspace()
{
    debug "开始克隆 master 分支源码"

    echo "👉 APP_GIT_URL = $APP_GIT_URL"
    echo "👉 APP_WORKSPACE = $APP_WORKSPACE"

    if [ -z "$APP_GIT_URL" ]; then
        echo "❌ APP_GIT_URL 为空，无法克隆仓库"
        exit 1
    fi

    git clone --branch master "$APP_GIT_URL" "$APP_WORKSPACE"
    if [ $? -ne 0 ] || [ ! -d "$APP_WORKSPACE" ]; then
        echo "❌ 克隆失败，$APP_WORKSPACE 目录不存在"
        exit 1
    fi

    cd "$APP_WORKSPACE" || {
        echo "❌ 切换目录失败：$APP_WORKSPACE"
        exit 1
    }

    set_env APP_UPLOAD_NAME "$APP_NAME-master-$(TZ='Asia/Shanghai' date +'%Y%m%d-%H%M')"
    debug "✅ 克隆完成：$APP_UPLOAD_NAME"
}

init_workspace
