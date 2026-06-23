#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="timeverse-py-mcp-creator"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Python MCP Server 脚手架 - 技能安装脚本"
echo "=========================================="
echo ""

# 检测当前目录下是否已有 .trae 或 .cursorrules 等，判断项目类型
detect_project_type() {
    if [ -d ".trae/skills" ]; then
        echo "1"
    elif [ -f ".cursorrules" ]; then
        echo "2"
    elif [ -f ".windsurfrules" ]; then
        echo "3"
    elif [ -f ".clinerules" ]; then
        echo "4"
    elif [ -d ".github" ]; then
        echo "5"
    else
        echo "0"
    fi
}

install_trae() {
    local target="${1:-.trae/skills/$SKILL_NAME}"
    mkdir -p "$(dirname "$target")"
    cp -r "$SCRIPT_DIR/adapters/trae/" "$target"
    echo "  ✓ 已安装到 Trae: $target"
}

install_cursor() {
    local target="${1:-.cursorrules}"
    cp "$SCRIPT_DIR/adapters/cursor/.cursorrules" "$target"
    echo "  ✓ 已安装到 Cursor: $target"
}

install_windsurf() {
    local target="${1:-.windsurfrules}"
    cp "$SCRIPT_DIR/adapters/windsurf/.windsurfrules" "$target"
    echo "  ✓ 已安装到 Windsurf: $target"
}

install_cline() {
    local target="${1:-.clinerules}"
    cp "$SCRIPT_DIR/adapters/cline/.clinerules" "$target"
    echo "  ✓ 已安装到 Cline/Roo Code: $target"
}

install_github_copilot() {
    local target="${1:-.github/copilot-instructions.md}"
    mkdir -p "$(dirname "$target")"
    cp "$SCRIPT_DIR/adapters/github-copilot/copilot-instructions.md" "$target"
    echo "  ✓ 已安装到 GitHub Copilot: $target"
}

install_all() {
    echo "  → 安装到所有支持的平台..."
    echo ""
    install_trae
    install_cursor
    install_windsurf
    install_cline
    install_github_copilot
    echo ""
    echo "  ✓ 全部安装完成！"
}

# --- 主逻辑 ---

# 如果没有参数，尝试检测项目类型
if [ $# -eq 0 ]; then
    detected=$(detect_project_type)
    case "$detected" in
        1) install_trae ;;
        2) install_cursor ;;
        3) install_windsurf ;;
        4) install_cline ;;
        5) install_github_copilot ;;
        *)
            echo "未检测到已知的 AI 客户端配置文件。"
            echo "请指定要安装的目标平台："
            echo ""
            echo "  ./install.sh trae          # 安装到 Trae IDE"
            echo "  ./install.sh cursor        # 安装到 Cursor"
            echo "  ./install.sh windsurf      # 安装到 Windsurf"
            echo "  ./install.sh cline         # 安装到 Cline / Roo Code"
            echo "  ./install.sh copilot       # 安装到 GitHub Copilot"
            echo "  ./install.sh all           # 安装到所有平台"
            echo ""
            echo "也可以指定目标路径："
            echo "  ./install.sh trae /custom/path"
            echo ""
            exit 0
            ;;
    esac
else
    case "$1" in
        trae)     install_trae "${2:-.trae/skills/$SKILL_NAME}" ;;
        cursor)   install_cursor "${2:-.cursorrules}" ;;
        windsurf) install_windsurf "${2:-.windsurfrules}" ;;
        cline)    install_cline "${2:-.clinerules}" ;;
        copilot)  install_github_copilot "${2:-.github/copilot-instructions.md}" ;;
        all)      install_all ;;
        *)
            echo "错误：未知的平台 '$1'"
            echo "可用选项：trae, cursor, windsurf, cline, copilot, all"
            exit 1
            ;;
    esac
fi
