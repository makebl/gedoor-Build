#!/bin/sh
source $GITHUB_WORKSPACE/action_util.sh

function init_workspace()
{
    debug "克隆 master 分支源码"

    if [ -z "$APP_GIT_URL" ]; then
        echo "❌ APP_GIT_URL 为空，无法克隆仓库"
        exit 1
    fi

    git clone --branch master "$APP_GIT_URL" "$APP_WORKSPACE"
    if [ ! -d "$APP_WORKSPACE" ]; then
        echo "❌ 克隆失败，$APP_WORKSPACE 目录不存在"
        exit 1
    fi

    cd "$APP_WORKSPACE"

    set_env APP_UPLOAD_NAME "$APP_NAME-master-$(date +'%Y%m%d-%H%M')"
}

init_workspace
