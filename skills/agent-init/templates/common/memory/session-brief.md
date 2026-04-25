# 会话启动摘要

> 最后更新：待初始化
>
> 本文件用于 SessionStart hook 的轻量注入，只保留宏观项目状态和记忆读取策略。完整进度以 `project-progress.md` 为准。

## 宏观进度

- 当前阶段：待补充
- 已完成主线：待补充
- 进行中重点：待补充
- 未启动重点：待补充

## 读取策略

- 简单配置核查或单文件小改动：优先按任务作用域读取必要文件，不强制加载完整进度
- 中等及以上任务、跨模块任务、阶段规划、重大功能收口：先读取 `project-progress.md`，再按类型读取相关 `rules`、`memory` 和架构文档
- 大块功能模块完成、阶段性提交或路线变化后：主动更新 `project-progress.md`，并同步更新本摘要

## 事实源

- 完整进度：`memory/project-progress.md`
- 执行规则：`rules`
- 稳定架构事实源：`docs/architectures`
