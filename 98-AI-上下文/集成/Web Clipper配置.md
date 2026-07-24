---
type: integration-guide
status: needs-manual-browser-step
tags:
  - workflow/research
  - topic/obsidian
---

# Web Clipper 配置

可导入模板：

`98-AI-上下文/集成/研究资料收集.json`

## 浏览器操作

1. 安装官方 **Obsidian Web Clipper** 扩展。
2. 打开设置并选择 Vault `ob仓库`。
3. 打开 **Templates**，导入 `研究资料收集.json`。
4. 确认目标路径为 `00-收件箱/已下载`。
5. 剪藏一篇文章，确认标题、网址、作者、发布时间、收集时间和完整正文均已保留。

浏览器扩展把配置保存在浏览器配置文件中，而不是 Vault 中。本 Vault 内的 JSON 文件是长期有效的配置源和导入备份。

## 收集后处理

运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\98-AI-上下文\自动化\研究资料清洗器.ps1"
```

原始资料在 `已下载` 中保持不变；清洗后的 Markdown 创建在 `已清洗` 中。
