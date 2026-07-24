---
title: "AI 原生知识库"
type: project-status
status: active
owner: gxpqaznew
created: "2026-07-24"
updated: "2026-07-24"
tags:
  - project
---

# AI 原生知识库 — 项目状态

## 当前状态

**阶段：** 基础架构和主要集成已完成
**目标：** 建立一套长期可用的 AI 原生 Obsidian 知识系统，支持 GitHub 同步、知识图谱、研究处理、项目、提示词、记忆和内容工作流。
**成功标准：** Vault 结构有效、脚本检查通过、GitHub 推送成功、Obsidian Git 正常加载、收集模板可用，并且真实研究资料可以无重复地完成分类。

## 已完成

- [x] 检查 Obsidian、Vault、权限、GitHub CLI、仓库、插件和目录结构。
- [x] 建立核心信息架构。
- [x] 建立 Inbox、Research、Content、Projects、提示词库、模板、AI 记忆、AI 上下文和归档系统。
- [x] 建立主题中心、标签规则、内部链接规则和知识地图。
- [x] 建立研究资料清洗器、知识图谱更新器、项目生成器和知识库巡检。
- [x] 安装系统 Git 和 Obsidian Git 2.38.6。
- [x] 配置 Web Clipper，并用其替代不可用的 MarkDownload。
- [x] 初始化本地 Git 仓库并连接私有 GitHub 远端。
- [x] 验证 Obsidian Git Pull 和 Commit-and-sync。

## 待办事项

- [x] 重启 Obsidian 并确认 Obsidian Git 正常加载。
- [x] 将 `Research Capture.json` 导入 Web Clipper。
- [x] 确认使用 Web Clipper 替代 MarkDownload。
- [ ] 确认主要研究领域。
- [ ] 确认发布平台、内容形式、受众和写作风格。
- [ ] 导入真实研究资料，并检查首次生成的分类和主题中心索引。

## 下一步行动

- [ ] 补充研究领域和内容定位，然后导入第一批真实研究资料。

## 风险

| 风险 | 影响 | 应对措施 |
| --- | --- | --- |
| 提供的路径指向父目录，而不是实际 Vault。 | Agent 或工具可能写入错误层级。 | 除非用户明确调整结构，否则以 `C:\ob仓库\ob仓库` 为准。 |
| 研究领域尚未明确。 | 猜测式目录会造成分类负担。 | 在证据或用户输入确立领域前，只保留 `General` 兜底分类。 |
| 浏览器扩展配置保存在本地浏览器配置中。 | 仅靠 Git 无法完整复现 Web Clipper 设置。 | 在 Vault 中保留可导入模板和明确配置指南。 |

## 决策

| 日期 | 决策 | 理由 |
| --- | --- | --- |
| 2026-07-24 | 使用一个主目录，配合多个主题标签和链接。 | 避免重复笔记，同时支持跨领域发现。 |
| 2026-07-24 | 保持原始下载资料不可修改。 | 保留证据，并使清洗过程可逆。 |
| 2026-07-24 | 不强制重启 Obsidian。 | 避免干扰已打开窗口或未保存工作。 |

## 相关研究

- [[98-AI-Context/Knowledge Map]]
- [[98-AI-Context/AI Operating Context]]
- [[04-Research/Topic-Hubs/Obsidian Hub]]
- [[04-Research/Topic-Hubs/GitHub Hub]]
