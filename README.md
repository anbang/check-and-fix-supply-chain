# check-and-fix-supply-chain

2025 年 9 月 npm 供应链攻击检测与修复工具

一个用于检测和修复 npm 供应链攻击的自动化脚本，专门针对 2025 年 9 月发现的恶意包版本进行检测和修复。

## 🚨 背景

2025 年 9 月，npm 生态系统遭受了大规模的供应链攻击，多个流行包被注入了恶意代码。本工具专门用于检测和修复这些受影响的包版本。

## ✨ 功能特性

- 🔍 **自动检测包管理器**：支持 yarn、npm、pnpm
- 🛡️ **深度安全扫描**：使用 Semgrep 进行恶意代码检测
- 📋 **依赖版本检查**：检查锁定文件中的受影响版本
- 🔧 **自动修复**：生成并应用安全版本修复方案
- 📊 **详细报告**：提供完整的检测和修复报告
- 🔄 **备份保护**：自动备份原始配置文件

## 🎯 受影响的包版本

脚本会检测以下受影响的包版本：

- `debug@4.4.2`
- `color-name@2.0.1`
- `strip-ansi@7.1.1`
- `color@5.0.1`
- `color-convert@3.1.1`
- `color-string@2.1.1`
- `has-ansi@6.0.1`
- `ansi-styles@6.2.2`
- `ansi-regex@6.2.1`
- `supports-color@10.2.1`
- `chalk@5.6.1`
- `backslash@0.2.1`
- `wrap-ansi@9.0.1`
- `is-arrayish@0.3.3`
- `error-ex@1.3.3`
- `slice-ansi@7.1.1`
- `simple-swizzle@0.2.3`
- `chalk-template@1.1.1`
- `supports-hyperlinks@4.1.1`

## 🚀 快速开始

### 1. 下载脚本

```bash
# 克隆仓库
git clone https://github.com/anbang/check-and-fix-supply-chain.git
cd check-and-fix-supply-chain

# 或者直接下载脚本
curl -O https://raw.githubusercontent.com/anbang/check-and-fix-supply-chain/main/check-and-fix-supply-chain.sh
```

### 2. 设置权限

```bash
chmod +x check-and-fix-supply-chain.sh
```

### 3. 运行脚本

在项目根目录下运行：

```bash
./check-and-fix-supply-chain.sh
```

## 📋 前置要求

### 必需工具

- **jq**：用于 JSON 处理

  ```bash
  # macOS
  brew install jq

  # Ubuntu/Debian
  sudo apt-get install jq

  # CentOS/RHEL
  sudo yum install jq
  ```

- **Semgrep**：用于深度安全扫描

  ```bash
  # 使用 pip
  pip3 install semgrep

  # 使用 Homebrew (macOS)
  brew install semgrep
  ```

Semgrep：需要 Python 3.9 或更高版本。


## 🔧 使用方法

### 基本用法

```bash
# 在项目根目录运行
./check-and-fix-supply-chain.sh
```

### 脚本执行流程

1. **检测包管理器**：自动识别项目使用的包管理器（yarn/npm/pnpm）
2. **Semgrep 扫描**：使用 Semgrep 进行深度恶意代码检测
3. **依赖版本检查**：检查锁定文件中的受影响版本
4. **生成修复方案**：为受影响的包生成安全版本修复方案
5. **应用修复**：自动应用修复并重新安装依赖

### 输出示例

```
=== 2025年9月 npm 供应链攻击检测与修复工具 ===
检测到包管理器: yarn
锁定文件: yarn.lock
受影响的包版本：
- debug@4.4.2
- color-name@2.0.1
...

=== [1/4] 使用 Semgrep 检查是否含已知恶意版本 ===
✅ Semgrep 扫描完成

=== [2/4] 检查当前依赖中的受影响版本 ===
❌ 发现受影响的版本: chalk@5.6.1

=== [3/4] 生成安全版本修复方案 ===
  - 包含 chalk，推荐锁定为安全版本 5.3.0

=== [4/4] 应用安全修复 ===
发现需要修复的依赖，开始应用修复...
已备份 package.json => package.json.bak
已更新 package.json，添加 resolutions 字段
清理并重新安装依赖...
🎉 修复完成！已使用安全版本替换受影响依赖。
```

## 📁 文件说明

- `check-and-fix-supply-chain.sh`：主脚本文件
- `package.json.bak`：自动备份的原始 package.json（如果进行了修复）
- `resolutions-patch.json`：生成的修复方案文件（临时文件）

## 🛡️ 安全版本映射

脚本会将受影响的包版本替换为以下安全版本：

| 包名           | 受影响版本 | 安全版本 |
| -------------- | ---------- | -------- |
| chalk          | 5.6.1      | 5.3.0    |
| strip-ansi     | 7.1.1      | 7.1.0    |
| color-convert  | 3.1.1      | 2.0.1    |
| color-name     | 2.0.1      | 1.1.4    |
| debug          | 4.4.2      | 4.3.4    |
| ansi-regex     | 6.2.1      | 5.0.1    |
| color          | 5.0.1      | 4.1.0    |
| color-string   | 2.1.1      | 2.0.0    |
| has-ansi       | 6.0.1      | 5.0.0    |
| ansi-styles    | 6.2.2      | 6.2.1    |
| supports-color | 10.2.1     | 10.1.0   |

## 🔄 包管理器支持

### Yarn

- 使用 `resolutions` 字段锁定版本
- 支持 `yarn.lock` 文件检测

### npm

- 使用 `overrides` 字段锁定版本
- 支持 `package-lock.json` 文件检测

### pnpm

- 使用 `pnpm.overrides` 字段锁定版本
- 支持 `pnpm-lock.yaml` 文件检测

## ⚠️ 注意事项

1. **备份重要**：脚本会自动备份 `package.json`，但建议在运行前手动备份整个项目
2. **测试环境**：建议先在测试环境中运行脚本
3. **依赖更新**：修复后可能需要测试应用程序功能
4. **定期检查**：建议定期运行此脚本检查新的供应链攻击

## 🚨 故障排除

### 常见问题

**Q: 脚本提示 "未检测到支持的包管理器"**
A: 确保项目根目录存在 `package.json` 文件，并且安装了 yarn、npm 或 pnpm 之一。

**Q: 提示 "需要 jq，请先安装"**
A: 请按照前置要求部分安装 jq 工具。

**Q: Semgrep 扫描失败**
A: Semgrep 是可选的，脚本会继续使用其他方法进行检测。

**Q: 修复后项目无法启动**
A: 检查 `package.json.bak` 备份文件，必要时可以恢复原始配置。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个工具！

## 📄 许可证

MIT License

## 🔗 相关链接

- [npm 安全公告](https://blog.npmjs.org/post/security-advisory)
- [Semgrep 官方文档](https://semgrep.dev/docs/)
- [供应链攻击防护最佳实践](https://owasp.org/www-project-supply-chain-security/)

---

**⚠️ 重要提醒**：此工具专门针对 2025 年 9 月的供应链攻击设计。请定期更新工具以应对新的安全威胁。
