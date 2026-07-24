---
type: integration-guide
status: active
tags:
  - workflow/git
  - topic/github
  - topic/obsidian
---

# GitHub 同步

## 仓库

- 远端：`https://github.com/gxpqaznew/ob-.git`
- 可见性：私有。
- 本地 Vault：`C:\ob仓库\ob仓库`

## 同步策略

- Obsidian 启动时拉取。
- 每 10 分钟自动备份。
- 自动备份成功后推送。
- 推送前先拉取。
- 不提交工作区布局、缓存、回收站、临时文件或秘密信息。

## 冲突恢复

如果自动同步报告冲突：

1. 停止编辑冲突笔记。
2. 打开 Git 历史并检查两个版本。
3. 如果含义不确定，保留两个来源版本。
4. 解决冲突后运行巡检，再提交并推送。
