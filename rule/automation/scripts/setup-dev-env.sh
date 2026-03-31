#!/bin/bash
# =============================================================================
# 开发环境一键安装脚本
# 用途：clone 后执行此脚本，自动安装 pre-commit hooks
# 使用：bash scripts/setup-dev-env.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "============================================"
echo "  开发环境安装工具"
echo "  项目: ${PROJECT_ROOT}"
echo "============================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# =============================================================================
# 1. 安装 Git pre-commit hook（后端）
# =============================================================================
install_backend_hook() {
    local hook_dir="${PROJECT_ROOT}/.git/hooks"
    local hook_file="${hook_dir}/pre-commit"

    if [ ! -d "$hook_dir" ]; then
        mkdir -p "$hook_dir"
    fi

    if [ -f "$hook_file" ]; then
        echo -e "${YELLOW}[SKIP]${NC} pre-commit hook 已存在: ${hook_file}"
        return
    fi

    cat > "$hook_file" << 'HOOK_EOF'
#!/bin/bash
# Pre-commit hook — 后端规范快速检查
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# 后端规范检查（仅检查暂存区的 Java 文件）
STAGED_JAVA=$(git diff --cached --name-only --diff-filter=ACM | grep '\.java$' || true)
if [ -n "$STAGED_JAVA" ]; then
    echo "[pre-commit] 检查后端规范..."
    bash "${SCRIPT_DIR}/rule/automation/scripts/check-backend-rules.sh" "$SCRIPT_DIR" || {
        echo "[pre-commit] 后端规范检查失败，请修复后重新提交。"
        exit 1
    }
fi

# 前端规范检查（仅检查暂存区的 Vue/TS 文件）
STAGED_FRONTEND=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(vue|ts|js)$' | grep '^frontend/' || true)
if [ -n "$STAGED_FRONTEND" ]; then
    echo "[pre-commit] 检查前端规范..."
    bash "${SCRIPT_DIR}/rule/automation/scripts/check-frontend-rules.sh" "${SCRIPT_DIR}/frontend" || {
        echo "[pre-commit] 前端规范检查失败，请修复后重新提交。"
        exit 1
    }
fi

echo "[pre-commit] 所有检查通过。"
HOOK_EOF

    chmod +x "$hook_file"
    echo -e "${GREEN}[OK]${NC} 后端 pre-commit hook 安装成功"
}

# =============================================================================
# 2. 安装前端 husky（如果 frontend 目录存在）
# =============================================================================
install_frontend_hooks() {
    local frontend_dir="${PROJECT_ROOT}/frontend"

    if [ ! -d "$frontend_dir" ]; then
        echo -e "${YELLOW}[SKIP]${NC} frontend/ 目录不存在，跳过 husky 安装"
        return
    fi

    if [ ! -f "$frontend_dir/package.json" ]; then
        echo -e "${YELLOW}[SKIP]${NC} frontend/package.json 不存在，跳过 husky 安装"
        return
    fi

    # 检查 husky 是否已在 package.json 的 devDependencies 中
    if grep -q '"husky"' "$frontend_dir/package.json" 2>/dev/null; then
        echo -e "${YELLOW}[SKIP]${NC} husky 已在 package.json 中配置"
    else
        echo -e "${YELLOW}[INFO]${NC} 建议在 frontend/ 中安装 husky + lint-staged："
        echo "  cd frontend && npm install -D husky lint-staged"
        echo "  npx husky init"
    fi
}

# =============================================================================
# 3. 验证规则检查脚本可用性
# =============================================================================
verify_scripts() {
    local scripts_dir="${PROJECT_ROOT}/rule/automation/scripts"

    echo ""
    echo "验证规则检查脚本..."

    if [ ! -d "$scripts_dir" ]; then
        echo -e "  ${RED}[MISSING]${NC} rule/automation/scripts/ 目录不存在"
        return
    fi

    for script in check-backend-rules.sh check-frontend-rules.sh check-middleware-rules.sh check-security-rules.sh; do
        if [ -f "${scripts_dir}/${script}" ]; then
            echo -e "  ${GREEN}[OK]${NC} ${script}"
        else
            echo -e "  ${RED}[MISSING]${NC} ${script}"
        fi
    done
}

# =============================================================================
# 执行安装
# =============================================================================
install_backend_hook
install_frontend_hooks
verify_scripts

echo ""
echo "============================================"
echo -e "  ${GREEN}开发环境安装完成${NC}"
echo ""
echo "  后续步骤："
echo "  1. 阅读 rule/README.md 了解规范体系"
echo "  2. 阅读 rule/快速参考-后端.md / 快速参考-前端.md"
echo "  3. 提交代码时 pre-commit hook 会自动检查规范合规"
echo "============================================"
