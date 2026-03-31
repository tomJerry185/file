#!/bin/bash
# =============================================================================
# 安全规范合规检查脚本
# 对齐文件：rule/安全防护规范.md
# 用途：CI/CD 集成或本地检查
# 使用：bash rule/automation/scripts/check-security-rules.sh [项目根目录]
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PROJECT_ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"

TOTAL_CHECKS=0
PASSED=0
FAILED=0
WARNINGS=0
RESULTS=""

check_name=""
check_desc=""

begin_check() {
    check_name="$1"
    check_desc="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

pass() { PASSED=$((PASSED + 1)); RESULTS="${RESULTS}\n${GREEN}[PASS]${NC} ${check_name}: ${check_desc}"; }
fail() { local msg="$1"; FAILED=$((FAILED + 1)); RESULTS="${RESULTS}\n${RED}[FAIL]${NC} ${check_name}: ${msg}"; }
warn() { local msg="$1"; WARNINGS=$((WARNINGS + 1)); RESULTS="${RESULTS}\n${YELLOW}[WARN]${NC} ${check_name}: ${msg}"; }

# =============================================================================
# 检查 1: API 限流配置覆盖率
# SEC-RATE-* — 关键接口必须配置限流
# =============================================================================
check_rate_limit() {
    begin_check "API限流配置" "SEC-RATE-* 关键接口限流覆盖率"

    local has_sentinel=0
    local has_gateway_rate=0

    has_sentinel=$(grep -rl "@SentinelResource\|@RateLimiter\|sentinel" "$PROJECT_ROOT" --include="*.java" --include="*.yml" 2>/dev/null | grep -v "target/" | wc -l || echo "0")
    has_gateway_rate=$(grep -rl "RequestRateLimiter\|RateLimiter\|rate-limit" "$PROJECT_ROOT" --include="*.java" --include="*.yml" 2>/dev/null | grep -v "target/" | wc -l || echo "0")

    if [ "$has_sentinel" -gt 0 ] && [ "$has_gateway_rate" -gt 0 ]; then
        pass
    elif [ "$has_sentinel" -gt 0 ]; then
        warn "Sentinel 限流已配置，但网关层限流未找到，建议补充"
    else
        fail "未找到 API 限流配置，请按 SEC-RATE-* 规范配置"
    fi
}

# =============================================================================
# 检查 2: 硬编码密钥/密码
# SEC-SQL-002 — 禁止硬编码
# =============================================================================
check_hardcoded_secrets() {
    begin_check "硬编码密钥检测" "SEC-SQL-002 禁止硬编码密码/密钥"

    local count=0
    local details=""

    while IFS= read -r line; do
        local file=$(echo "$line" | cut -d: -f1)
        local lineno=$(echo "$line" | cut -d: -f2)
        count=$((count + 1))
        if [ "$count" -le 10 ]; then
            details="${details}\n    ${file}:${lineno}"
        fi
    done < <(grep -rn "password\s*=\s*['\"][^$\"'{][a-zA-Z0-9_]\{8,\}" "$PROJECT_ROOT" --include="*.java" --include="*.properties" --include="*.yml" 2>/dev/null | grep -v 'target/' | grep -v 'test/' | grep -v 'simple\.yml' | grep -v '\${' || true)

    if [ "$count" -eq 0 ]; then
        pass
    else
        fail "发现 ${count} 处可能硬编码的密码/密钥：${details}"
    fi
}

# =============================================================================
# 检查 3: CSRF 配置
# SEC-CSRF-001 — 状态变更接口需要 CSRF 防护
# =============================================================================
check_csrf() {
    begin_check "CSRF防护" "SEC-CSRF-001 状态变更接口CSRF防护"

    local has_csrf=0
    local has_cors=0

    has_csrf=$(grep -rl "csrf\|CsrfFilter\|CsrfToken" "$PROJECT_ROOT" --include="*.java" --include="*.yml" 2>/dev/null | grep -v "target/" | wc -l || echo "0")
    has_cors=$(grep -rl "CorsConfiguration\|@CrossOrigin\|cors" "$PROJECT_ROOT" --include="*.java" --include="*.yml" 2>/dev/null | grep -v "target/" | wc -l || echo "0")

    if [ "$has_csrf" -gt 0 ]; then
        pass
    elif [ "$has_cors" -gt 0 ]; then
        warn "找到 CORS 配置但未找到 CSRF 配置，API 场景可接受但建议确认"
    else
        warn "未找到 CSRF/CORS 配置，请确认安全策略"
    fi
}

# =============================================================================
# 检查 4: 文件上传安全
# SEC-UPLOAD-001 — 白名单 + 大小限制
# =============================================================================
check_file_upload() {
    begin_check "文件上传安全" "SEC-UPLOAD-001 白名单+大小限制"

    local has_upload_config=0

    has_upload_config=$(grep -rl "max-file-size\|MaxFileSize\|multipart\|allowedExtensions\|白名单" "$PROJECT_ROOT" --include="*.java" --include="*.yml" 2>/dev/null | grep -v "target/" | wc -l || echo "0")

    if [ "$has_upload_config" -gt 0 ]; then
        pass
    else
        warn "未找到文件上传安全配置，如无上传功能可忽略"
    fi
}

# =============================================================================
# 检查 5: v-html 未净化
# SEC-XSS-002 — v-html 必须使用 DOMPurify
# =============================================================================
check_vhtml_sanitized() {
    begin_check "v-html净化检测" "SEC-XSS-002 v-html必须净化"

    local vhtml_count=0
    local sanitized_count=0

    if [ -d "$PROJECT_ROOT/frontend/src" ]; then
        vhtml_count=$(grep -rl "v-html" "$PROJECT_ROOT/frontend/src" --include="*.vue" 2>/dev/null | wc -l || echo "0")
        sanitized_count=$(grep -rl "DOMPurify\|sanitize\|purify\|xss" "$PROJECT_ROOT/frontend/src" --include="*.vue" --include="*.ts" --include="*.js" 2>/dev/null | wc -l || echo "0")
    fi

    if [ "$vhtml_count" -eq 0 ]; then
        pass
    elif [ "$sanitized_count" -gt 0 ]; then
        pass
    else
        fail "发现 ${vhtml_count} 处 v-html 使用但未找到 DOMPurify 净化，存在 XSS 风险"
    fi
}

# =============================================================================
# 检查 6: Cookie 安全属性
# SEC-COOKIE-001 — HttpOnly + Secure + SameSite
# =============================================================================
check_cookie_security() {
    begin_check "Cookie安全属性" "SEC-COOKIE-001 HttpOnly+Secure+SameSite"

    local has_secure_cookie=0

    has_secure_cookie=$(grep -rn "HttpOnly\|httpOnly\|SameSite\|sameSite" "$PROJECT_ROOT" --include="*.java" --include="*.yml" 2>/dev/null | grep -v "target/" | wc -l || echo "0")

    if [ "$has_secure_cookie" -gt 0 ]; then
        pass
    else
        warn "未找到 Cookie 安全属性配置（HttpOnly/SameSite），请确认 Sa-Token 配置"
    fi
}

# =============================================================================
# 检查 7: CORS 通配符
# SEC-CORS-001 — 禁止 Access-Control-Allow-Origin: *
# =============================================================================
check_cors_wildcard() {
    begin_check "CORS通配符检测" "SEC-CORS-001 禁止 CORS *"

    local count=0

    count=$(grep -rn "allowedOrigin.*\*\|AllowOrigin.*\*\|access-control-allow-origin.*\*" "$PROJECT_ROOT" --include="*.java" --include="*.yml" 2>/dev/null | grep -v "target/" | grep -v "test/" | wc -l || echo "0")

    if [ "$count" -eq 0 ]; then
        pass
    else
        fail "发现 ${count} 处 CORS 通配符配置，生产环境禁止使用 *"
    fi
}

# =============================================================================
# 检查 8: MyBatis ${} 使用（SQL 注入风险）
# SEC-SQL-003 — 禁止 ${} 传递用户输入
# =============================================================================
check_mybatis_dollar() {
    begin_check "MyBatis\${}检测" "SEC-SQL-003 禁止\${}传递用户输入"

    local count=0
    local details=""

    while IFS= read -r line; do
        local file=$(echo "$line" | cut -d: -f1)
        local lineno=$(echo "$line" | cut -d: -f2)
        count=$((count + 1))
        if [ "$count" -le 10 ]; then
            details="${details}\n    ${file}:${lineno}"
        fi
    done < <(grep -rn '\$\{' "$PROJECT_ROOT" --include="*.xml" 2>/dev/null | grep -v "target/" | grep -v "node_modules" || true)

    if [ "$count" -eq 0 ]; then
        pass
    else
        warn "发现 ${count} 处 MyBatis \${} 使用，请确认非用户输入：${details}"
    fi
}

# =============================================================================
# 执行所有检查
# =============================================================================
echo "============================================"
echo "  安全规范合规检查"
echo "  项目: ${PROJECT_ROOT}"
echo "  对齐: rule/安全防护规范.md"
echo "============================================"
echo ""

check_rate_limit
check_hardcoded_secrets
check_csrf
check_file_upload
check_vhtml_sanitized
check_cookie_security
check_cors_wildcard
check_mybatis_dollar

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
    echo -e "${RED}存在 ${FAILED} 项安全合规失败，请修复后重新检查。${NC}"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}存在 ${WARNINGS} 项安全警告，建议改进。${NC}"
    exit 0
else
    echo -e "${GREEN}所有安全检查项通过！${NC}"
    exit 0
fi
