#!/bin/sh
# 本脚本用来个性化定制 app，包含签名、共存、重命名、最小化等处理

source $GITHUB_WORKSPACE/action_util.sh

# 去除 18+ 限制内容
function app_clear_18plus() {
    if [[ "$APP_NAME" == "legado" ]]; then
        debug "清空 18PlusList.txt"
        echo "" > "$APP_WORKSPACE/app/src/main/assets/18PlusList.txt"
    fi
}

# 无条件修改启动桌面名称为 APP_LAUNCH_NAME
function app_rename() {
    if [[ "$APP_NAME" == "legado" ]]; then
        debug "更改桌面启动名称为 $APP_LAUNCH_NAME"
        sed -i "s#\"app_name\">阅读#\"app_name\">$APP_LAUNCH_NAME#"             "$APP_WORKSPACE/app/src/main/res/values-zh/strings.xml"
        debug "更改 webdav 备份路径为含后缀"
        find "$APP_WORKSPACE/app/src" -regex '.*/storage/.*.kt' -exec             sed -i "s/\${url}legado/&$APP_SUFFIX/" {} +
    fi
}

# 删除不必要的资源（未启用）
function app_resources_unuse() {
    if [[ "$APP_NAME" == "legado" ]]; then
        debug "删除一些用不到的资源"
        rm -rf "$APP_WORKSPACE/app/src/main/assets/bg"
    fi
}

# 启用资源压缩以缩小 APK 体积
function app_minify() {
    if [[ "$APP_NAME" == "legado" ]]; then
        debug "启用 shrinkResources 和 minifyEnabled"
        sed -e '/minifyEnabled/i\            shrinkResources true'             -e 's/minifyEnabled false/minifyEnabled true/'             -i "$APP_WORKSPACE/app/build.gradle"
    fi
}

# 支持安装共存
function app_live_together() {
    if [[ "$APP_NAME" == "legado" ]]; then
        debug "处理共存包名标识"
        sed -i "s/'.release'/'.release$APP_SUFFIX'/" "$APP_WORKSPACE/app/build.gradle"
        sed -i "s/.release/.release$APP_SUFFIX/" "$APP_WORKSPACE/app/google-services.json"
    fi
}

# 签名处理
function app_sign() {
    debug "复制签名文件并注入 gradle.properties"
    cp "$GITHUB_WORKSPACE/.github/legado/legado.jks" "$APP_WORKSPACE/app/legado.jks"
    sed -i -e '$r '"$GITHUB_WORKSPACE/.github/legado/legado.sign"'' "$APP_WORKSPACE/gradle.properties"
}

# 禁用部分插件（适用于 MyBookshelf）
function app_not_apply_plugin() {
    if [[ "$APP_NAME" == "MyBookshelf" ]]; then
        debug "移除 Google/Firebase 插件"
        sed -i -e '/io.fabric/d' -e '/com.google.firebase/d' -e '/com.google.gms/d'             "$APP_WORKSPACE/app/build.gradle"
    fi
}

# 签名
app_sign

# 压缩资源（需开启）
[[ "$SECRETS_MINIFY" == "true" ]] && app_minify

# 应用基础定制
app_clear_18plus
app_rename
app_live_together
