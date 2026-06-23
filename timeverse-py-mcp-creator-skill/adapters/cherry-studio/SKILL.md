---
name: timeverse-py-mcp-creator
description: 自动搭建 Python MCP Server 项目骨架。包含最佳实践的项目结构、构建配置、CI/CD、测试和文档模板。当用户要求创建/搭建/初始化 Python MCP 项目时自动触发。
---

<!--
  Cherry Studio 适配版本。
  核心内容维护在 ../../skill.md，此文件适配 Cherry Studio 的 SKILL.md 格式。
-->

# Python MCP Server 项目脚手架

自动创建完整的 **Python** MCP Server 项目骨架。

## 工作流程

### 1. 确认用户需求
- 充分理解 MCP Server 的功能/用途
- **如果用户描述不清晰，必须主动追问，直到需求明确**
- 确认：项目名称、Python 包名、工具名称和功能、额外依赖

### 2. 创建项目结构

参见 [skill.md](../../skill.md) 中的完整模板。

### 3. 编写核心文件

参见 [skill.md](../../skill.md) 中的完整代码模板。

### 4. 验证
- `ruff check src/ tests/`
- `ruff format --check src/ tests/`
- `mypy src/`
- `pytest -v --tb=short`

### 5. 发布到 PyPI
参见 [skill.md](../../skill.md) 中的完整发布流程。

## 设计原则
- **最小依赖**：运行时只依赖 `mcp>=1.0.0`
- **类型安全**：mypy strict mode
- **跨平台**：CI 覆盖 macOS/Ubuntu/Windows × Python 3.10-3.12
- **Hatchling 构建**
