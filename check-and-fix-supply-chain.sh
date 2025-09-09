#!/usr/bin/env bash
set -euo pipefail

# 检测包管理器
detect_package_manager() {
  if [ -f "yarn.lock" ]; then
    echo "yarn"
  elif [ -f "package-lock.json" ]; then
    echo "npm"
  elif [ -f "pnpm-lock.yaml" ]; then
    echo "pnpm"
  else
    # 检查可用的包管理器
    if command -v yarn >/dev/null 2>&1; then
      echo "yarn"
    elif command -v pnpm >/dev/null 2>&1; then
      echo "pnpm"
    elif command -v npm >/dev/null 2>&1; then
      echo "npm"
    else
      echo "unknown"
    fi
  fi
}

# 设置包管理器相关变量
PACKAGE_MANAGER=$(detect_package_manager)
case $PACKAGE_MANAGER in
  "yarn")
    LOCK_FILE="yarn.lock"
    INSTALL_CMD="yarn install"
    CLEAN_CMD="rm -rf node_modules yarn.lock"
    ;;
  "npm")
    LOCK_FILE="package-lock.json"
    INSTALL_CMD="npm install"
    CLEAN_CMD="rm -rf node_modules package-lock.json"
    ;;
  "pnpm")
    LOCK_FILE="pnpm-lock.yaml"
    INSTALL_CMD="pnpm install"
    CLEAN_CMD="rm -rf node_modules pnpm-lock.yaml"
    ;;
  *)
    echo "❌ 未检测到支持的包管理器 (yarn/npm/pnpm)"
    exit 1
    ;;
esac

echo "=== 2025年9月 npm 供应链攻击检测与修复工具 ==="
echo "检测到包管理器: $PACKAGE_MANAGER"
echo "锁定文件: $LOCK_FILE"
echo "受影响的包版本："
echo "- debug@4.4.2"
echo "- color-name@2.0.1" 
echo "- strip-ansi@7.1.1"
echo "- color@5.0.1"
echo "- color-convert@3.1.1"
echo "- color-string@2.1.1"
echo "- has-ansi@6.0.1"
echo "- ansi-styles@6.2.2"
echo "- ansi-regex@6.2.1"
echo "- supports-color@10.2.1"
echo "- chalk@5.6.1"
echo "- backslash@0.2.1"
echo "- wrap-ansi@9.0.1"
echo "- is-arrayish@0.3.3"
echo "- error-ex@1.3.3"
echo "- slice-ansi@7.1.1"
echo "- simple-swizzle@0.2.3"
echo "- chalk-template@1.1.1"
echo "- supports-hyperlinks@4.1.1"
echo

# 第 1 步：使用 Semgrep 进行深度检测
echo "=== [1/4] 使用 Semgrep 检查是否含已知恶意版本 ==="
if command -v semgrep >/dev/null 2>&1; then
  semgrep --config=https://semgrep.dev/c/r/kxUgZJg/semgrep.ssc-mal-deps-mit-2025-09-chalk-debug-color || true
else
  echo "⚠️ Semgrep 未安装，请先安装：pip3 install semgrep / brew install semgrep"
  echo "   继续使用其他方法检测..."
fi

# 第 2 步：检查锁定文件中是否有受影响的版本
echo
echo "=== [2/4] 检查当前依赖中的受影响版本 ==="
VULNERABLE_FOUND=false

# 定义受影响的版本
declare -a VULNERABLE_VERSIONS=(
  "debug@4.4.2"
  "color-name@2.0.1"
  "strip-ansi@7.1.1"
  "color@5.0.1"
  "color-convert@3.1.1"
  "color-string@2.1.1"
  "has-ansi@6.0.1"
  "ansi-styles@6.2.2"
  "ansi-regex@6.2.1"
  "supports-color@10.2.1"
  "chalk@5.6.1"
  "backslash@0.2.1"
  "wrap-ansi@9.0.1"
  "is-arrayish@0.3.3"
  "error-ex@1.3.3"
  "slice-ansi@7.1.1"
  "simple-swizzle@0.2.3"
  "chalk-template@1.1.1"
  "supports-hyperlinks@4.1.1"
)

if [ -f "$LOCK_FILE" ]; then
  for version in "${VULNERABLE_VERSIONS[@]}"; do
    if grep -q "\"$version\"" "$LOCK_FILE"; then
      echo "❌ 发现受影响的版本: $version"
      VULNERABLE_FOUND=true
    fi
  done
  
  if [ "$VULNERABLE_FOUND" = false ]; then
    echo "✅ 未发现受影响的包版本"
  fi
else
  echo "⚠️ 未找到 $LOCK_FILE 文件，将重新生成"
fi

# 第 3 步：生成安全版本修复方案
echo
echo "=== [3/4] 生成安全版本修复方案 ==="

# 定义安全版本映射
CHALK_SAFE="5.3.0"
STRIP_ANSI_SAFE="7.1.0"
COLOR_CONVERT_SAFE="2.0.1"
COLOR_NAME_SAFE="1.1.4"
DEBUG_SAFE="4.3.4"
ANSI_REGEX_SAFE="5.0.1"
COLOR_SAFE="4.1.0"
COLOR_STRING_SAFE="2.0.0"
HAS_ANSI_SAFE="5.0.0"
ANSI_STYLES_SAFE="6.2.1"
SUPPORTS_COLOR_SAFE="10.1.0"
BACKSLASH_SAFE="0.1.0"
WRAP_ANSI_SAFE="8.1.0"
IS_ARRAYISH_SAFE="0.2.2"
ERROR_EX_SAFE="1.3.2"
SLICE_ANSI_SAFE="6.0.0"
SIMPLE_SWIZZLE_SAFE="0.2.2"
CHALK_TEMPLATE_SAFE="1.0.0"
SUPPORTS_HYPERLINKS_SAFE="3.0.0"

# 创建 patch
PATCH_FILE="resolutions-patch.json"

# 根据包管理器设置正确的字段名
case $PACKAGE_MANAGER in
  "yarn")
    RESOLUTIONS_FIELD="resolutions"
    ;;
  "npm")
    RESOLUTIONS_FIELD="overrides"
    ;;
  "pnpm")
    RESOLUTIONS_FIELD="pnpm.overrides"
    ;;
esac

jq -n --arg field "$RESOLUTIONS_FIELD" '{($field): {}}' > "$PATCH_FILE"

# 检查并添加需要修复的包
NEED_FIX=false

if [ -f "$LOCK_FILE" ]; then
  if grep -q "\"chalk@" "$LOCK_FILE"; then
    echo "  - 包含 chalk，推荐锁定为安全版本 $CHALK_SAFE"
    jq --arg pkg "chalk" --arg ver "$CHALK_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"strip-ansi@" "$LOCK_FILE"; then
    echo "  - 包含 strip-ansi，推荐锁定为安全版本 $STRIP_ANSI_SAFE"
    jq --arg pkg "strip-ansi" --arg ver "$STRIP_ANSI_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"color-convert@" "$LOCK_FILE"; then
    echo "  - 包含 color-convert，推荐锁定为安全版本 $COLOR_CONVERT_SAFE"
    jq --arg pkg "color-convert" --arg ver "$COLOR_CONVERT_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"color-name@" "$LOCK_FILE"; then
    echo "  - 包含 color-name，推荐锁定为安全版本 $COLOR_NAME_SAFE"
    jq --arg pkg "color-name" --arg ver "$COLOR_NAME_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"debug@" "$LOCK_FILE"; then
    echo "  - 包含 debug，推荐锁定为安全版本 $DEBUG_SAFE"
    jq --arg pkg "debug" --arg ver "$DEBUG_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"ansi-regex@" "$LOCK_FILE"; then
    echo "  - 包含 ansi-regex，推荐锁定为安全版本 $ANSI_REGEX_SAFE"
    jq --arg pkg "ansi-regex" --arg ver "$ANSI_REGEX_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  # 检查其他可能受影响的包
  if grep -q "\"color@" "$LOCK_FILE"; then
    echo "  - 包含 color，推荐锁定为安全版本 $COLOR_SAFE"
    jq --arg pkg "color" --arg ver "$COLOR_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"color-string@" "$LOCK_FILE"; then
    echo "  - 包含 color-string，推荐锁定为安全版本 $COLOR_STRING_SAFE"
    jq --arg pkg "color-string" --arg ver "$COLOR_STRING_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"has-ansi@" "$LOCK_FILE"; then
    echo "  - 包含 has-ansi，推荐锁定为安全版本 $HAS_ANSI_SAFE"
    jq --arg pkg "has-ansi" --arg ver "$HAS_ANSI_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"ansi-styles@" "$LOCK_FILE"; then
    echo "  - 包含 ansi-styles，推荐锁定为安全版本 $ANSI_STYLES_SAFE"
    jq --arg pkg "ansi-styles" --arg ver "$ANSI_STYLES_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi

  if grep -q "\"supports-color@" "$LOCK_FILE"; then
    echo "  - 包含 supports-color，推荐锁定为安全版本 $SUPPORTS_COLOR_SAFE"
    jq --arg pkg "supports-color" --arg ver "$SUPPORTS_COLOR_SAFE" --arg field "$RESOLUTIONS_FIELD" '.[$field][$pkg] = $ver' "$PATCH_FILE" > tmp.json
    mv tmp.json "$PATCH_FILE"
    NEED_FIX=true
  fi
fi

echo "生成的 patch 文件：$PATCH_FILE"
cat "$PATCH_FILE"

# 第 4 步：应用修复（如果需要）
echo
echo "=== [4/4] 应用安全修复 ==="

if [ "$NEED_FIX" = true ] || [ "$VULNERABLE_FOUND" = true ]; then
  echo "发现需要修复的依赖，开始应用修复..."
  
  # 备份原始文件
  cp package.json package.json.bak
  echo "已备份 package.json => package.json.bak"
  
  if ! command -v jq >/dev/null 2>&1; then
    echo "⚠️ 需要 jq，请先安装（macOS: brew install jq）"
    exit 1
  fi
  
  # 应用 resolutions/overrides
  if [ -s "$PATCH_FILE" ] && [ "$(jq -r --arg field "$RESOLUTIONS_FIELD" '.[$field] | keys | length' "$PATCH_FILE")" -gt 0 ]; then
    TMP=$(mktemp)
    jq --slurpfile res "$PATCH_FILE" --arg field "$RESOLUTIONS_FIELD" '
      .[$field] = (($res[0][$field] // {}) + (.[$field] // {}))
    ' package.json > "$TMP"
    mv "$TMP" package.json
    echo "已更新 package.json，添加 $RESOLUTIONS_FIELD 字段"
    
    # 清理并重新安装
    echo "清理并重新安装依赖..."
    $CLEAN_CMD
    $INSTALL_CMD
    
    echo "🎉 修复完成！已使用安全版本替换受影响依赖。"
  else
    echo "没有需要添加的 resolutions"
  fi
else
  echo "✅ 未发现需要修复的依赖，项目是安全的！🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🌹🌹🌹"
fi

# 清理临时文件
echo
echo "=== 清理临时文件 ==="
if [ -f "$PATCH_FILE" ]; then
  if [ "$(jq -r --arg field "$RESOLUTIONS_FIELD" '.[$field] | keys | length' "$PATCH_FILE")" -eq 0 ]; then
    echo "删除空的临时文件: $PATCH_FILE"
    rm -f "$PATCH_FILE"
  else
    echo "保留包含修复方案的临时文件: $PATCH_FILE"
    echo "内容预览:"
    cat "$PATCH_FILE"
  fi
fi

echo
echo "=== 建议的安全措施 ==="
echo "1. 定期运行此脚本检查供应链攻击"
echo "2. 在 CI/CD 中集成依赖扫描"
echo "3. 定期更新依赖包到最新安全版本"
echo "4. 使用 $LOCK_FILE 锁定依赖版本"
echo "5. 考虑使用 npm audit 或 yarn npm audit 检查其他漏洞"
echo
echo "脚本执行完成！"