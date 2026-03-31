#!/bin/bash
# =============================================================================
# 后端规范合规检查脚本
# 对齐文件：rule/后端规范.md
# 用途：CI/CD 集成或本地 pre-commit 检查
# 使用：bash rule/automation/scripts/check-backend-rules.sh [项目根目录]
# =============================================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录（默认为脚本上级目录的上级目录）
PROJECT_ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
SRC_DIR="${PROJECT_ROOT}"

# 计数器
TOTAL_CHECKS=0
PASSED=0
FAILED=0
WARNINGS=0

# 结果收集
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
# 检查 1: @Autowired 字段注入 vs 构造器注入
# 后端规范 5.1.01 — 构造器注入优先
# =============================================================================
check_field_injection() {
    begin_check "字段注入检测" "后端规范 5.1.01 构造器注入优先"

    local autowired_count=0
    local constructor_count=0
    local files=""

    if [ -d "$SRC_DIR" ]; then
        # 查找 @Autowired 字段注入（排除构造器参数上的 @Autowired）
        # 通过检测 @Autowired 注解是否在字段声明行上（非 public/private/protected 开头的构造器参数）
        while IFS= read -r match; do
            local file=$(echo "$match" | cut -d: -f1)
            local lineno=$(echo "$match" | cut -d: -f2)
            # 读取注解下一行，判断是否为字段注入（行首有空白 + private/protected/public 或直接是类型声明）
            local next_line=$(sed -n "$((lineno + 1))p" "$file" 2>/dev/null)
            if echo "$next_line" | grep -qE "^\s*(private|protected|public|volatile|final)\s+\w+"; then
                autowired_count=$((autowired_count + 1))
            fi
        done < <(grep -rn "@Autowired" "$SRC_DIR" --include="*.java" 2>/dev/null | grep -v "/target/" || true)

        # 统计使用构造器注入的文件数（@RequiredArgsConstructor 或 @AllArgsConstructor）
        constructor_count=$(grep -rl "@RequiredArgsConstructor\|@AllArgsConstructor" "$SRC_DIR" --include="*.java" 2>/dev/null | grep -v "/target/" | wc -l)
    fi

    if [ "$autowired_count" -eq 0 ]; then
        pass
    elif [ "$autowired_count" -le 5 ]; then
        warn "发现 ${autowired_count} 处 @Autowired 字段注入（构造器注入文件: ${constructor_count}），建议迁移"
    else
        fail "发现 ${autowired_count} 处 @Autowired 字段注入（构造器注入文件: ${constructor_count}），请按后端规范 5.1.01 迁移为构造器注入"
    fi
}

# =============================================================================
# 检查 2: Mapper XML 中的 SELECT *
# 后端规范 6.1.01 — 禁止 SELECT *
# =============================================================================
check_select_star() {
    begin_check "SELECT * 检测" "后端规范 6.1.01 禁止 SELECT *"

    local count=0
    local details=""

    if [ -d "$SRC_DIR" ]; then
        while IFS= read -r line; do
            local file=$(echo "$line" | cut -d: -f1)
            local lineno=$(echo "$line" | cut -d: -f2)
            count=$((count + 1))
            details="${details}\n    ${file}:${lineno}"
        done < <(grep -rn "SELECT\s*\*" "$SRC_DIR" --include="*.xml" 2>/dev/null | grep -i "select" || true)
    fi

    if [ "$count" -eq 0 ]; then
        pass
    else
        fail "发现 ${count} 处 SELECT * 查询：${details}"
    fi
}

# =============================================================================
# 检查 3: Controller 直接注入 Mapper/Repository
# 后端规范 2.1.01/1.2.02 — 禁止跨层调用
# =============================================================================
check_controller_mapper() {
    begin_check "Controller跨层检测" "后端规范 2.1.02 Controller禁止直接访问Mapper"

    local count=0
    local details=""

    if [ -d "$SRC_DIR" ]; then
        while IFS= read -r line; do
            local file=$(echo "$line" | cut -d: -f1)
            local lineno=$(echo "$line" | cut -d: -f2)
            # 只检查 Controller 文件
            if echo "$file" | grep -qi "controller"; then
                count=$((count + 1))
                details="${details}\n    ${file}:${lineno}"
            fi
        done < <(grep -rn "Mapper\|Repository" "$SRC_DIR" --include="*.java" 2>/dev/null | grep -i "import.*\(Mapper\|Repository\)" || true)
    fi

    if [ "$count" -eq 0 ]; then
        pass
    else
        fail "发现 ${count} 处 Controller 直接注入 Mapper/Repository：${details}"
    fi
}

# =============================================================================
# 检查 4: Fallback 返回空对象伪装成功
# 后端规范 2.6.02 — 降级后不得返回伪成功
# 流程手册 3.5.3
# =============================================================================
check_fallback_fake_success() {
    begin_check "Fallback伪成功检测" "后端规范 2.6.02 降级不得返回伪成功"

    local count=0
    local details=""

    if [ -d "$SRC_DIR" ]; then
        # 检测 Fallback/FallbackFactory 中的 new XxxDTO() / new XxxVO() / new XxxInfo()
        while IFS= read -r line; do
            local file=$(echo "$line" | cut -d: -f1)
            local lineno=$(echo "$line" | cut -d: -f2)
            count=$((count + 1))
            details="${details}\n    ${file}:${lineno}"
        done < <(grep -rn "return new.*\(DTO\|VO\|Info\|Result\.success\)" "$SRC_DIR" --include="*.java" 2>/dev/null | grep -i "fallback\|fallbackfactory" || true)
    fi

    if [ "$count" -eq 0 ]; then
        pass
    else
        fail "发现 ${count} 处 Fallback 可能返回伪成功对象：${details}"
    fi
}

# =============================================================================
# 检查 5: System.out.println / printStackTrace
# 通用编码规范
# =============================================================================
check_print_statements() {
    begin_check "打印语句检测" "禁止 System.out.println / printStackTrace"

    local count=0
    local details=""

    if [ -d "$SRC_DIR" ]; then
        count=$(grep -rn "System\.out\.println\|System\.err\.println\|\.printStackTrace()" "$SRC_DIR" --include="*.java" 2>/dev/null | grep -v "test/" | grep -v "/target/" | wc -l || echo "0")
    fi

    if [ "$count" -eq 0 ]; then
        pass
    elif [ "$count" -le 3 ]; then
        warn "发现 ${count} 处打印语句残留，建议使用 SLF4J Logger"
    else
        fail "发现 ${count} 处打印语句残留，请替换为 SLF4J Logger"
    fi
}

# =============================================================================
# 检查 6: Service 接口 + Impl 模式
# 后端规范 2.2.01 — Service 必须定义接口
# =============================================================================
check_service_interface() {
    begin_check "Service接口规范" "后端规范 2.2.01 Service必须有接口"

    local impl_without_iface=0
    local details=""

    if [ -d "$SRC_DIR" ]; then
        # 查找 ServiceImpl 文件，检查是否有对应接口
        while IFS= read -r file; do
            local classname=$(basename "$file" .java)
            local iface_name="${classname%Impl}"
            local dir=$(dirname "$file")

            # 在同目录或上级查找接口文件
            if ! find "$dir" -name "${iface_name}.java" -type f 2>/dev/null | head -1 | grep -q .; then
                impl_without_iface=$((impl_without_iface + 1))
                if [ "$impl_without_iface" -le 5 ]; then
                    details="${details}\n    ${file} — 缺少接口 ${iface_name}.java"
                fi
            fi
        done < <(find "$SRC_DIR" -name "*ServiceImpl.java" -type f 2>/dev/null | grep -v "/target/" || true)
    fi

    if [ "$impl_without_iface" -eq 0 ]; then
        pass
    else
        fail "发现 ${impl_without_iface} 个 ServiceImpl 缺少对应接口：${details}"
    fi
}

# =============================================================================
# 检查 7: 空 catch 块
# 后端规范 14.6.01
# =============================================================================
check_empty_catch() {
    begin_check "空catch块检测" "后端规范 14.6.01 禁止空catch块"

    local count=0

    if [ -d "$SRC_DIR" ]; then
        count=$(grep -rPzl "catch\s*\([^)]+\)\s*\{\s*\}" "$SRC_DIR" --include="*.java" 2>/dev/null | grep -v "test/" | grep -v "/target/" | wc -l || echo "0")
    fi

    if [ "$count" -eq 0 ]; then
        pass
    else
        warn "发现 ${count} 个文件包含空 catch 块，至少需要 log.warn"
    fi
}

# =============================================================================
# 执行所有检查
# =============================================================================
echo "============================================"
echo "  后端规范合规检查"
echo "  项目: ${PROJECT_ROOT}"
echo "  对齐: rule/后端规范.md"
echo "============================================"
echo ""

check_field_injection
check_select_star
check_controller_mapper
check_fallback_fake_success
check_print_statements
check_service_interface
check_empty_catch

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
