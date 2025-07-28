#!/bin/sh
# 构建名格式为 legado-3.25.20250729-0835.apk（北京时间）

function set_env() { echo "$1=$2" >> $GITHUB_ENV; }

APP_NAME="legado"
APP_GIT_URL="https://github.com/gedoor/legado.git"
APP_SUFFIX="A"
APP_WORKSPACE="/opt/$APP_NAME"
APP_UPLOAD="$APP_WORKSPACE/app/build/outputs/apk/app/release"
APP_LAUNCH_NAME="阅读.$APP_SUFFIX"

GITHUB_API_LATEST="https://api.github.com/repos/gedoor/legado/releases/latest"

set_env APP_NAME        $APP_NAME
set_env APP_GIT_URL     $APP_GIT_URL
set_env APP_LAUNCH_NAME $APP_LAUNCH_NAME
set_env APP_WORKSPACE   $APP_WORKSPACE
set_env APP_SUFFIX      $APP_SUFFIX
set_env APP_UPLOAD      $APP_UPLOAD
set_env SECRETS_MINIFY  $SECRETS_MINIFY 
set_env SECRETS_RENAME  $SECRETS_RENAME 

# 使用北京时间
export TZ="Asia/Shanghai"
LatestTag=$(curl -s $GITHUB_API_LATEST | jq .tag_name -r)
LatestCheck=$(date "+%Y-%m-%d %H:%M:%S")
BuildStamp=$(date "+%Y%m%d-%H%M")

# 下载 release body 内容
curl -s $GITHUB_API_LATEST | jq .body -r > /opt/latest.md

# 设置用于 release 的信息
SimpleName="$APP_NAME-$LatestTag.$BuildStamp"

set_env LATEST_TAG         $LatestTag
set_env APP_LATEST_TAG     $(echo $LatestTag | grep -o '3\.[0-9]\{2\}\.[0-9]\{6\}')
set_env APP_LATEST_BODY    "/opt/latest.md"
set_env APP_LATEST_CHECK   "$LatestCheck"
set_env BUILD_TIME         "$BuildStamp"
set_env APP_UPLOAD_NAME    "$SimpleName"
set_env APP_RELEASE_NAME   "$SimpleName.apk"
set_env APP_RELEASE        "$APP_UPLOAD/$SimpleName.apk"
set_env APP_LAST_TAG       $(cat $GITHUB_WORKSPACE/.lastcheck | sed -n 1p)
