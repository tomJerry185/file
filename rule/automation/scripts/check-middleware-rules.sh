#!/bin/bash
# =============================================================================
# 中间件规范合规检查脚本
# 对齐文件：rule/中间件规范.txt
# 用途：CI/CD 集成或本地 pre-commit 检查
# 使用：bash rule/automation/scripts/check-middleware-rules.sh [项目根目录]
# =============================================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m'

# 项目根目录
PROJECT_ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"

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
# 检查 1: YAML 配置中硬编码 IP 地址
# 中间件规范 2.1.01 — 禁止硬编码连接信息
# =============================================================================
check_hardcoded_ip() {
    begin_check "硬编码IP检测" "中间件规范 2.1.01 禁止硬编码IP"

    local count=0
    local details=""

    while IFS= read -r line; do
        local file=$(echo "$line" | cut -d: -f1)
        local lineno=$(echo "$line" | cut -d: -f2)
        # 排除使用变量引用的行 ${} 和 localhost/127.0.0.1
        if ! echo "$line" | grep -qE '\$\{|localhost|127\.0\.0\.1'; then
            count=$((count + 1))
            if [ "$count" -le 10 ]; then
                details="${details}\n    ${file}:${lineno}"
            fi
        fi
    done < <(grep -rn "server-addr:\s*\d\{1,3\}\.\d\{1,3\}\.\d\{1,3\}\.\d\{1,3\}" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" --include="*.properties" 2>/dev/null | grep -v "node_modules" | grep -v "/target/" || true)

    if [ "$count" -eq 0 ]; then
        pass
    else
        fail "发现 ${count} 处硬编码IP地址，请使用环境变量：${details}"
    fi
}

# =============================================================================
# 检查 2: YAML 配置中硬编码密码
# 中间件规范 2.1.01
# =============================================================================
check_hardcoded_password() {
    begin_check "硬编码密码检测" "中间件规范 2.1.01 禁止硬编码密码"

    local count=0

    count=$(grep -rn "password:\s*[a-zA-Z0-9_]\{6,\}" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" --include="*.properties" 2>/dev/null | grep -v '\$\{' | grep -v 'node_modules' | grep -v '/target/' | wc -l || echo "0")

    if [ "$count" -eq 0 ]; then
        pass
    else
        fail "发现 ${count} 处可能硬编码的密码，请使用环境变量 \${DB_PASSWORD} 等"
    fi
}

# =============================================================================
# 检查 3: Feign 超时配置覆盖率
# 中间件规范 4.4.01 — 必须配置超时
# =============================================================================
check_feign_timeout() {
    begin_check "Feign超时配置" "中间件规范 4.4.01 Feign必须配置超时"

    local feign_clients=0
    local configured=0

    # 统计 FeignClient 数量
    feign_clients=$(grep -rl "@FeignClient" "$PROJECT_ROOT" --include="*.java" 2>/dev/null | grep -v "/target/" | wc -l || echo "0")

    # 统计有超时配置的
    configured=$(grep -rl "connectTimeout\|readTimeout\|connect-timeout\|read-timeout" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" --include="*.java" 2>/dev/null | grep -v "node_modules" | grep -v "/target/" | wc -l || echo "0")

    if [ "$feign_clients" -eq 0 ]; then
        warn "未找到 FeignClient，跳过检查"
    elif [ "$configured" -gt 0 ]; then
        pass
    else
        warn "发现 ${feign_clients} 个 FeignClient 但未找到超时配置，请按中间件规范 4.4.01 配置 connectTimeout/readTimeout"
    fi
}

# =============================================================================
# 检查 4: HikariCP 连接池配置完整性
# 中间件规范 4.9.01 — 必须配置连接池参数
# =============================================================================
check_hikari_config() {
    begin_check "HikariCP连接池" "中间件规范 4.9.01 连接池配置完整性"

    local has_max=0
    local has_min=0
    local has_timeout=0

    if [ -d "$PROJECT_ROOT" ]; then
        has_max=$(grep -rl "maximum-pool-size\|max-active\|maximumPoolSize" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" --include="*.properties" 2>/dev/null | grep -v "node_modules" | grep -v "/target/" | wc -l || echo "0")
        has_min=$(grep -rl "minimum-idle\|min-idle\|minimumIdle" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" --include="*.properties" 2>/dev/null | grep -v "node_modules" | grep -v "/target/" | wc -l || echo "0")
        has_timeout=$(grep -rl "connection-timeout\|connectionTimeout" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" --include="*.properties" 2>/dev/null | grep -v "node_modules" | grep -v "/target/" | wc -l || echo "0")
    fi

    if [ "$has_max" -gt 0 ] && [ "$has_min" -gt 0 ] && [ "$has_timeout" -gt 0 ]; then
        pass
    else
        local missing=""
        [ "$has_max" -eq 0 ] && missing="${missing} maximum-pool-size"
        [ "$has_min" -eq 0 ] && missing="${missing} minimum-idle"
        [ "$has_timeout" -eq 0 ] && missing="${missing} connection-timeout"
        warn "HikariCP 连接池配置不完整，缺少:${missing}"
    fi
}

# =============================================================================
# 检查 5: RocketMQ 消费者幂等处理
# 中间件规范 3.2.01 / 4.7.03 — 消费必须幂等
# =============================================================================
check_mq_idempotent() {
    begin_check "MQ幂等处理" "中间件规范 3.2.01 消费端必须幂等"

    local consumers=0
    local idempotent=0

    consumers=$(grep -rl "RocketMQListener\|@RocketMQMessageListener" "$PROJECT_ROOT" --include="*.java" 2>/dev/null | grep -v "/target/" | wc -l || echo "0")

    # 检测幂等相关关键词
    idempotent=$(grep -rl "setIfAbsent\|setnx\|idempotent\|幂等\|唯一键" "$PROJECT_ROOT" --include="*.java" 2>/dev/null | grep -v "/target/" | wc -l || echo "0")

    if [ "$consumers" -eq 0 ]; then
        warn "未找到 RocketMQ 消费者，跳过检查"
    elif [ "$idempotent" -gt 0 ]; then
        pass
    else
        warn "发现 ${consumers} 个 MQ 消费者但未找到幂等处理代码，请按中间件规范 3.2.01 添加幂等控制"
    fi
}

# =============================================================================
# 检查 6: Sentinel 规则源配置
# 中间件规范 4.3.01 — 规则源必须集中管理
# =============================================================================
check_sentinel_rules() {
    begin_check "Sentinel规则源" "中间件规范 4.3.01 规则集中管理"

    local has_datasource=0

    has_datasource=$(grep -rl "datasource.*nacos\|nacos.*rule-type" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" 2>/dev/null | grep -v "node_modules" | grep -v "/target/" | wc -l || echo "0")

    if [ "$has_datasource" -gt 0 ]; then
        pass
    else
        warn "未找到 Sentinel Nacos 数据源配置，建议按中间件规范 4.3.01 集中管理规则"
    fi
}

# =============================================================================
# 执行所有检查
# =============================================================================
echo "============================================"
echo "  中间件规范合规检查"
echo "  项目: ${PROJECT_ROOT}"
echo "  对齐: rule/中间件规范.txt"
echo "============================================"
echo ""

check_hardcoded_ip
check_hardcoded_password
check_feign_timeout
check_hikari_config
check_mq_idempotent
check_sentinel_rules

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
