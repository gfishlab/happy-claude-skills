## Agent 工程运行约定

- `.codex/rules`：任务分类、记忆写入、子代理路由、验证清单等执行细则
- `.codex/hooks`：任务开始、任务结束、失败复盘、提交前检查等关键阶段触发约定
- `.codex/memory`：纠正记录、阶段观察、已学规则、反模式、演化日志等工程记忆
- `.codex/subagents`：`planner`、`executor`、`verifier` 等子代理职责说明

## 默认加载顺序

1. 识别任务作用域、影响路径与模块范围
2. 读取本 `AGENTS.md`
3. 按任务类型读取 `.codex/rules`
4. 按需读取 `.codex/memory`
5. 判断是否启用子代理分工
6. 执行任务
7. 在关键 hook 阶段完成验证、复盘与沉淀
