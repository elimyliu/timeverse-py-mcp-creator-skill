---
name: python-mcp-creator-skill
description: "自动搭建 Python MCP Server 项目骨架。包含最佳实践的项目结构、构建配置、CI/CD、测试和文档模板。当用户要求创建/搭建/初始化 Python MCP 项目时立即调用。"
version: 1.0.0
author: TimeVerse
tags:
  - python
  - mcp
  - scaffolding
  - boilerplate
---

# Python MCP Server 项目脚手架

## 描述

当用户要求创建/搭建/初始化 Python MCP Server 项目时，自动生成完整的项目骨架，包含最佳实践的项目结构、构建配置、CI/CD、测试和文档模板。

---

## 工作流程

### 1. 确认用户需求

充分理解 MCP Server 的功能/用途，**如果用户描述不清晰或存在歧义，必须主动追问，直到需求明确后再实施**，不要猜测或假设。

首先确认传输方式（**需要用户选择**）：
- **stdio**（默认）：通过标准输入输出与客户端通信，适合本地/嵌入使用
- **http**：通过 Streamable HTTP 远程调用，适合跨网络或独立部署场景

根据以下三种场景区分处理：

#### 场景 A：有三方 API 文档链接

用户提供了外部 API 的文档链接（如 OpenAPI/Swagger、REST API 文档等）。

- 先读取/抓取 API 文档，理解接口定义（请求方法、参数、响应格式、认证方式）
- 根据 API 接口设计对应的 MCP 工具（一个接口或一类接口封装为一个工具）
- 项目名称、Python 包名、工具名称由用户确认
- 依赖：自动添加 `httpx`（推荐 HTTP 客户端）

#### 场景 B：无三方 API 文档但 MCP 需要对接三方服务

用户知道要对接某个三方服务，但没有提供 API 文档。

- **必须追问**：要求用户提供 API 文档链接、接口说明，或至少给出服务名称让用户自行查找文档
- 如果用户也无法提供文档，建议用户先获取文档后再继续
- 在用户提供文档后，按场景 A 处理

#### 场景 C：无需对接三方服务

MCP Server 仅提供本地功能（如文件处理、代码分析、命令行工具封装等），不调用外部 API。

- 明确工具的功能边界和输入/输出
- 不需要 `httpx` 等 HTTP 依赖
- 项目名称、Python 包名、工具名称由用户确认

### 2. 创建项目目录结构

```
<project-name>/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI 工作流：ruff + mypy + pytest × 3 OS × 3 Python(3.10-3.12)
│       └── release.yml         # 发布工作流：推 tag 自动发布 PyPI (OIDC)
├── src/
│   └── <package_name>/
│       ├── __init__.py
│       └── server.py           # MCP Server 入口
│       # 复杂场景可另建 executor.py 拆分业务逻辑
├── tests/
│   ├── __init__.py
│   └── test_server.py
│   # 如有 executor.py，对应添加 test_executor.py
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
http = [
    "starlette>=0.40.0",
    "uvicorn>=0.30.0",
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

import argparse
import asyncio
import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Any

from mcp.server import Server
from mcp.types import TextContent, Tool

logger = logging.getLogger("<package_name>")


# ==================== MCP Server ====================

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
        results = []
        async for chunk in _run_and_collect(name, arguments):
            results.append(TextContent(type="text", text=chunk))
        return results
    except Exception as e:
        logger.exception("Error handling tool call")
        return [TextContent(
            type="text",
            text=f"Error: {e!s}",
        )]


async def _run_and_collect(
    name: str,
    arguments: dict[str, Any],
) -> AsyncIterator[str]:
    """执行工具并流式返回结果。

    支持逐步 yield 结果，客户端可实时收到中间进度信息，
    无需等待全部处理完成。
    """
    # 模拟分步处理
    for i in range(3):
        await asyncio.sleep(0.1)  # 替换为真实异步 I/O
        yield f"[step {i + 1}/3] 处理中...\n"
    yield "处理完成"


# ==================== 场景 A：Web API 调用模式 ====================
# 当需要对接外部 REST API 时，参考以下模式：

# @asynccontextmanager
# async def api_client() -> AsyncIterator[httpx.AsyncClient]:
#     """带超时和重试的 HTTP 客户端。"""
#     async with httpx.AsyncClient(
#         base_url="https://api.example.com",
#         timeout=httpx.Timeout(30.0),
#     ) as client:
#         yield client
#
#
# async def _run_and_collect(
#     name: str,
#     arguments: dict[str, Any],
# ) -> AsyncIterator[str]:
#     params = {"q": arguments.get("query", "")}
#     async with api_client() as client:
#         response = await client.get("/search", params=params)
#         response.raise_for_status()
#         data = response.json()
#         for item in data.get("results", []):
#             yield json.dumps(item, ensure_ascii=False)


# ==================== 传输层 ====================

async def _run_stdio() -> None:
    """通过 stdio 传输启动（默认）。"""
    from mcp.server import stdio_server
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream, write_stream,
            server.create_initialization_options(),
        )


async def _run_http(host: str = "0.0.0.0", port: int = 8000, reload: bool = False) -> None:
    """通过 Streamable HTTP 传输启动。"""
    from mcp.server.sse import SseServerTransport
    from starlette.applications import Starlette
    from starlette.routing import Route
    import uvicorn

    sse = SseServerTransport("/messages/")

    async def handle_sse(request):
        async with sse.connect_sse(
            request.scope, request.receive, request._send,
        ) as (read_stream, write_stream):
            await server.run(
                read_stream, write_stream,
                server.create_initialization_options(),
            )

    async def handle_messages(request):
        await sse.handle_post_message(
            request.scope, request.receive, request._send,
        )

    app = Starlette(routes=[
        Route("/sse", endpoint=handle_sse),
        Route("/messages/", endpoint=handle_messages, methods=["POST"]),
    ])

    logger.info("MCP Server listening on %s:%s", host, port)
    uvicorn.run(app, host=host, port=port, log_level="info", reload=reload)


def main() -> None:
    """CLI 入口点。

    支持两种传输方式：
    - stdio（默认）：通过标准输入输出通信，适合本地/嵌入使用
    - http：通过 Streamable HTTP 远程调用，适合跨网络部署
    """
    parser = argparse.ArgumentParser(description="<package_name> MCP Server")
    parser.add_argument(
        "--transport",
        choices=["stdio", "http"],
        default="stdio",
        help="传输方式：stdio（默认，本地 stdio）或 http（Streamable HTTP）",
    )
    parser.add_argument("--host", default="0.0.0.0", help="HTTP 监听地址（仅 http 模式）")
    parser.add_argument("--port", type=int, default=8000, help="HTTP 监听端口（仅 http 模式）")
    parser.add_argument("--dev", action="store_true", help="开发模式（启用热重载，仅 http 模式）")
    args = parser.parse_args()

    logging.basicConfig(level=logging.WARNING, stream=__import__("sys").stderr)

    if args.transport == "http":
        asyncio.run(_run_http(host=args.host, port=args.port, reload=args.dev))
    else:
        asyncio.run(_run_stdio())


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

## 安装

```bash
pip install <project-name>
```

或从源码安装：
```bash
git clone https://github.com/<owner>/<project-name>.git
cd <project-name>
pip install -e ".[dev]"
```

## 使用

### 作为 CLI 工具

```bash
<project-name>
```

### 传输方式

支持两种传输模式，通过 `--transport` 参数选择：

#### stdio 模式（默认）

通过标准输入输出与客户端通信，适合本地/嵌入使用：

```bash
# 直接运行
<project-name>

# 或显式指定
<project-name> --transport stdio
```

#### HTTP 模式

通过 Streamable HTTP 远程调用，适合跨网络或独立部署：

```bash
# 需要先安装 HTTP 依赖
pip install "<project-name>[http]"

# 启动 HTTP 服务
<project-name> --transport http --host 0.0.0.0 --port 8000

# 开发模式（启用热重载，代码变更自动重启）
<project-name> --transport http --host 0.0.0.0 --port 8000 --dev
```

启动后客户端通过 SSE 端点连接：
- SSE 端点：`http://<host>:<port>/sse`
- 消息端点：`http://<host>:<port>/messages/`

### 与 TimeVerse Studio 集成

在 TimeVerse Studio 的 MCP Server 配置中添加：

```json
{
  "mcpServers": {
    "<server-name>": {
      "command": "<project-name>",
      "args": []
    }
  }
}
```

如果使用 `uvx`（无需安装，直接运行）：

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

### 其他 MCP 客户端集成

所有支持 MCP 协议的客户端（Claude Desktop、Cursor、Windsurf、Trae 等）配置方式一致，只需在客户端的 MCP Server 配置中添加：

```json
{
  "mcpServers": {
    "<server-name>": {
      "command": "<project-name>",
      "args": []
    }
  }
}
```

如果使用 `uvx`（无需安装，直接运行）：

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

不同客户端的配置文件位置请参考其官方文档。需要 HTTP 模式时添加 `--transport http` 参数。

## 开发

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
