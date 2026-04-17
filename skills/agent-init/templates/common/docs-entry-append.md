## 文档规则

- `docs` 下只保留 `architectures`、`plans`、`tasks` 三类目录，不新增其他文档分类目录
- `docs/architectures` 存放当前正式生效的架构与技术设计，属于稳定事实源
- `docs/plans` 存放当前仍有效的阶段性方案、设计推演与实施计划
- `docs/tasks` 存放当前执行型文档，一个 plan 可以对应多个 task 文件
- 三类文档的默认流转关系为：`architectures -> plans -> tasks`
- `plans` 与 `tasks` 产生的长期有效结论，应及时回写到 `docs/architectures`
- 文件名优先使用稳定英文 slug，不使用按年月日追加的文件名前缀
- 路线变更后直接覆盖、重写或删除旧 plan，不为过期方案保留兼容性文书
- 任务完成且无复用价值后直接删除；长期有效结论及时回写到 `docs/architectures`
