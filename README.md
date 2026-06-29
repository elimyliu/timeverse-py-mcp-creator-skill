# Python MCP Server 项目脚手架 — 通用技能包

自动搭建 **Python MCP Server** 项目骨架。包含最佳实践的项目结构、构建配置、CI/CD、测试和文档模板。

## 文件结构

```
.
├── skill.md       # 核心技能定义
├── README.md      # 本文件
└── .gitignore
```

## 安装方式

### TimeVerse Studio

1. 打开 TimeVerse Studio
2. 进入 **设置 → 技能 → 添加技能包**
3. 选择本仓库的 `skill.md` 文件
4. 保存后即可在对话中使用

### Trae IDE

将本项目添加为技能后，提出以下需求即可自动生成项目。

## 使用方式

### 从零创建

- "帮我创建一个 Python MCP Server"
- "搭建一个 MCP 项目，功能是 xxx"
- "初始化一个 Python MCP Server 脚手架"

### 基于第三方 API 文档生成

提供第三方 API 文档，自动生成对应的 MCP Server：

- "根据这个 API 文档帮我创建一个 MCP Server：[文档链接]"
- "基于 xxx 的 API 文档生成一个 MCP Server"
- "把这个 OpenAPI 规范转成一个 MCP Server 项目"

支持的文档格式：

- OpenAPI / Swagger 文档（JSON/YAML）
- API 文档链接或 Markdown 文档
- cURL 示例或接口描述文本
