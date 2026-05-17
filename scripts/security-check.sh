#!/bin/bash

# KidMemory 1.0 安全检查脚本
# 自动化安全扫描和漏洞检测

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}🔒 KidMemory 1.0 安全检查${NC}"
echo "========================================"
echo "检查时间: $(date)"
echo "项目路径: $PROJECT_ROOT"
echo ""

# 检查结果统计
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0
CRITICAL_ISSUES=0

# 辅助函数
security_check() {
    local name="$1"
    local status="$2"
    local message="$3"
    local severity="$4"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    case $status in
        "PASS")
            echo -e "✅ ${GREEN}PASS${NC} $name"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            ;;
        "FAIL")
            echo -e "❌ ${RED}FAIL${NC} $name - $message"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            if [ "$severity" = "CRITICAL" ]; then
                CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            fi
            ;;
        "WARN")
            echo -e "⚠️  ${YELLOW}WARN${NC} $name - $message"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            ;;
    esac
}

log_section() {
    echo -e "${BLUE}$1${NC}"
    echo "----------------------------------------"
}

# 1. 敏感文件检查
log_section "🔍 敏感文件和配置检查"

# 检查是否有敏感文件被意外提交
SENSITIVE_PATTERNS=(
    "*.key"
    "*.pem"
    "*.p12"
    "*.pfx"
    "id_rsa"
    "id_dsa"
    "dump.rdb"
)

FOUND_SENSITIVE=false
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    MATCHES=$(find . -name "$pattern" \
        -not -path "./node_modules/*" \
        -not -path "./.git/*" \
        -not -path "./packages/*/node_modules/*" \
        -not -path "./packages/*/build/*" \
        -not -path "./packages/*/dist/*" \
        -not -path "./test-results/*")
    if [ -n "$MATCHES" ]; then
        FOUND_SENSITIVE=true
        echo "发现敏感文件: $MATCHES"
    fi
done

if [ "$FOUND_SENSITIVE" = true ]; then
    security_check "敏感文件检查" "WARN" "发现可能的敏感文件"
else
    security_check "敏感文件检查" "PASS"
fi

# 检查 .env 文件
if [ -f ".env" ]; then
    if git check-ignore .env >/dev/null 2>&1; then
        security_check ".env 文件保护" "PASS"
    else
        security_check ".env 文件保护" "FAIL" ".env 文件未被 .gitignore 忽略" "CRITICAL"
    fi
else
    security_check ".env 文件存在性" "WARN" ".env 文件不存在"
fi

# 检查硬编码密钥
HARDCODED_PATTERNS=(
    "password\\s*[:=]\\s*['\"][^'\"]{8,}['\"]"
    "api[_-]?key\\s*[:=]\\s*['\"][^'\"]{20,}['\"]"
    "secret\\s*[:=]\\s*['\"][^'\"]{16,}['\"]"
    "token\\s*[:=]\\s*['\"][^'\"]{20,}['\"]"
)

HARDCODED_FOUND=false
SCAN_SCOPE="packages/sidecar/src packages/cloud-api/src packages/web/src packages/desktop/lib"
for pattern in "${HARDCODED_PATTERNS[@]}"; do
    if rg -n -i -P "$pattern" $SCAN_SCOPE >/dev/null 2>&1; then
        HARDCODED_FOUND=true
        break
    fi
done

if [ "$HARDCODED_FOUND" = true ]; then
    security_check "硬编码密钥检查" "FAIL" "发现硬编码密钥样式字面量" "CRITICAL"
else
    security_check "硬编码密钥检查" "PASS"
fi

echo ""

# 2. 依赖漏洞扫描
log_section "📦 依赖漏洞扫描"

# 后端依赖扫描
if [ -d "packages/sidecar" ]; then
    cd packages/sidecar

    if [ -f "package.json" ] && [ -d "node_modules" ]; then
        echo "扫描后端依赖漏洞..."

        # 运行 npm audit
        if npm audit --omit=dev --audit-level=high >/dev/null 2>&1; then
            security_check "后端依赖漏洞" "PASS"
        else
            AUDIT_OUTPUT=$(npm audit --omit=dev --audit-level=high 2>&1 || true)
            if echo "$AUDIT_OUTPUT" | grep -q "high\|critical"; then
                security_check "后端依赖漏洞" "WARN" "发现高危或严重漏洞（建议尽快修复）"
            else
                security_check "后端依赖漏洞" "WARN" "发现中低危漏洞"
            fi
        fi

        # 检查过时依赖
        OUTDATED_COUNT=$(npm outdated --json 2>/dev/null | jq 'length' 2>/dev/null || echo "0")
        if [ "$OUTDATED_COUNT" -gt 10 ]; then
            security_check "后端依赖更新" "WARN" "有 $OUTDATED_COUNT 个过时依赖"
        else
            security_check "后端依赖更新" "PASS"
        fi
    else
        security_check "后端依赖扫描" "WARN" "依赖未安装或配置不完整"
    fi

    cd "$PROJECT_ROOT"
fi

# Web 前端依赖扫描
if [ -d "packages/web" ]; then
    cd packages/web

    if [ -f "package.json" ] && [ -d "node_modules" ]; then
        echo "扫描 Web 前端依赖漏洞..."

        if npm audit --omit=dev --audit-level=high >/dev/null 2>&1; then
            security_check "Web前端依赖漏洞" "PASS"
        else
            AUDIT_OUTPUT=$(npm audit --omit=dev --audit-level=high 2>&1 || true)
            if echo "$AUDIT_OUTPUT" | grep -q "high\|critical"; then
                security_check "Web前端依赖漏洞" "WARN" "发现高危或严重漏洞（建议尽快修复）"
            else
                security_check "Web前端依赖漏洞" "WARN" "发现中低危漏洞"
            fi
        fi
    else
        security_check "Web前端依赖扫描" "WARN" "依赖未安装或配置不完整"
    fi

    cd "$PROJECT_ROOT"
fi

echo ""

# 3. 代码安全分析
log_section "🔍 代码安全分析"

# SQL 注入检查
SQL_INJECTION_PATTERNS=(
    "query.*\+.*req\."
    "SELECT.*\+.*req\."
    "INSERT.*\+.*req\."
    "UPDATE.*\+.*req\."
    "DELETE.*\+.*req\."
)

SQL_INJECTION_FOUND=false
for pattern in "${SQL_INJECTION_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" --include="*.ts" --include="*.js" --exclude-dir=node_modules --exclude-dir=.git . >/dev/null 2>&1; then
        SQL_INJECTION_FOUND=true
        break
    fi
done

if [ "$SQL_INJECTION_FOUND" = true ]; then
    security_check "SQL注入风险" "FAIL" "发现可能的SQL注入风险" "CRITICAL"
else
    security_check "SQL注入风险" "PASS"
fi

# XSS 检查
XSS_PATTERNS=(
    "innerHTML.*\+.*req\."
    "document\.write.*\+.*req\."
    "eval\("
    "new\s+Function\("
)

XSS_FOUND=false
for pattern in "${XSS_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" --exclude-dir=node_modules --exclude-dir=.git . >/dev/null 2>&1; then
        XSS_FOUND=true
        break
    fi
done

if [ "$XSS_FOUND" = true ]; then
    security_check "XSS风险" "WARN" "发现可能的XSS风险，请人工复核"
else
    security_check "XSS风险" "PASS"
fi

# 不安全的随机数生成
WEAK_RANDOM_PATTERNS=(
    "Math\.random\(\)"
    "new Date\(\)\.getTime\(\)"
)

WEAK_RANDOM_FOUND=false
for pattern in "${WEAK_RANDOM_PATTERNS[@]}"; do
    if grep -r -E "$pattern" --include="*.ts" --include="*.js" --include="*.dart" --exclude-dir=node_modules --exclude-dir=.git . >/dev/null 2>&1; then
        WEAK_RANDOM_FOUND=true
        break
    fi
done

if [ "$WEAK_RANDOM_FOUND" = true ]; then
    security_check "随机数生成安全性" "WARN" "发现不安全的随机数生成"
else
    security_check "随机数生成安全性" "PASS"
fi

echo ""

# 4. 配置安全检查
log_section "⚙️ 配置安全检查"

# 检查数据库配置
if [ -f "packages/sidecar/.env" ]; then
    # 检查默认密码
    if grep -q "password.*=.*password\|password.*=.*123456\|password.*=.*admin" packages/sidecar/.env; then
        security_check "数据库密码强度" "FAIL" "使用了弱密码" "CRITICAL"
    else
        security_check "数据库密码强度" "PASS"
    fi

    # 检查生产环境配置
    if grep -q "NODE_ENV.*=.*production" packages/sidecar/.env; then
        if grep -q "DEBUG.*=.*true" packages/sidecar/.env; then
            security_check "生产环境调试模式" "FAIL" "生产环境启用了调试模式" "CRITICAL"
        else
            security_check "生产环境调试模式" "PASS"
        fi
    fi
else
    security_check "后端环境配置" "WARN" "后端环境配置文件不存在"
fi

# 检查 CORS 配置
if grep -r "cors" packages/sidecar/src/ >/dev/null 2>&1; then
    if grep -r "origin.*\*" packages/sidecar/src/ >/dev/null 2>&1; then
        security_check "CORS配置" "WARN" "CORS配置过于宽松"
    else
        security_check "CORS配置" "PASS"
    fi
else
    security_check "CORS配置" "WARN" "未找到CORS配置"
fi

echo ""

# 5. 文件权限检查
log_section "📁 文件权限检查"

# 检查脚本文件权限
SCRIPT_FILES=$(find scripts/ -name "*.sh" 2>/dev/null || true)
if [ -n "$SCRIPT_FILES" ]; then
    INSECURE_SCRIPTS=false
    for script in $SCRIPT_FILES; do
        if [ -f "$script" ]; then
            PERMS=$(stat -f "%A" "$script" 2>/dev/null || stat -c "%a" "$script" 2>/dev/null)
            if [ "$PERMS" -gt 755 ]; then
                INSECURE_SCRIPTS=true
                break
            fi
        fi
    done

    if [ "$INSECURE_SCRIPTS" = true ]; then
        security_check "脚本文件权限" "WARN" "发现权限过宽的脚本文件"
    else
        security_check "脚本文件权限" "PASS"
    fi
fi

# 检查配置文件权限
CONFIG_FILES=(".env" "packages/sidecar/.env")
INSECURE_CONFIGS=false
for config in "${CONFIG_FILES[@]}"; do
    if [ -f "$config" ]; then
        PERMS=$(stat -f "%A" "$config" 2>/dev/null || stat -c "%a" "$config" 2>/dev/null)
        if [ "$PERMS" -gt 600 ]; then
            INSECURE_CONFIGS=true
            break
        fi
    fi
done

if [ "$INSECURE_CONFIGS" = true ]; then
    security_check "配置文件权限" "WARN" "配置文件权限过宽"
else
    security_check "配置文件权限" "PASS"
fi

echo ""

# 6. 网络安全检查
log_section "🌐 网络安全检查"

# 检查是否有不安全的 HTTP 连接
HTTP_PATTERNS=(
    "http://[^/]"
    "ws://[^/]"
)

HTTP_FOUND=false
for pattern in "${HTTP_PATTERNS[@]}"; do
    HTTP_MATCHES=$(rg -n -P "$pattern" packages/sidecar/src packages/cloud-api/src packages/web/src packages/desktop/lib \
      | rg -v "http://localhost|http://127\\.0\\.0\\.1|http://0\\.0\\.0\\.0|https://|ws://localhost|ws://127\\.0\\.0\\.1" || true)
    if [ -n "$HTTP_MATCHES" ]; then
        HTTP_FOUND=true
        break
    fi
done

if [ "$HTTP_FOUND" = true ]; then
    security_check "不安全连接" "WARN" "发现不安全的HTTP连接"
else
    security_check "不安全连接" "PASS"
fi

# 检查端口配置
if rg -n "listen.*0\.0\.0\.0" packages/sidecar/src >/dev/null 2>&1; then
    security_check "端口绑定" "WARN" "服务绑定到所有接口"
else
    security_check "端口绑定" "PASS"
fi

echo ""

# 7. 日志安全检查
log_section "📝 日志安全检查"

# 检查是否记录敏感信息
LOG_SENSITIVE_PATTERNS=(
    "console\.log.*password"
    "console\.log.*token"
    "console\.log.*key"
    "logger.*password"
    "logger.*token"
    "logger.*key"
)

LOG_SENSITIVE_FOUND=false
for pattern in "${LOG_SENSITIVE_PATTERNS[@]}"; do
    if rg -n -i -P "$pattern" packages/sidecar/src packages/cloud-api/src packages/web/src packages/desktop/lib >/dev/null 2>&1; then
        LOG_SENSITIVE_FOUND=true
        break
    fi
done

if [ "$LOG_SENSITIVE_FOUND" = true ]; then
    security_check "日志敏感信息" "FAIL" "日志中可能包含敏感信息" "CRITICAL"
else
    security_check "日志敏感信息" "PASS"
fi

echo ""

# 8. Flutter 特定安全检查
log_section "📱 Flutter 安全检查"

if [ -d "packages/desktop" ]; then
    cd packages/desktop

    # 检查调试模式
    if grep -r "kDebugMode.*true" lib/ >/dev/null 2>&1; then
        security_check "Flutter调试模式" "WARN" "代码中包含调试模式检查"
    else
        security_check "Flutter调试模式" "PASS"
    fi

    # 检查不安全的网络请求
    if grep -r "allowBadCertificates.*true" lib/ >/dev/null 2>&1; then
        security_check "Flutter证书验证" "FAIL" "禁用了证书验证" "CRITICAL"
    else
        security_check "Flutter证书验证" "PASS"
    fi

    cd "$PROJECT_ROOT"
fi

echo ""

# 9. 生成安全报告
log_section "📊 安全报告生成"

REPORT_FILE="security-report-$(date +%Y%m%d-%H%M%S).md"

cat > "$REPORT_FILE" << EOF
# KidMemory 安全检查报告

**生成时间**: $(date)
**项目路径**: $PROJECT_ROOT

## 检查摘要

- **总检查项**: $TOTAL_CHECKS
- **通过**: $PASSED_CHECKS
- **警告**: $WARNING_CHECKS
- **失败**: $FAILED_CHECKS
- **严重问题**: $CRITICAL_ISSUES

## 安全评分

EOF

# 计算安全分数
if [ $TOTAL_CHECKS -gt 0 ]; then
    SECURITY_SCORE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    echo "**安全分数**: $SECURITY_SCORE%" >> "$REPORT_FILE"

    if [ $CRITICAL_ISSUES -gt 0 ]; then
        echo "**风险等级**: 🔴 高风险" >> "$REPORT_FILE"
    elif [ $FAILED_CHECKS -gt 0 ]; then
        echo "**风险等级**: 🟡 中风险" >> "$REPORT_FILE"
    elif [ $WARNING_CHECKS -gt 0 ]; then
        echo "**风险等级**: 🟢 低风险" >> "$REPORT_FILE"
    else
        echo "**风险等级**: ✅ 安全" >> "$REPORT_FILE"
    fi
fi

cat >> "$REPORT_FILE" << EOF

## 建议措施

EOF

if [ $CRITICAL_ISSUES -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### 🚨 紧急修复项
- 立即修复所有严重安全问题
- 审查代码中的硬编码密钥
- 检查SQL注入和XSS漏洞
- 确保敏感文件不被提交到版本控制

EOF
fi

if [ $FAILED_CHECKS -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### ⚠️ 重要修复项
- 修复所有失败的安全检查项
- 更新有漏洞的依赖包
- 加强配置文件安全性
- 改进错误处理和日志记录

EOF
fi

if [ $WARNING_CHECKS -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### 📋 改进建议
- 关注所有警告项
- 定期更新依赖包
- 加强代码审查流程
- 建立安全监控机制

EOF
fi

cat >> "$REPORT_FILE" << EOF
## 下一步行动

1. **立即行动**: 修复所有严重和高危问题
2. **短期计划**: 解决中危问题和警告项
3. **长期规划**: 建立持续安全监控和改进机制
4. **定期检查**: 每周运行安全检查脚本

---
*此报告由 KidMemory 安全检查脚本自动生成*
EOF

security_check "安全报告生成" "PASS" "报告已保存到 $REPORT_FILE"

echo ""

# 总结
echo -e "${BLUE}📊 安全检查总结${NC}"
echo "========================================"
echo "总检查项: $TOTAL_CHECKS"
echo -e "通过: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "警告: ${YELLOW}$WARNING_CHECKS${NC}"
echo -e "失败: ${RED}$FAILED_CHECKS${NC}"
echo -e "严重问题: ${RED}$CRITICAL_ISSUES${NC}"

if [ $TOTAL_CHECKS -gt 0 ]; then
    SECURITY_SCORE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    echo "安全分数: $SECURITY_SCORE%"

    if [ $CRITICAL_ISSUES -gt 0 ]; then
        echo -e "风险等级: ${RED}🔴 高风险${NC}"
        echo -e "${RED}⚠️ 发现严重安全问题，需要立即修复！${NC}"
    elif [ $FAILED_CHECKS -gt 0 ]; then
        echo -e "风险等级: ${YELLOW}🟡 中风险${NC}"
        echo -e "${YELLOW}⚠️ 发现安全问题，建议尽快修复${NC}"
    elif [ $WARNING_CHECKS -gt 0 ]; then
        echo -e "风险等级: ${GREEN}🟢 低风险${NC}"
        echo -e "${YELLOW}💡 有改进空间，建议关注警告项${NC}"
    else
        echo -e "风险等级: ${GREEN}✅ 安全${NC}"
        echo -e "${GREEN}🎉 恭喜！未发现安全问题${NC}"
    fi
fi

echo ""
echo "详细报告已保存到: $REPORT_FILE"
echo "检查完成时间: $(date)"
echo "========================================"

# 退出码
if [ $CRITICAL_ISSUES -gt 0 ]; then
    exit 2  # 严重问题
elif [ $FAILED_CHECKS -gt 0 ]; then
    exit 1  # 一般问题
else
    exit 0  # 正常
fi
