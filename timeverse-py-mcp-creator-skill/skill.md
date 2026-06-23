# Python MCP Server 项目脚手架

## 描述

当用户要求创建/搭建/初始化 Python MCP Server 项目时，自动生成完整的项目骨架，包含最佳实践的项目结构、构建配置、CI/CD、测试和文档模板。

---

## 工作流程

### 1. 确认用户需求

- 充分理解 MCP Server 的功能/用途（做什么）
- **如果用户描述不清晰或存在歧义，必须主动追问，直到需求明确后再实施**，不要猜测或假设
- 项目名称（如 `my-mcp-server`）
- Python 包名（如 `my_mcp_server`）
- 对外暴露的工具名称和功能描述
- 是否需要特定的外部依赖（如 `httpx`, `aiofiles` 等）

### 2. 创建项目目录结构

```
<project-name>/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI 工作流：ruff + mypy + pytest × 3 OS × 3 Python(3.10-3.12)
│       └── release.yml         # 发布工作流：推 tag 自动发布 PyPI (OIDC)
├── docs/
│   ├── USAGE.md
│   ├── claude_desktop_config.example.json
│   └── claude_desktop_config.uvx.example.json
├── src/
│   └── <package_name>/
│       ├── __init__.py
│       ├── server.py           # MCP Server 入口
│       └── executor.py         # 业务逻辑实现 (可选)
├── tests/
│   ├── __init__.py
│   ├── test_server.py
│   └── test_executor.py
├── .gitignore
├── .python-version             # 3.12
├── CHANGELOG.md
├── LICENSE                     # MIT
├── pyproject.toml
└── README.md
```

### 3. 编写核心文件

#### pyproject.toml

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "<project-name>"
version = "0.1.0"
description = "<description>"
readme = "README.md"
license = { text = "MIT" }
authors = [
    { name = "<author>" },
]
keywords = [
    "mcp",
    "model-context-protocol",
    "<your-keywords>",
]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Topic :: Software Development :: Libraries :: Python Modules",
    "Operating System :: MacOS",
    "Operating System :: Microsoft :: Windows",
    "Operating System :: POSIX :: Linux",
]
requires-python = ">=3.10"
dependencies = [
    "mcp>=1.0.0",
    # <其他运行时依赖>
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-asyncio>=0.21",
    "ruff>=0.1.0",
    "mypy>=1.0",
]

[project.scripts]
<project-name> = "<package_name>.server:main"

[project.urls]
Homepage = "https://github.com/<owner>/<project-name>"
Issues = "https://github.com/<owner>/<project-name>/issues"

[tool.hatch.build.targets.wheel]
packages = ["src/<package_name>"]

[tool.hatch.build.targets.sdist]
include = [
    "src/<package_name>",
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
]

[tool.ruff]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "UP", "B", "C4", "SIM"]

[tool.mypy]
python_version = "3.10"
strict = true
warn_return_any = true
warn_unused_configs = true
ignore_missing_imports = true

[[tool.mypy.overrides]]
module = ["tests.*"]
disallow_untyped_defs = false
disable_error_code = ["untyped-decorator", "no-untyped-def"]

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
pythonpath = ["src"]
```

#### src/\<package_name\>/server.py

```python
"""MCP Server for <功能描述>."""

from __future__ import annotations

import asyncio
import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from dataclasses import dataclass
from typing import Any

from mcp.server import Server, stdio_server
from mcp.types import TextContent, Tool

logger = logging.getLogger("<package_name>")


# ==================== 业务逻辑模块 ====================

@dataclass
class Session:
    """请求会话，包含状态管理。"""
    tool_call_id: str
    # <添加自定义字段>


# ==================== MCP Server ====================

async def _run() -> None:
    """启动 MCP Server。"""
    server = Server("<server-name>")

    # --- 列出所有工具 ---
    @server.list_tools()  # type: ignore[untyped-decorator]
    async def list_tools() -> list[Tool]:
        return [
            Tool(
                name="<tool1>",
                description="<tool1 功能描述>",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "<param1>": {
                            "type": "string",
                            "description": "<参数描述>",
                        },
                        "<param2>": {
                            "type": "string",
                            "description": "<参数描述>",
                        },
                    },
                    "required": ["<param1>"],
                },
            ),
            # <更多工具>
        ]

    # --- 处理工具调用 ---
    @server.call_tool()  # type: ignore[untyped-decorator]
    async def call_tool(
        name: str,
        arguments: dict[str, Any],
    ) -> list[TextContent]:
        try:
            result = await _run_and_collect(name, arguments)
            return [TextContent(type="text", text=result)]
        except Exception as e:
            logger.exception("Error handling tool call")
            return [TextContent(
                type="text",
                text=f"Error: {e!s}",
            )]

    # --- 启动 stdio 传输 ---
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


async def _run_and_collect(
    name: str,
    arguments: dict[str, Any],
) -> str:
    """执行工具并收集结果。"""
    # <业务逻辑>
    import json
    return json.dumps({"result": "ok"})


def main() -> None:
    """CLI 入口点。"""
    logging.basicConfig(level=logging.WARNING, stream=__import__("sys").stderr)
    asyncio.run(_run())


if __name__ == "__main__":
    main()
```

#### src/\<package_name\>/__init__.py

```python
"""<package_name> - <一行描述>."""
```

#### tests/test_server.py

参考以下模式编写测试：

```python
"""测试 MCP Server。"""

from __future__ import annotations

import json
import pytest
from unittest.mock import AsyncMock, patch

from <package_name>.server import <要测试的函数>


class TestListTools:
    """测试工具列表注册。"""

    def test_tools_registered(self) -> None:
        """验证注册了正确数量的工具。"""
        # <测试逻辑>


class TestCallTool:
    """测试工具调用。"""

    @pytest.mark.asyncio
    async def test_basic_call(self) -> None:
        """测试基础调用。"""
        # <测试逻辑>
```

#### .gitignore

```
# Python
__pycache__/
*.py[cod]
*.egg-info/
dist/
build/
.eggs/
*.egg
.venv/
venv/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local
```

#### .python-version

```
3.12
```

#### LICENSE (MIT)

```text
MIT License

Copyright (c) 2026 <Author>

Permission is hereby granted...
```

#### .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    name: Lint and type check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install dev deps
        run: pip install -e ".[dev]"
      - name: Ruff check
        run: ruff check src/ tests/
      - name: Ruff format check
        run: ruff format --check src/ tests/
      - name: MyPy
        run: mypy src/

  test:
    name: Test ${{ matrix.os }} / Python ${{ matrix.python-version }}
    needs: lint
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python-version: ['3.10', '3.11', '3.12']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - name: Install dev deps
        run: pip install -e ".[dev]"
      - name: Test with pytest
        run: pytest -v --tb=short
```

#### .github/workflows/release.yml

```yaml
name: Release

on:
  push:
    tags: ['v*']
  workflow_dispatch:

jobs:
  publish:
    name: Build and publish to PyPI
    runs-on: ubuntu-latest
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install build
        run: python -m pip install --upgrade build
      - name: Build sdist and wheel
        run: python -m build
      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
```

#### README.md

```markdown
# <Project Name>

[![PyPI](https://img.shields.io/pypi/v/<project-name>)](https://pypi.org/project/<project-name>/)
[![Python](https://img.shields.io/pypi/pyversions/<project-name>)](https://pypi.org/project/<project-name>/)
[![CI](https://github.com/<owner>/<project-name>/actions/workflows/ci.yml/badge.svg)](https://github.com/<owner>/<project-name>/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<一行描述>

## Tools

| 工具 | 描述 |
|------|------|
| `<tool1>` | <功能> |

## Installation

```bash
pip install <project-name>
```

Or from source:
```bash
git clone https://github.com/<owner>/<project-name>.git
cd <project-name>
pip install -e ".[dev]"
```

## Claude Desktop Config

```json
{
  "mcpServers": {
    "<server-name>": {
      "command": "uvx",
      "args": ["<project-name>"]
    }
  }
}
```

## Development

```bash
pip install -e ".[dev]"
ruff check src/ tests/
ruff format src/ tests/
mypy src/
pytest -v
```

## License

MIT
```

#### docs/claude_desktop_config.example.json

```json
{
  "mcpServers": {
    "<server-name>": {
      "command": "<project-name>",
      "args": [],
      "env": {}
    }
  }
}
```

#### docs/claude_desktop_config.uvx.example.json

```json
{
  "mcpServers": {
    "<server-name>": {
      "command": "uvx",
      "args": ["<project-name>"]
    }
  }
}
```

#### CHANGELOG.md

```markdown
# Changelog

## [0.1.0] - <date>

### Added
- 初始发布
- 基础 MCP Server 功能：<tools>
```

### 4. 验证

- `ruff check src/ tests/` 无错误
- `ruff format --check src/ tests/` 无错误
- `mypy src/` 无错误
- `pytest -v --tb=short` 全部通过

### 5. 初始化 Git 仓库并推送

```bash
cd <project-name>
git init
git add .
git commit -m "chore: init <project-name>"
git remote add origin https://github.com/<owner>/<project-name>.git
git push -u origin main
```

### 6. 发布到 PyPI

#### 前置条件

1. **注册 PyPI 账号**：[pypi.org](https://pypi.org/register)
2. **开启 2FA**：Account Settings → Two-factor authentication（推荐 TOTP）
3. **配置受信任发布者（推荐）**：Account Settings → Publishing
4. **备选方式：API Token**

#### 发布流程

**方式 A：GitHub Actions 自动发布（推荐）**

```bash
# 1. 更新 pyproject.toml 中的 version
# 2. 更新 CHANGELOG.md
# 3. 提交并推送
git add pyproject.toml CHANGELOG.md
git commit -m "chore: bump version to 0.2.0"
git push origin main

# 4. 创建并推送 tag（触发 release.yml）
git tag v0.2.0
git push origin v0.2.0
```

**方式 B：手动发布**

```bash
pip install build twine
python -m build
python -m twine upload dist/*
```

---

## 设计原则

- **最小依赖**：运行时只依赖 `mcp>=1.0.0`，其他按需添加
- **类型安全**：mypy strict mode，全部使用现代类型注解
- **跨平台兼容**：CI 覆盖 macOS / Ubuntu / Windows × Python 3.10-3.12
- **流式输出**：使用异步生成器实时返回结果，支持超时和取消
- **Hatchling 构建**：现代 Python 打包标准
