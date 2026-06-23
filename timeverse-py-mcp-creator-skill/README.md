# Python MCP Server 项目脚手架 - 通用技能包

自动创建完整的 **Python MCP Server** 项目骨架，包含最佳实践的项目结构、构建配置、CI/CD、测试和文档模板。

## 目录结构

```
timeverse-py-mcp-creator-skill/
├── skill.md                          # 通用技能核心内容（平台无关）
├── adapters/
│   ├── trae/
│   │   └── SKILL.md                 # Trae IDE 格式
│   ├── cursor/
│   │   └── .cursorrules             # Cursor 格式
│   ├── windsurf/
│   │   └── .windsurfrules           # Windsurf 格式
│   ├── cline/
│   │   └── .clinerules              # Cline / Roo Code 格式
│   └── github-copilot/
│       └── copilot-instructions.md  # GitHub Copilot 格式
├── install.sh                       # 一键安装脚本
└── README.md                        # 本文件
```

## 安装方法

### Trae IDE

```bash
# 将 adapters/trae/ 下的内容复制到项目 .trae/skills/ 目录
cp -r adapters/trae /path/to/your/project/.trae/skills/timeverse-py-mcp-creator
```

### Cursor

```bash
# 将 adapters/cursor/.cursorrules 复制到项目根目录
cp adapters/cursor/.cursorrules /path/to/your/project/.cursorrules
```

### Windsurf

```bash
# 将 adapters/windsurf/.windsurfrules 复制到项目根目录
cp adapters/windsurf/.windsurfrules /path/to/your/project/.windsurfrules
```

### Cline / Roo Code (VS Code)

```bash
# 将 adapters/cline/.clinerules 复制到项目根目录
cp adapters/cline/.clinerules /path/to/your/project/.clinerules
```

### GitHub Copilot

```bash
# 将 adapters/github-copilot/copilot-instructions.md 放到项目 .github/ 目录
cp adapters/github-copilot/copilot-instructions.md /path/to/your/project/.github/copilot-instructions.md
```

### 一键安装

```bash
# 在项目根目录运行
chmod +x install.sh && ./install.sh
```

## 使用方式

安装后在对应 AI 客户端中提出以下需求即可自动生成项目：

- "帮我创建一个 Python MCP Server"
- "搭建一个 MCP 项目，功能是 xxx"
- "初始化一个 Python MCP Server 脚手架"
