#!/bin/bash

# KidMemory 1.0 发布前检查脚本
# 自动化执行发布前的所有必要检查

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

echo -e "${BLUE}🚀 KidMemory 1.0 发布前检查${NC}"
echo "========================================"
echo "检查时间: $(date)"
echo "项目路径: $PROJECT_ROOT"
echo ""

# 检查结果统计
TOTAL_CATEGORIES=0
PASSED_CATEGORIES=0
FAILED_CATEGORIES=0
WARNING_CATEGORIES=0
CRITICAL_ISSUES=0

# 辅助函数
log_category() {
    echo -e "${PURPLE}📋 $1${NC}"
    echo "----------------------------------------"
}

check_result() {
    local category="$1"
    local status="$2"
    local message="$3"
    local is_critical="$4"

    TOTAL_CATEGORIES=$((TOTAL_CATEGORIES + 1))

    case $status in
        "PASS")
            echo -e "✅ ${GREEN}PASS${NC} $category"
            PASSED_CATEGORIES=$((PASSED_CATEGORIES + 1))
            ;;
        "WARN")
            echo -e "⚠️  ${YELLOW}WARN${NC} $category - $message"
            WARNING_CATEGORIES=$((WARNING_CATEGORIES + 1))
            ;;
        "FAIL")
            echo -e "❌ ${RED}FAIL${NC} $category - $message"
            FAILED_CATEGORIES=$((FAILED_CATEGORIES + 1))
            if [ "$is_critical" = "true" ]; then
                CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            fi
            ;;
    esac
}

# 1. 代码质量检查
log_category "代码质量检查"

# Flutter 分析
if [ -d "packages/desktop" ]; then
    cd packages/desktop
    if flutter analyze >/dev/null 2>&1; then
        check_result "Flutter代码分析" "PASS"
    else
        check_result "Flutter代码分析" "FAIL" "存在代码分析问题" "true"
    fi
    cd "$PROJECT_ROOT"
fi

# 后端代码检查
if [ -d "packages/sidecar" ]; then
    cd packages/sidecar
    if [ -d "node_modules" ]; then
        if npm run lint >/dev/null 2>&1 && npm run type-check >/dev/null 2>&1; then
            check_result "后端代码检查" "PASS"
        else
            check_result "后端代码检查" "FAIL" "后端代码检查失败" "true"
        fi
    else
        check_result "后端依赖安装" "FAIL" "后端依赖未安装" "true"
    fi
    cd "$PROJECT_ROOT"
fi

# Protocol 代码检查
if [ -d "packages/protocol" ]; then
    cd packages/protocol
    if [ -d "node_modules" ]; then
        if npm run check >/dev/null 2>&1 && npm run type-check >/dev/null 2>&1 && npm run build >/dev/null 2>&1; then
            check_result "Protocol代码检查" "PASS"
        else
            check_result "Protocol代码检查" "FAIL" "Protocol检查失败" "true"
        fi
    else
        check_result "Protocol依赖安装" "FAIL" "Protocol依赖未安装" "true"
    fi
    cd "$PROJECT_ROOT"
fi

# Cloud API 代码检查
if [ -d "packages/cloud-api" ]; then
    cd packages/cloud-api
    if [ -d "node_modules" ]; then
        if npm run lint >/dev/null 2>&1 && npm run type-check >/dev/null 2>&1; then
            check_result "Cloud API代码检查" "PASS"
        else
            check_result "Cloud API代码检查" "FAIL" "Cloud API检查失败" "true"
        fi
    else
        check_result "Cloud API依赖安装" "FAIL" "Cloud API依赖未安装" "true"
    fi
    cd "$PROJECT_ROOT"
fi

# Web 前端构建检查
if [ -d "packages/web" ]; then
    cd packages/web
    if [ -d "node_modules" ]; then
        if npm run build >/dev/null 2>&1; then
            check_result "Web前端构建" "PASS"
        else
            check_result "Web前端构建" "FAIL" "Web前端构建失败" "true"
        fi
    else
        check_result "Web前端依赖安装" "FAIL" "Web前端依赖未安装" "true"
    fi
    cd "$PROJECT_ROOT"
fi

echo ""

# 3. 测试覆盖率检查
log_category "测试覆盖率检查"

# 检查测试文件存在性
TEST_FILES_COUNT=0

if [ -d "packages/sidecar/tests" ]; then
    BACKEND_TESTS=$(find packages/sidecar/tests -name "*.test.ts" | wc -l)
    TEST_FILES_COUNT=$((TEST_FILES_COUNT + BACKEND_TESTS))
fi

if [ -d "packages/desktop/test" ]; then
    FLUTTER_TESTS=$(find packages/desktop/test -name "*.dart" | wc -l)
    TEST_FILES_COUNT=$((TEST_FILES_COUNT + FLUTTER_TESTS))
fi

echo "总测试文件数: $TEST_FILES_COUNT"

if [ $TEST_FILES_COUNT -gt 10 ]; then
    check_result "测试文件数量" "PASS"
else
    check_result "测试文件数量" "FAIL" "测试文件数量不足" "false"
fi

# 运行测试
if [ -f "scripts/run-all-tests.sh" ]; then
    echo "运行自动化测试..."
    if bash scripts/run-all-tests.sh >/dev/null 2>&1; then
        check_result "自动化测试" "PASS"
    else
        check_result "自动化测试" "FAIL" "部分测试失败" "true"
    fi
else
    check_result "测试脚本存在" "FAIL" "测试脚本不存在" "false"
fi

echo ""

# 4. 安全检查
log_category "安全检查"

# 运行安全检查脚本
if [ -f "scripts/security-check.sh" ]; then
    echo "运行安全检查..."
    SECURITY_EXIT_CODE=0
    bash scripts/security-check.sh >/dev/null 2>&1 || SECURITY_EXIT_CODE=$?

    case $SECURITY_EXIT_CODE in
        0)
            check_result "安全检查" "PASS"
            ;;
        1)
            check_result "安全检查" "WARN" "发现待处理安全项（非阻塞）" "false"
            ;;
        2)
            check_result "安全检查" "FAIL" "发现严重安全问题" "true"
            ;;
    esac
else
    check_result "安全检查脚本" "FAIL" "安全检查脚本不存在" "false"
fi

echo ""

# 5. 文档完整性检查
log_category "文档完整性检查"

REQUIRED_DOCS=(
    "README.md"
    "CLAUDE.md"
    "docs/product/architecture.md"
    "docs/product/roadmap.md"
)

MISSING_DOCS=0
for doc in "${REQUIRED_DOCS[@]}"; do
    if [ ! -f "$doc" ] || [ ! -s "$doc" ]; then
        MISSING_DOCS=$((MISSING_DOCS + 1))
        echo "缺少文档: $doc"
    fi
done

if [ $MISSING_DOCS -eq 0 ]; then
    check_result "必要文档" "PASS"
else
    check_result "必要文档" "FAIL" "缺少 $MISSING_DOCS 个必要文档" "false"
fi

echo ""

# 6. 环境配置检查
log_category "环境配置检查"

# 检查环境变量示例文件
if [ -f ".env.example" ]; then
    check_result "环境变量示例" "PASS"
else
    check_result "环境变量示例" "FAIL" ".env.example 文件不存在" "false"
fi

# 检查 .gitignore
if [ -f ".gitignore" ]; then
    if grep -q "\.env" .gitignore && grep -q "node_modules" .gitignore; then
        check_result "Git忽略配置" "PASS"
    else
        check_result "Git忽略配置" "FAIL" ".gitignore 配置不完整" "false"
    fi
else
    check_result "Git忽略文件" "FAIL" ".gitignore 文件不存在" "true"
fi

echo ""

# 7. 依赖和漏洞检查
log_category "依赖和漏洞检查"

# 后端依赖漏洞检查
if [ -d "packages/sidecar/node_modules" ]; then
    cd packages/sidecar
    if npm audit --omit=dev --audit-level=high >/dev/null 2>&1; then
        check_result "后端依赖安全" "PASS"
    else
        check_result "后端依赖安全" "WARN" "发现高危依赖漏洞（建议在发布前修复）" "false"
    fi
    cd "$PROJECT_ROOT"
fi

# Web 前端依赖漏洞检查
if [ -d "packages/web/node_modules" ]; then
    cd packages/web
    if npm audit --omit=dev --audit-level=high >/dev/null 2>&1; then
        check_result "Web前端依赖安全" "PASS"
    else
        check_result "Web前端依赖安全" "WARN" "发现高危依赖漏洞（建议在发布前修复）" "false"
    fi
    cd "$PROJECT_ROOT"
fi

echo ""

# 8. 构建和打包检查
log_category "构建和打包检查"

# 检查构建脚本
BUILD_SCRIPTS_EXIST=false
if [ -f "scripts/build-macos-app.sh" ] || [ -f "packages/desktop/macos/Scripts/bundle-sidecar-for-release.sh" ]; then
    BUILD_SCRIPTS_EXIST=true
fi

if [ $BUILD_SCRIPTS_EXIST = true ]; then
    check_result "构建脚本" "PASS"
else
    check_result "构建脚本" "WARN" "缺少统一构建入口脚本（可用 Flutter 命令替代）" "false"
fi

echo ""

# 9. Git 状态检查
log_category "Git状态检查"

if [ -d ".git" ]; then
    # 检查是否有未提交的更改
    if git diff --quiet && git diff --cached --quiet; then
        check_result "工作区状态" "PASS"
    else
        check_result "工作区状态" "WARN" "有未提交的更改" "false"
    fi

    # 检查是否有未推送的提交
    if git status | grep -q "Your branch is ahead"; then
        check_result "推送状态" "WARN" "有未推送的提交" "false"
    else
        check_result "推送状态" "PASS"
    fi

    # 检查当前分支
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
        check_result "发布分支" "PASS"
    else
        check_result "发布分支" "WARN" "不在主分支上 ($CURRENT_BRANCH)" "false"
    fi
else
    check_result "Git仓库" "FAIL" "不是Git仓库" "true"
fi

echo ""

# 10. 性能基准检查
log_category "性能基准检查"

# 检查项目大小
PROJECT_SIZE_KB=$(du -sk . | cut -f1)
PROJECT_SIZE_MB=$((PROJECT_SIZE_KB / 1024))

echo "项目大小: ${PROJECT_SIZE_MB}MB"

if [ $PROJECT_SIZE_MB -lt 500 ]; then
    check_result "项目大小" "PASS"
else
    check_result "项目大小" "WARN" "项目过大 (${PROJECT_SIZE_MB}MB)" "false"
fi

# 检查 node_modules 大小
NODE_MODULES_SIZE=0
if [ -d "packages/sidecar/node_modules" ]; then
    BACKEND_NM_SIZE=$(du -sk packages/sidecar/node_modules | cut -f1)
    NODE_MODULES_SIZE=$((NODE_MODULES_SIZE + BACKEND_NM_SIZE))
fi

if [ -d "packages/web/node_modules" ]; then
    WEB_NM_SIZE=$(du -sk packages/web/node_modules | cut -f1)
    NODE_MODULES_SIZE=$((NODE_MODULES_SIZE + WEB_NM_SIZE))
fi

NODE_MODULES_SIZE_MB=$((NODE_MODULES_SIZE / 1024))
echo "依赖大小: ${NODE_MODULES_SIZE_MB}MB"

if [ $NODE_MODULES_SIZE_MB -lt 1000 ]; then
    check_result "依赖大小" "PASS"
else
    check_result "依赖大小" "WARN" "依赖过大 (${NODE_MODULES_SIZE_MB}MB)" "false"
fi

echo ""

# 生成发布前检查报告
REPORT_FILE="pre-release-check-$(date +%Y%m%d-%H%M%S).md"

cat > "$REPORT_FILE" << EOF
# KidMemory 发布前检查报告

**生成时间**: $(date)
**项目路径**: $PROJECT_ROOT

## 检查摘要

- **总检查类别**: $TOTAL_CATEGORIES
- **通过类别**: $PASSED_CATEGORIES
- **警告类别**: $WARNING_CATEGORIES
- **失败类别**: $FAILED_CATEGORIES
- **严重问题**: $CRITICAL_ISSUES

## 发布就绪状态

EOF

# 计算就绪分数
if [ $TOTAL_CATEGORIES -gt 0 ]; then
    EFFECTIVE_PASSED=$((PASSED_CATEGORIES + WARNING_CATEGORIES))
    READINESS_SCORE=$(( (EFFECTIVE_PASSED * 100) / TOTAL_CATEGORIES ))
    echo "**就绪分数**: $READINESS_SCORE%" >> "$REPORT_FILE"

    if [ $CRITICAL_ISSUES -eq 0 ] && [ $FAILED_CATEGORIES -eq 0 ] && [ $READINESS_SCORE -ge 90 ]; then
        echo "**发布状态**: ✅ 可以发布" >> "$REPORT_FILE"
        RELEASE_READY=true
    elif [ $CRITICAL_ISSUES -eq 0 ] && [ $FAILED_CATEGORIES -le 2 ] && [ $READINESS_SCORE -ge 80 ]; then
        echo "**发布状态**: ⚠️ 基本就绪，建议修复警告项" >> "$REPORT_FILE"
        RELEASE_READY=false
    else
        echo "**发布状态**: ❌ 不建议发布，需要修复问题" >> "$REPORT_FILE"
        RELEASE_READY=false
    fi
fi

cat >> "$REPORT_FILE" << EOF

## Git 信息

- **Git分支**: $(git branch --show-current 2>/dev/null || echo "未知")
- **Git提交**: $(git rev-parse --short HEAD 2>/dev/null || echo "未知")

## 下一步行动

EOF

if [ $CRITICAL_ISSUES -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### 🚨 必须修复的严重问题
- 立即修复所有标记为严重的问题
- 重新运行检查确保问题已解决
- 严重问题修复前不建议发布

EOF
fi

if [ $FAILED_CATEGORIES -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### ⚠️ 建议修复的问题
- 修复失败的检查项
- 提高代码质量和测试覆盖率
- 完善文档和配置

EOF
fi

if [ "$RELEASE_READY" = true ]; then
    cat >> "$REPORT_FILE" << EOF
### 🚀 发布准备
- 所有检查通过，可以开始发布流程
- 建议执行最终的手动测试
- 准备发布说明和用户文档
- 通知相关团队准备发布

EOF
fi

cat >> "$REPORT_FILE" << EOF
---
*此报告由 KidMemory 发布前检查脚本自动生成*
EOF

echo ""

# 总结
echo -e "${BLUE}📊 发布前检查总结${NC}"
echo "========================================"
echo "检查类别: $PASSED_CATEGORIES/$TOTAL_CATEGORIES 通过"
echo "警告类别: $WARNING_CATEGORIES 个"
echo "失败类别: $FAILED_CATEGORIES 个"
echo "严重问题: $CRITICAL_ISSUES 个"

if [ $TOTAL_CATEGORIES -gt 0 ]; then
    EFFECTIVE_PASSED=$((PASSED_CATEGORIES + WARNING_CATEGORIES))
    READINESS_SCORE=$(( (EFFECTIVE_PASSED * 100) / TOTAL_CATEGORIES ))
    echo "就绪分数: $READINESS_SCORE%"
fi

if [ $CRITICAL_ISSUES -eq 0 ] && [ $FAILED_CATEGORIES -eq 0 ] && [ $READINESS_SCORE -ge 90 ]; then
    echo -e "${GREEN}🎉 发布检查通过，可以发布！${NC}"
    echo -e "${GREEN}✅ 建议继续执行发布流程${NC}"
elif [ $CRITICAL_ISSUES -eq 0 ] && [ $FAILED_CATEGORIES -le 2 ] && [ $READINESS_SCORE -ge 80 ]; then
    echo -e "${YELLOW}⚠️ 基本就绪，建议修复警告项后发布${NC}"
    echo -e "${YELLOW}💡 可以发布，但建议先解决非严重问题${NC}"
else
    echo -e "${RED}❌ 发现严重问题，不建议发布${NC}"
    echo -e "${RED}🔧 请修复所有问题后重新检查${NC}"
fi

echo ""
echo "详细报告: $REPORT_FILE"
echo "检查完成时间: $(date)"
echo "========================================"

# 退出码
if [ $CRITICAL_ISSUES -gt 0 ]; then
    exit 2  # 严重问题，不能发布
elif [ $FAILED_CATEGORIES -gt 2 ] || [ $READINESS_SCORE -lt 80 ]; then
    exit 1  # 问题较多，不建议发布
else
    exit 0  # 可以发布
fi
