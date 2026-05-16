#!/bin/bash

# KidMemory 1.0 项目状态仪表板
# 综合显示项目健康状态、进度和关键指标

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 清屏并显示标题
clear
echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${WHITE}║                          ${BLUE}KidMemory 1.0 项目仪表板${WHITE}                          ║${NC}"
echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}更新时间: $(date)${NC}"
echo -e "${CYAN}项目路径: $PROJECT_ROOT${NC}"
echo ""

# 辅助函数
print_section() {
    echo -e "${WHITE}┌─ $1 ─────────────────────────────────────────────────────────────────────┐${NC}"
}

print_section_end() {
    echo -e "${WHITE}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

print_status() {
    local status="$1"
    local text="$2"
    local details="$3"

    case $status in
        "OK")
            echo -e "  ${GREEN}✓${NC} $text ${CYAN}$details${NC}"
            ;;
        "WARN")
            echo -e "  ${YELLOW}⚠${NC} $text ${CYAN}$details${NC}"
            ;;
        "ERROR")
            echo -e "  ${RED}✗${NC} $text ${CYAN}$details${NC}"
            ;;
        "INFO")
            echo -e "  ${BLUE}ℹ${NC} $text ${CYAN}$details${NC}"
            ;;
    esac
}

get_file_count() {
    local pattern="$1"
    local dir="$2"
    find "$dir" -name "$pattern" 2>/dev/null | wc -l | tr -d ' '
}

get_line_count() {
    local pattern="$1"
    local dir="$2"
    find "$dir" -name "$pattern" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo "0"
}

# 1. 项目概览
print_section "📊 项目概览"

# Git 信息
if [ -d ".git" ]; then
    CURRENT_BRANCH=$(git branch --show-current)
    COMMIT_COUNT=$(git rev-list --count HEAD)
    LAST_COMMIT=$(git log -1 --format="%h - %s (%cr)")

    print_status "INFO" "当前分支" "$CURRENT_BRANCH"
    print_status "INFO" "提交数量" "$COMMIT_COUNT"
    print_status "INFO" "最新提交" "$LAST_COMMIT"
fi

print_section_end

# 2. 代码统计
print_section "📈 代码统计"

# 后端代码统计
if [ -d "packages/sidecar/src" ]; then
    TS_FILES=$(get_file_count "*.ts" "packages/sidecar/src")
    TS_LINES=$(get_line_count "*.ts" "packages/sidecar/src")
    print_status "INFO" "后端 TypeScript 文件" "$TS_FILES 个文件, $TS_LINES 行代码"
fi

# Flutter 代码统计
if [ -d "packages/desktop/lib" ]; then
    DART_FILES=$(get_file_count "*.dart" "packages/desktop/lib")
    DART_LINES=$(get_line_count "*.dart" "packages/desktop/lib")
    print_status "INFO" "Flutter Dart 文件" "$DART_FILES 个文件, $DART_LINES 行代码"
fi

# Web 前端代码统计
if [ -d "packages/web/src" ]; then
    TSX_FILES=$(get_file_count "*.tsx" "packages/web/src")
    TSX_LINES=$(get_line_count "*.tsx" "packages/web/src")
    print_status "INFO" "Web 前端文件" "$TSX_FILES 个文件, $TSX_LINES 行代码"
fi

# 测试文件统计
TEST_FILES=0
if [ -d "packages/sidecar/tests" ]; then
    TEST_FILES=$((TEST_FILES + $(get_file_count "*.test.ts" "packages/sidecar/tests")))
fi
if [ -d "packages/desktop/test" ]; then
    TEST_FILES=$((TEST_FILES + $(get_file_count "*.dart" "packages/desktop/test")))
fi

print_status "INFO" "测试文件" "$TEST_FILES 个"

print_section_end

# 3. 环境状态
print_section "🔧 开发环境状态"

# 检查必要工具
check_tool() {
    local tool="$1"
    local name="$2"

    if command -v "$tool" >/dev/null 2>&1; then
        local tool_info=$($tool --version 2>/dev/null | head -1 || echo "已安装")
        print_status "OK" "$name" "$tool_info"
    else
        print_status "ERROR" "$name" "未安装"
    fi
}

check_tool "node" "Node.js"
check_tool "npm" "npm"
check_tool "flutter" "Flutter"
check_tool "psql" "PostgreSQL"

# 检查数据库连接
if command -v psql >/dev/null 2>&1; then
    if psql -d postgres -c "SELECT 1;" >/dev/null 2>&1; then
        print_status "OK" "数据库连接" "正常"
    else
        print_status "ERROR" "数据库连接" "失败"
    fi
fi

print_section_end

# 4. 依赖状态
print_section "📦 依赖状态"

# 后端依赖
if [ -d "packages/sidecar" ]; then
    cd packages/sidecar

    if [ -d "node_modules" ]; then
        DEPS_COUNT=$(ls node_modules | wc -l | tr -d ' ')
        print_status "OK" "后端依赖" "$DEPS_COUNT 个包已安装"

        # 检查过时依赖
        OUTDATED_COUNT=$(npm outdated --json 2>/dev/null | jq 'length' 2>/dev/null || echo "0")
        if [ "$OUTDATED_COUNT" -gt 0 ]; then
            print_status "WARN" "后端过时依赖" "$OUTDATED_COUNT 个包需要更新"
        else
            print_status "OK" "后端依赖更新" "所有依赖都是最新的"
        fi
    else
        print_status "ERROR" "后端依赖" "未安装，请运行 npm install"
    fi

    cd "$PROJECT_ROOT"
fi

# Flutter 依赖
if [ -d "packages/desktop" ]; then
    cd packages/desktop

    if [ -f "pubspec.lock" ]; then
        FLUTTER_DEPS=$(grep -c "name:" pubspec.lock 2>/dev/null || echo "0")
        print_status "OK" "Flutter 依赖" "$FLUTTER_DEPS 个包已安装"
    else
        print_status "ERROR" "Flutter 依赖" "未安装，请运行 flutter pub get"
    fi

    cd "$PROJECT_ROOT"
fi

# Web 前端依赖
if [ -d "packages/web" ]; then
    cd packages/web

    if [ -d "node_modules" ]; then
        WEB_DEPS_COUNT=$(ls node_modules | wc -l | tr -d ' ')
        print_status "OK" "Web 前端依赖" "$WEB_DEPS_COUNT 个包已安装"
    else
        print_status "ERROR" "Web 前端依赖" "未安装，请运行 npm install"
    fi

    cd "$PROJECT_ROOT"
fi

print_section_end

# 5. 服务状态
print_section "🚀 服务状态"

# 检查后端服务
if curl -s http://localhost:3001/health >/dev/null 2>&1; then
    HEALTH_RESPONSE=$(curl -s http://localhost:3001/health | jq -r '.status' 2>/dev/null || echo "running")
    print_status "OK" "后端服务" "运行中 (http://localhost:3001) - $HEALTH_RESPONSE"
else
    print_status "WARN" "后端服务" "未运行 (http://localhost:3001)"
fi

# 检查 Web 前端服务
if curl -s http://localhost:5173 >/dev/null 2>&1; then
    print_status "OK" "Web 前端服务" "运行中 (http://localhost:5173)"
else
    print_status "WARN" "Web 前端服务" "未运行 (http://localhost:5173)"
fi

# 检查数据库服务
if command -v brew >/dev/null 2>&1; then
    if brew services list | grep postgresql | grep -q started; then
        print_status "OK" "PostgreSQL 服务" "运行中"
    else
        print_status "WARN" "PostgreSQL 服务" "未运行"
    fi
fi

print_section_end

# 6. 最近活动
print_section "📝 最近活动"

if [ -d ".git" ]; then
    # 最近的提交
    echo -e "  ${BLUE}最近提交:${NC}"
    git log --oneline -5 | sed 's/^/    /'
    echo ""

    # 工作区状态
    if git diff --quiet && git diff --cached --quiet; then
        print_status "OK" "工作区状态" "干净"
    else
        MODIFIED_FILES=$(git status --porcelain | wc -l | tr -d ' ')
        print_status "WARN" "工作区状态" "$MODIFIED_FILES 个文件有变更"
    fi
fi

print_section_end

# 7. 质量指标
print_section "📊 质量指标"

# 运行快速健康检查
HEALTH_SCORE=0
TOTAL_HEALTH_CHECKS=0

# 检查是否有 .gitignore
if [ -f ".gitignore" ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
fi
TOTAL_HEALTH_CHECKS=$((TOTAL_HEALTH_CHECKS + 1))

# 检查是否有 README
if [ -f "README.md" ] && [ -s "README.md" ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
fi
TOTAL_HEALTH_CHECKS=$((TOTAL_HEALTH_CHECKS + 1))

# 检查是否有测试
if [ $TEST_FILES -gt 0 ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
fi
TOTAL_HEALTH_CHECKS=$((TOTAL_HEALTH_CHECKS + 1))

# 计算健康分数
if [ $TOTAL_HEALTH_CHECKS -gt 0 ]; then
    HEALTH_PERCENTAGE=$(( (HEALTH_SCORE * 100) / TOTAL_HEALTH_CHECKS ))

    if [ $HEALTH_PERCENTAGE -ge 90 ]; then
        print_status "OK" "项目健康分数" "$HEALTH_PERCENTAGE% (优秀)"
    elif [ $HEALTH_PERCENTAGE -ge 70 ]; then
        print_status "OK" "项目健康分数" "$HEALTH_PERCENTAGE% (良好)"
    elif [ $HEALTH_PERCENTAGE -ge 50 ]; then
        print_status "WARN" "项目健康分数" "$HEALTH_PERCENTAGE% (一般)"
    else
        print_status "ERROR" "项目健康分数" "$HEALTH_PERCENTAGE% (需要改进)"
    fi
fi

# 检查最近的测试结果
if [ -d "test-results" ]; then
    LATEST_TEST=$(ls -t test-results/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_TEST" ]; then
        TEST_TIME=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$LATEST_TEST" 2>/dev/null || stat -c "%y" "$LATEST_TEST" 2>/dev/null | cut -d' ' -f1-2)
        print_status "INFO" "最近测试" "$TEST_TIME"
    fi
fi

print_section_end

# 8. 快速操作
print_section "⚡ 快速操作"

echo -e "  ${BLUE}可用命令:${NC}"
echo -e "    ${GREEN}./scripts/health-check.sh${NC}        - 运行完整健康检查"
echo -e "    ${GREEN}./scripts/security-check.sh${NC}      - 运行安全检查"
echo -e "    ${GREEN}./scripts/run-all-tests.sh${NC}       - 运行所有测试"
echo -e "    ${GREEN}./scripts/setup-dev-env.sh${NC}       - 设置开发环境"
echo ""
echo -e "  ${BLUE}开发服务:${NC}"
echo -e "    ${GREEN}cd packages/sidecar && npm run dev${NC}     - 启动后端服务"
echo -e "    ${GREEN}cd packages/web && npm run dev${NC}         - 启动 Web 前端"
echo -e "    ${GREEN}cd packages/desktop && flutter run${NC}     - 启动 Flutter 应用"

print_section_end

# 9. 系统资源
print_section "💻 系统资源"

# 磁盘使用情况
PROJECT_SIZE=$(du -sh . 2>/dev/null | cut -f1)
print_status "INFO" "项目大小" "$PROJECT_SIZE"

# 内存使用情况（macOS）
if command -v vm_stat >/dev/null 2>&1; then
    FREE_MEMORY=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    if [ -n "$FREE_MEMORY" ]; then
        FREE_MB=$(( FREE_MEMORY * 4096 / 1024 / 1024 ))
        print_status "INFO" "可用内存" "${FREE_MB}MB"
    fi
fi

# CPU 负载（macOS）
if command -v uptime >/dev/null 2>&1; then
    LOAD_AVG=$(uptime | awk -F'load averages:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    print_status "INFO" "系统负载" "$LOAD_AVG"
fi

print_section_end

# 10. 提醒和建议
print_section "💡 提醒和建议"

SUGGESTIONS=()

# 检查是否需要提交代码
if [ -d ".git" ]; then
    if ! git diff --quiet || ! git diff --cached --quiet; then
        SUGGESTIONS+=("有未提交的代码变更，建议及时提交")
    fi
fi

# 检查是否需要更新依赖
if [ -d "packages/sidecar" ] && [ "$OUTDATED_COUNT" -gt 5 ]; then
    SUGGESTIONS+=("后端有多个过时依赖，建议更新")
fi

# 检查是否需要运行测试
if [ -d "test-results" ]; then
    LATEST_TEST=$(ls -t test-results/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_TEST" ]; then
        TEST_AGE=$(( ($(date +%s) - $(stat -f "%m" "$LATEST_TEST" 2>/dev/null || stat -c "%Y" "$LATEST_TEST" 2>/dev/null)) / 86400 ))
        if [ $TEST_AGE -gt 1 ]; then
            SUGGESTIONS+=("最近测试超过1天，建议重新运行测试")
        fi
    fi
else
    SUGGESTIONS+=("尚未运行过测试，建议执行 ./scripts/run-all-tests.sh")
fi

# 显示建议
if [ ${#SUGGESTIONS[@]} -gt 0 ]; then
    for suggestion in "${SUGGESTIONS[@]}"; do
        print_status "WARN" "建议" "$suggestion"
    done
else
    print_status "OK" "状态" "一切正常，继续保持！"
fi

print_section_end

# 底部信息
echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${WHITE}║ 💡 提示: 使用 ${GREEN}watch -n 30 ./scripts/dashboard.sh${WHITE} 可以实时监控项目状态        ║${NC}"
echo -e "${WHITE}║ 🔄 刷新: 按 Ctrl+C 退出，重新运行脚本更新数据                              ║${NC}"
echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"

# 如果是交互模式，等待用户输入
if [ -t 0 ]; then
    echo ""
    echo -e "${CYAN}按任意键退出...${NC}"
    read -n 1 -s
fi
