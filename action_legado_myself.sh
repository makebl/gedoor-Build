#!/bin/sh
# 本脚本用来个性化定制app, 不修改任何核心功能但增强体验
source $GITHUB_WORKSPACE/action_util.sh

# ========== 通用定制功能 ==========

# 清空 18Plus
function app_clear_18plus() {
    debug "清空 18PlusList.txt"
    echo "" > $APP_WORKSPACE/app/src/main/assets/18PlusList.txt
}

# 更改 App 启动名称 & WebDAV 目录后缀
function app_rename() {
    debug "更改桌面启动名称为 $APP_LAUNCH_NAME"
    sed 's/"app_name">阅读/"app_name">'"$APP_LAUNCH_NAME"'/'         $APP_WORKSPACE/app/src/main/res/values-zh/strings.xml -i

    debug "更改 WebDAV 目录后缀为 $APP_SUFFIX"
    find $APP_WORKSPACE/app/src -regex '.*/storage/.*.kt' -exec         sed "s/\${url}legado/&$APP_SUFFIX/" {} -i
}

# APK 支持共存安装
function app_live_together() {
    debug "设置支持共存安装"
    sed "s/'.release'/'.release$APP_SUFFIX'/"         $APP_WORKSPACE/app/build.gradle -i
    sed "s/.release/.release$APP_SUFFIX/"         $APP_WORKSPACE/app/google-services.json -i
}

# APK 签名
function app_sign() {
    debug "添加签名配置"
    cp $GITHUB_WORKSPACE/.github/legado/legado.jks        $APP_WORKSPACE/app/legado.jks
    sed '$r '"$GITHUB_WORKSPACE/.github/legado/legado.sign"''        $APP_WORKSPACE/gradle.properties -i
}

# 可选启用资源压缩
function app_minify() {
    if [[ "$SECRETS_MINIFY" == "true" ]]; then
        debug "启用资源压缩"
        sed -e '/minifyEnabled/i\            shrinkResources true'             -e 's/minifyEnabled false/minifyEnabled true/'             $APP_WORKSPACE/app/build.gradle -i
    fi
}

# ========== 自定义优化增强 ==========

# 优化发现界面提示 & 超时
function exploreShow_be_better() {
    debug "优化发现界面加载体验"
    find $APP_WORKSPACE/app/src -regex '.*/ExploreShowActivity.kt' -exec     sed -e "/loadMoreView.error(it)/i\isLoading = false"         -e "/ExploreShowActivity/i\import io.legado.app.utils.longToastOnUi"         -e '/loadMoreView.error(it)/i\longToastOnUi(it)'         -e 's/loadMoreView.error(it)/loadMoreView.error("目标网站连接失败或超时")/'         {} -i

    find $APP_WORKSPACE/app/src -regex '.*/ExploreShowViewModel.kt' -exec         sed "s/30000L/8000L/" {} -i
}

# 发现页增加搜索能力
function explore_can_search() {
    debug "添加发现页搜索能力"
    find $APP_WORKSPACE/app/src -regex '.*/ExploreFragment.kt' -exec     sed -e 's/getString(R.string.screen_find)/"搜索书籍、书源"/'         -e '/fun initSearchView()/i\override fun onResume(){super.onResume();searchView.clearFocus()}'         -e '/ExploreFragment/i\import io.legado.app.ui.book.search.SearchActivity'         -e '/onQueryTextSubmit/a\if(!query?.contains("group:")!!){startActivity<SearchActivity> { putExtra("key", query) }}'         {} -i
}

# 替换启动图标
function my_launcher_icon() {
    debug "替换自定义图标"
    find $APP_WORKSPACE/app/src -type d -regex '.*/res/drawable' -exec         cp $GITHUB_WORKSPACE/.github/legado/ic_launcher_my.xml {}/ic_launcher1.xml \;

    find $APP_WORKSPACE/app/src -regex '.*/res/.*/ic_launcher.xml' -exec         sed "/background/d" {} -i
}

# 删除 Firebase / Google 依赖
function no_google_services() {
    debug "删除 Google/Firebase 相关依赖"
    sed -e "/com.google.firebase/d"         -e "/com.google.gms/d"         -e "/androidx.appcompat/a\    implementation 'androidx.documentfile:documentfile:1.0.1'"         $APP_WORKSPACE/app/build.gradle -i
}

# 关闭书架提示
function bookshelf_hide_tips() {
    debug "关闭书架提示"
    find "$APP_WORKSPACE/app/src" -regex '.*/BookcaseFragment.kt' -exec         sed -e 's/showAddTip = true/showAddTip = false/'             -e 's/showGuide = true/showGuide = false/'             -e 's/showAddTip()/\/\/ showAddTip()/'             -e 's/showGuide()/\/\/ showGuide()/'             {} -i
}

# ========== 执行顺序 ==========

app_sign
app_minify
app_clear_18plus
app_rename
app_live_together

# 仅对 legado 执行定制增强
if [[ "$APP_NAME" == "legado" ]]; then
    exploreShow_be_better
    explore_can_search
    no_google_services
    my_launcher_icon
    bookshelf_hide_tips
fi
