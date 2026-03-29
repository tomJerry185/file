#!/bin/bash
# =============================================================================
# 前端规范合规检查脚本
# 对齐文件：rule/前端规范.txt
# 用途：CI/CD 集成或本地 pre-commit 检查
# 使用：bash rule/automation/scripts/check-frontend-rules.sh [前端目录]
# =============================================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0;m'

# 前端目录
FRONTEND_DIR="${1:-$(cd "$(dirname "$0")/../../../frontend" && pwd)}"

# 计数器
TOTAL_CHECKS=0
PASSED=0
FAILED=0
WARNINGS=0
RESULTS=""

# =============================================================================
# 工具函数
# =============================================================================
check_name=""
check_desc=""

begin_check() {
    check_name="$1"
    check_desc="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

pass() {
    PASSED=$((PASSED + 1))
    RESULTS="${RESULTS}\n${GREEN}[PASS]${NC} ${check_name}: ${check_desc}"
}

fail() {
    local msg="$1"
    FAILED=$((FAILED + 1))
    RESULTS="${RESULTS}\n${RED}[FAIL]${NC} ${check_name}: ${msg}"
}

warn() {
    local msg="$1"
    WARNINGS=$((WARNINGS + 1))
    RESULTS="${RESULTS}\n${YELLOW}[WARN]${NC} ${check_name}: ${msg}"
}

# =============================================================================
# 检查 1: Vue 组件 script setup 使用率
# 前端规范 3.1.01 — 新组件必须使用 <script setup lang="ts">
# =============================================================================
check_script_setup() {
    begin_check "script setup 使用率" "前端规范 3.1.01 Composition API 优先"

    local total=0
    local setup_count=0

    if [ -d "$FRONTEND_DIR/src" ]; then
        total=$(find "$FRONTEND_DIR/src" -name "*.vue" -type f 2>/dev/null | wc -l || echo "0")
        setup_count=$(grep -rl "<script setup" "$FRONTEND_DIR/src" --include="*.vue" 2>/dev/null | wc -l || echo "0")
    fi

    if [ "$total" -eq 0 ]; then
        warn "未找到 .vue 文件，跳过检查"
        return
    fi

    local rate=$((setup_count * 100 / total))
    if [ "$rate" -ge 80 ]; then
        pass
    elif [ "$rate" -ge 50 ]; then
        warn "script setup 使用率 ${rate}%（${setup_count}/${total}），目标 >= 80%"
    else
        fail "script setup 使用率仅 ${rate}%（${setup_count}/${total}），目标 >= 80%"
    fi
}

# =============================================================================
# 检查 2: TypeScript 使用率
# 前端规范 2.1 — 禁止使用 any
# =============================================================================
check_typescript_usage() {
    begin_check "TypeScript使用率" "前端规范 2.1 TypeScript严格模式"

    local total=0
    local ts_count=0

    if [ -d "$FRONTEND_DIR/src" ]; then
        total=$(find "$FRONTEND_DIR/src" -name "*.vue" -type f 2>/dev/null | wc -l || echo "0")
        ts_count=$(grep -rl "lang=\"ts\"" "$FRONTEND_DIR/src" --include="*.vue" 2>/dev/null | wc -l || echo "0")
    fi

    if [ "$total" -eq 0 ]; then
        warn "未找到 .vue 文件，跳过检查"
        return
    fi

    local rate=$((ts_count * 100 / total))
    if [ "$rate" -ge 80 ]; then
        pass
    else
        warn "TypeScript 使用率 ${rate}%（${ts_count}/${total}），目标 >= 80%"
    fi
}

# =============================================================================
# 检查 3: console.log 残留
# 前端规范 9.3.02 — 生产环境禁止 console.log
# =============================================================================
check_console_log() {
    begin_check "console.log残留" "前端规范 9.3.02 禁止生产环境console"

    local count=0
    local details=""

    if [ -d "$FRONTEND_DIR/src" ]; then
        count=$(grep -rn "console\.\(log\|warn\|debug\)" "$FRONTEND_DIR/src" --include="*.vue" --include="*.ts" --include="*.js" 2>/dev/null | grep -v "// eslint-disable" | wc -l || echo "0")
    fi

    if [ "$count" -eq 0 ]; then
        pass
    elif [ "$count" -le 5 ]; then
        warn "发现 ${count} 处 console 调用残留，发布前需清理"
    else
        fail "发现 ${count} 处 console 调用残留，请清理或使用条件日志"
    fi
}

# =============================================================================
# 检查 4: v-html 使用
# 前端规范 9.1.01 — 使用 v-html 必须净化 HTML 内容
# =============================================================================
check_v_html() {
    begin_check "v-html使用检测" "前端规范 9.1.01 v-html必须净化"

    local count=0
    local details=""

    if [ -d "$FRONTEND_DIR/src" ]; then
        while IFS= read -r line; do
            local file=$(echo "$line" | cut -d: -f1)
            local lineno=$(echo "$line" | cut -d: -f2)
            count=$((count + 1))
            if [ "$count" -le 10 ]; then
                details="${details}\n    ${file}:${lineno}"
            fi
        done < <(grep -rn "v-html" "$FRONTEND_DIR/src" --include="*.vue" 2>/dev/null || true)
    fi

    if [ "$count" -eq 0 ]; then
        pass
    else
        warn "发现 ${count} 处 v-html 使用，请确保使用 DOMPurify 净化：${details}"
    fi
}

# =============================================================================
# 检查 5: 硬编码颜色值
# 前端规范 1.1.02 — 禁止硬编码颜色，使用设计令牌
# =============================================================================
check_hardcoded_colors() {
    begin_check "硬编码颜色检测" "前端规范 1.1.02 使用设计令牌"

    local count=0

    if [ -d "$FRONTEND_DIR/src" ]; then
        # 检测 style 中的硬编码颜色（排除 CSS 变量引用）
        count=$(grep -rn "color\s*:\s*#[0-9a-fA-F]\{3,8\}\|background-color\s*:\s*#[0-9a-fA-F]\{3,8\}" "$FRONTEND_DIR/src" --include="*.vue" --include="*.css" --include="*.scss" 2>/dev/null | grep -v "var(--" | wc -l || echo "0")
    fi

    if [ "$count" -eq 0 ]; then
        pass
    elif [ "$count" -le 5 ]; then
        warn "发现 ${count} 处硬编码颜色值，建议使用 CSS 变量（设计令牌）"
    else
        fail "发现 ${count} 处硬编码颜色值，请使用 var(--color-xxx) 设计令牌"
    fi
}

# =============================================================================
# 检查 6: API 调用错误处理
# 前端规范 3.6.2 — 错误处理规范
# =============================================================================
check_api_error_handling() {
    begin_check "API错误处理" "前端规范 3.6.2 禁止吞掉错误"

    local no_catch=0
    local details=""

    if [ -d "$FRONTEND_DIR/src" ]; then
        # 检测 .catch(() => {}) 空 catch 或 .then() 无 .catch 的模式
        no_catch=$(grep -rn "\.catch(() =>\s*{)" "$FRONTEND_DIR/src" --include="*.vue" --include="*.ts" --include="*.js" 2>/dev/null | wc -l || echo "0")
    fi

    if [ "$no_catch" -eq 0 ]; then
        pass
    else
        warn "发现 ${no_catch} 处可能的空 catch 块（吞错误模式），请确认有错误处理"
    fi
}

# =============================================================================
# 检查 7: TypeScript any 使用
# 前端规范 2.1.01 — 禁止使用 any
# =============================================================================
check_ts_any() {
    begin_check "TypeScript any检测" "前端规范 2.1.01 禁止any"

    local count=0

    if [ -d "$FRONTEND_DIR/src" ]; then
        count=$(grep -rn ": any\b\|as any\b\|<any>" "$FRONTEND_DIR/src" --include="*.ts" --include="*.vue" 2>/dev/null | grep -v "// @ts-ignore" | grep -v "node_modules" | wc -l || echo "0")
    fi

    if [ "$count" -eq 0 ]; then
        pass
    elif [ "$count" -le 10 ]; then
        warn "发现 ${count} 处 any 类型使用，请替换为具体类型"
    else
        fail "发现 ${count} 处 any 类型使用，请按前端规范 2.1.01 替换为具体类型或 unknown"
    fi
}

# =============================================================================
# 执行所有检查
# =============================================================================
echo "============================================"
echo "  前端规范合规检查"
echo "  目录: ${FRONTEND_DIR}"
echo "  对齐: rule/前端规范.txt"
echo "============================================"
echo ""

check_script_setup
check_typescript_usage
check_console_log
check_v_html
check_hardcoded_colors
check_api_error_handling
check_ts_any

# =============================================================================
# 输出报告
# =============================================================================
echo -e "$RESULTS"
echo ""
echo "============================================"
echo "  检查结果汇总"
echo "============================================"
echo "  总检查项: ${TOTAL_CHECKS}"
echo -e "  ${GREEN}通过: ${PASSED}${NC}"
echo -e "  ${RED}失败: ${FAILED}${NC}"
echo -e "  ${YELLOW}警告: ${WARNINGS}${NC}"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}存在 ${FAILED} 项不合规，请修复后重新检查。${NC}"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}存在 ${WARNINGS} 项警告，建议改进。${NC}"
    exit 0
else
    echo -e "${GREEN}所有检查项通过！${NC}"
    exit 0
fi
