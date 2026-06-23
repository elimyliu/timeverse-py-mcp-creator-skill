---
name: "timeverse-py-mcp-creator"
description: "自动搭建 Python MCP Server 项目骨架。包含最佳实践的项目结构、构建配置、CI/CD、测试和文档模板。当用户要求创建/搭建/初始化 Python MCP 项目时立即调用。"
---

<!--
  此文件是 Trae IDE 专用格式。
  核心内容维护在 ../../skill.md，此文件为 Trae 适配版本。
-->

# Python MCP Server 项目脚手架

根据最佳实践，自动创建完整的 **Python** MCP Server 项目骨架。

## 工作流程

1. **确认用户需求**
   - 充分理解 MCP Server 的功能/用途（做什么）
   - **如果用户描述不清晰或存在歧义，必须主动追问，直到需求明确后再实施**，不要猜测或假设
   - 项目名称（如 `my-mcp-server`）
   - Python 包名（如 `my_mcp_server`）
   - 对外暴露的工具名称和功能描述
   - 是否需要特定的外部依赖（如 `httpx`, `aiofiles` 等）

2. **创建项目目录结构**

参见 [skill.md](../../skill.md) 中的完整模板定义。

3. **编写 core 文件**

参见 [skill.md](../../skill.md) 中的完整代码模板。

4. **验证**

- `ruff check src/ tests/` 无错误
- `ruff format --check src/ tests/` 无错误
- `mypy src/` 无错误
- `pytest -v --tb=short` 全部通过

5. **初始化 Git 仓库并推送**

```bash
cd <project-name>
git init
git add .
git commit -m "chore: init <project-name>"
git remote add origin https://github.com/<owner>/<project-name>.git
git push -u origin main
```

6. **发布到 PyPI**

参见 [skill.md](../../skill.md) 中的完整发布流程。

## 设计原则

- **最小依赖**：运行时只依赖 `mcp>=1.0.0`，其他按需添加
- **类型安全**：mypy strict mode，全部使用现代类型注解（`X | None`、`list[X]` 替代 `Optional`、`List`）
- **跨平台兼容**：CI 覆盖 macOS / Ubuntu / Windows × Python 3.10-3.12
- **流式输出**：使用异步生成器实时返回结果，支持超时和取消
- **Hatchling 构建**：现代 Python 打包标准
