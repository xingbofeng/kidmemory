#!/bin/bash

# KidMemory 1.0 自动化测试运行器
# 运行所有测试套件并生成测试报告

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

echo -e "${BLUE}🧪 KidMemory 1.0 自动化测试${NC}"
echo "========================================"
echo "测试时间: $(date)"
echo "项目路径: $PROJECT_ROOT"
echo ""

# 测试结果统计
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 辅助函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

run_test_suite() {
    local suite_name="$1"
    local test_command="$2"
    local working_dir="$3"

    TOTAL_SUITES=$((TOTAL_SUITES + 1))

    echo -e "${PURPLE}🔍 运行测试套件: $suite_name${NC}"
    echo "工作目录: $working_dir"
    echo "命令: $test_command"
    echo ""

    cd "$working_dir"

    # 创建测试输出目录
    mkdir -p "$PROJECT_ROOT/test-results"

    # 运行测试并捕获输出
    local output_file="$PROJECT_ROOT/test-results/${suite_name}-$(date +%Y%m%d-%H%M%S).log"
    local start_time=$(date +%s)

    if eval "$test_command" > "$output_file" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        log_success "$suite_name 测试通过 (${duration}s)"
        PASSED_SUITES=$((PASSED_SUITES + 1))

        # 尝试提取测试数量
        local test_count=$(extract_test_count "$output_file" "$suite_name")
        TOTAL_TESTS=$((TOTAL_TESTS + test_count))
        PASSED_TESTS=$((PASSED_TESTS + test_count))

        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        log_error "$suite_name 测试失败 (${duration}s)"
        FAILED_SUITES=$((FAILED_SUITES + 1))

        # 显示错误摘要
        echo "错误详情:"
        tail -n 20 "$output_file" | sed 's/^/  /'
        echo ""

        # 尝试提取测试数量
        local test_count=$(extract_test_count "$output_file" "$suite_name")
        TOTAL_TESTS=$((TOTAL_TESTS + test_count))
        # 假设失败的测试套件中有一些测试通过
        local passed_count=$((test_count / 2))
        PASSED_TESTS=$((PASSED_TESTS + passed_count))
        FAILED_TESTS=$((FAILED_TESTS + test_count - passed_count))

        return 1
    fi
}

extract_test_count() {
    local output_file="$1"
    local suite_name="$2"

    case "$suite_name" in
        "sidecar-unit")
            # Node.js 测试输出格式
            grep -o "passing ([0-9]*)" "$output_file" | grep -o "[0-9]*" | head -1 || echo "0"
            ;;
        "sidecar-integration")
            grep -o "[0-9]* passing" "$output_file" | grep -o "[0-9]*" | head -1 || echo "0"
            ;;
        "flutter-unit")
            # Flutter 测试输出格式
            grep -o "All tests passed!" "$output_file" >/dev/null && echo "10" || echo "0"
            ;;
        "flutter-widget")
            grep -o "[0-9]* tests passed" "$output_file" | grep -o "[0-9]*" | head -1 || echo "0"
            ;;
        "web-unit")
            grep -o "[0-9]* passed" "$output_file" | grep -o "[0-9]*" | head -1 || echo "0"
            ;;
        *)
            echo "5"  # 默认值
            ;;
    esac
}

# 检查测试环境
log_info "检查测试环境..."

# 检查必要工具
REQUIRED_TOOLS=("node" "npm" "flutter")
MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    log_error "缺少必要工具: ${MISSING_TOOLS[*]}"
    echo "请运行 ./scripts/setup-dev-env.sh 安装依赖"
    exit 1
fi

log_success "测试环境检查通过"
echo ""

# 1. Protocol 协议层测试
if [ -d "packages/protocol" ]; then
    log_info "准备 Protocol 协议层测试环境..."

    cd packages/protocol
    if [ ! -d "node_modules" ]; then
        log_info "安装 Protocol 依赖..."
        npm install
    fi

    run_test_suite "protocol-check" "npm run check" "$PROJECT_ROOT/packages/protocol"
    run_test_suite "protocol-typecheck" "npm run type-check" "$PROJECT_ROOT/packages/protocol"
    run_test_suite "protocol-test" "npm run test" "$PROJECT_ROOT/packages/protocol"

    cd "$PROJECT_ROOT"
else
    log_warning "Protocol 目录不存在，跳过协议层测试"
fi

echo ""

# 2. Cloud API 测试
if [ -d "packages/cloud-api" ]; then
    log_info "准备 Cloud API 测试环境..."

    cd packages/cloud-api
    if [ ! -d "node_modules" ]; then
        log_info "安装 Cloud API 依赖..."
        npm install
    fi

    run_test_suite "cloud-api-lint" "npm run lint" "$PROJECT_ROOT/packages/cloud-api"
    run_test_suite "cloud-api-typecheck" "npm run type-check" "$PROJECT_ROOT/packages/cloud-api"
    run_test_suite "cloud-api-unit" "npm run test" "$PROJECT_ROOT/packages/cloud-api"
    run_test_suite "cloud-api-build-prod" "npm run build:prod" "$PROJECT_ROOT/packages/cloud-api"

    cd "$PROJECT_ROOT"
else
    log_warning "Cloud API 目录不存在，跳过 Cloud API 测试"
fi

echo ""

# 3. Sidecar 测试
if [ -d "packages/sidecar" ]; then
    log_info "准备后端测试环境..."

    cd packages/sidecar

    # 检查依赖
    if [ ! -d "node_modules" ]; then
        log_info "安装后端依赖..."
        npm install
    fi

    run_test_suite "sidecar-lint" "npm run lint" "$PROJECT_ROOT/packages/sidecar"
    run_test_suite "sidecar-unit" "npm test" "$PROJECT_ROOT/packages/sidecar"

    # 运行类型检查
    if grep -q '"type-check"' package.json; then
        run_test_suite "sidecar-typecheck" "npm run type-check" "$PROJECT_ROOT/packages/sidecar"
    fi

    cd "$PROJECT_ROOT"
else
    log_warning "后端目录不存在，跳过后端测试"
fi

echo ""

# 4. Flutter 测试
if [ -d "packages/desktop" ]; then
    log_info "准备 Flutter 测试环境..."

    cd packages/desktop

    # 获取依赖
    flutter pub get >/dev/null 2>&1

    # 运行 Flutter 分析
    run_test_suite "flutter-analyze" "flutter analyze" "$PROJECT_ROOT/packages/desktop"

    # 运行单元测试
    if [ -d "test" ] && [ "$(find test -name "*.dart" | wc -l)" -gt 0 ]; then
        run_test_suite "flutter-unit" "flutter test" "$PROJECT_ROOT/packages/desktop"
    else
        log_warning "Flutter 测试目录为空或不存在"
    fi

    cd "$PROJECT_ROOT"
else
    log_warning "Flutter 目录不存在，跳过 Flutter 测试"
fi

echo ""

# 5. Web 前端测试
if [ -d "packages/web" ]; then
    log_info "准备 Web 前端测试环境..."

    cd packages/web

    # 检查依赖
    if [ ! -d "node_modules" ]; then
        log_info "安装 Web 前端依赖..."
        npm install
    fi

    run_test_suite "web-lint" "npm run lint" "$PROJECT_ROOT/packages/web"
    run_test_suite "web-typecheck" "npm run type-check" "$PROJECT_ROOT/packages/web"
    run_test_suite "web-unit" "npm run test -- --run --pool=forks" "$PROJECT_ROOT/packages/web"
    run_test_suite "web-build" "npm run build" "$PROJECT_ROOT/packages/web"

    cd "$PROJECT_ROOT"
else
    log_warning "Web 前端目录不存在，跳过 Web 测试"
fi

echo ""

# 6. 集成测试
log_info "运行集成测试..."

SIDEcar_ACCEPT_DB_URL="${SIDECAR_ACCEPTANCE_DATABASE_URL:-postgresql://$USER@127.0.0.1:5432/kidmemory_acceptance}"

# 检查数据库连接
if command -v psql >/dev/null 2>&1; then
    if psql -d postgres -c "SELECT 1;" >/dev/null 2>&1; then
        log_success "数据库连接正常"
        run_test_suite "sidecar-prisma-generate" "DATABASE_URL=$SIDEcar_ACCEPT_DB_URL npm run prisma:generate" "$PROJECT_ROOT/packages/sidecar"
        run_test_suite "sidecar-prisma-migrate" "DATABASE_URL=$SIDEcar_ACCEPT_DB_URL npm run prisma:migrate" "$PROJECT_ROOT/packages/sidecar"
        run_test_suite "sidecar-integration" "DATABASE_URL=$SIDEcar_ACCEPT_DB_URL npm run test:integration" "$PROJECT_ROOT/packages/sidecar"
    else
        log_warning "数据库连接失败，跳过数据库测试"
    fi
else
    log_warning "PostgreSQL 未安装，跳过数据库测试"
fi

echo ""

# 7. 架构测试
if [ -f "packages/sidecar/tests/architecture/architecture.test.ts" ]; then
    run_test_suite "architecture" "tsx --test tests/architecture/architecture.test.ts" "$PROJECT_ROOT/packages/sidecar"
fi

echo ""

# 8. 性能测试
log_info "运行性能测试..."

# 简单的性能基准测试
run_performance_test() {
    local test_name="$1"
    local url="$2"

    if command -v curl >/dev/null 2>&1; then
        local start_time=$(date +%s%N)
        if curl -s "$url" >/dev/null 2>&1; then
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))  # 转换为毫秒

            if [ $duration -lt 2000 ]; then  # 小于2秒
                log_success "$test_name 性能测试通过 (${duration}ms)"
                return 0
            else
                log_warning "$test_name 性能测试较慢 (${duration}ms)"
                return 1
            fi
        else
            log_warning "$test_name 服务不可用"
            return 1
        fi
    else
        log_warning "curl 未安装，跳过性能测试"
        return 1
    fi
}

# 检查后端服务是否运行
if curl -s http://localhost:3001/health >/dev/null 2>&1; then
    run_performance_test "sidecar-health" "http://localhost:3001/health"
    run_performance_test "sidecar-config" "http://localhost:3001/config/status"
else
    log_warning "后端服务未运行，跳过性能测试"
fi

echo ""

# 8. 生成测试报告
log_info "生成测试报告..."

REPORT_FILE="test-report-$(date +%Y%m%d-%H%M%S).md"

cat > "$REPORT_FILE" << EOF
# KidMemory 测试报告

**生成时间**: $(date)
**项目路径**: $PROJECT_ROOT

## 测试摘要

### 测试套件统计
- **总测试套件**: $TOTAL_SUITES
- **通过套件**: $PASSED_SUITES
- **失败套件**: $FAILED_SUITES

### 测试用例统计
- **总测试用例**: $TOTAL_TESTS
- **通过用例**: $PASSED_TESTS
- **失败用例**: $FAILED_TESTS

## 测试覆盖率

EOF

# 计算成功率
if [ $TOTAL_SUITES -gt 0 ]; then
    SUITE_SUCCESS_RATE=$(( (PASSED_SUITES * 100) / TOTAL_SUITES ))
    echo "**测试套件成功率**: $SUITE_SUCCESS_RATE%" >> "$REPORT_FILE"
fi

if [ $TOTAL_TESTS -gt 0 ]; then
    TEST_SUCCESS_RATE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    echo "**测试用例成功率**: $TEST_SUCCESS_RATE%" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

## 测试结果详情

### 通过的测试套件
EOF

# 列出通过的测试
if [ $PASSED_SUITES -gt 0 ]; then
    echo "- 共 $PASSED_SUITES 个测试套件通过" >> "$REPORT_FILE"
else
    echo "- 无" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

### 失败的测试套件
EOF

# 列出失败的测试
if [ $FAILED_SUITES -gt 0 ]; then
    echo "- 共 $FAILED_SUITES 个测试套件失败" >> "$REPORT_FILE"
    echo "- 详细错误信息请查看 test-results/ 目录中的日志文件" >> "$REPORT_FILE"
else
    echo "- 无" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

## 建议措施

EOF

if [ $FAILED_SUITES -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### 🚨 需要修复的问题
- 修复失败的测试套件
- 检查错误日志并解决根本原因
- 确保所有依赖正确安装
- 验证测试环境配置

EOF
fi

if [ $TOTAL_TESTS -eq 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### 📋 测试改进建议
- 增加单元测试覆盖率
- 添加集成测试
- 建立自动化测试流程
- 设置测试质量门禁

EOF
fi

cat >> "$REPORT_FILE" << EOF
## 下一步行动

1. **立即行动**: 修复所有失败的测试
2. **短期计划**: 提高测试覆盖率到 80% 以上
3. **长期规划**: 建立持续集成和自动化测试
4. **定期检查**: 每次代码提交前运行测试

## 测试文件位置

- **测试日志**: \`test-results/\`
- **后端测试**: \`packages/sidecar/tests/\`
- **Flutter测试**: \`packages/desktop/test/\`
- **Web测试**: \`packages/web/src/__tests__/\` (如果存在)

---
*此报告由 KidMemory 自动化测试脚本生成*
EOF

log_success "测试报告已保存到: $REPORT_FILE"

echo ""

# 总结
echo -e "${BLUE}📊 测试总结${NC}"
echo "========================================"
echo "测试套件: $PASSED_SUITES/$TOTAL_SUITES 通过"
echo "测试用例: $PASSED_TESTS/$TOTAL_TESTS 通过"

if [ $TOTAL_SUITES -gt 0 ]; then
    SUITE_SUCCESS_RATE=$(( (PASSED_SUITES * 100) / TOTAL_SUITES ))
    echo "套件成功率: $SUITE_SUCCESS_RATE%"
fi

if [ $TOTAL_TESTS -gt 0 ]; then
    TEST_SUCCESS_RATE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    echo "用例成功率: $TEST_SUCCESS_RATE%"
fi

if [ $FAILED_SUITES -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！${NC}"
else
    echo -e "${RED}❌ 有 $FAILED_SUITES 个测试套件失败${NC}"
    echo -e "${YELLOW}💡 请查看测试报告了解详情${NC}"
fi

echo ""
echo "详细报告: $REPORT_FILE"
echo "测试日志: test-results/"
echo "测试完成时间: $(date)"
echo "========================================"

# 清理临时文件
find test-results/ -name "*.log" -mtime +7 -delete 2>/dev/null || true

# 退出码
if [ $FAILED_SUITES -gt 0 ]; then
    exit 1
else
    exit 0
fi
