# GitHub Copilot Instructions - Python MCP Server 项目脚手架

## 触发关键词
当用户输入包含以下关键词时，主动提供 Python MCP Server 项目生成：
- "create mcp server"
- "new mcp project"
- "python mcp"
- "mcp server scaffold"
- "initialize mcp"

## 生成规则

### 项目结构
生成标准 Python 包结构，使用 hatchling 构建系统，src 布局。

### 依赖
- 运行时: mcp>=1.0.0
- 开发: pytest, pytest-asyncio, ruff, mypy

### 代码风格
- Python 3.10+ 类型注解（使用 `X | None` 而非 `Optional[X]`）
- async/await 异步模式
- 所有函数必须有类型注解
- mypy strict mode 兼容

### 测试
使用 pytest + pytest-asyncio，覆盖主要工具调用路径。

### CI/CD
生成 GitHub Actions 配置：
- CI: ruff + mypy + pytest on 3 OS × 3 Python
- Release: 推 tag 自动发布到 PyPI (trusted publisher)

## 参考
完整的代码模板请参考 `skill.md`。
