#!/bin/bash

# KidMemory 1.0 项目健康检查脚本
# 用于监控项目开发进度和质量指标

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}🔍 KidMemory 1.0 项目健康检查${NC}"
echo "========================================"
echo "检查时间: $(date)"
echo "项目路径: $PROJECT_ROOT"
echo ""

# 检查结果统计
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# 辅助函数
check_status() {
    local name="$1"
    local status="$2"
    local message="$3"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    case $status in
        "PASS")
            echo -e "✅ ${GREEN}PASS${NC} $name"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            ;;
        "FAIL")
            echo -e "❌ ${RED}FAIL${NC} $name - $message"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            ;;
        "WARN")
            echo -e "⚠️  ${YELLOW}WARN${NC} $name - $message"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            ;;
    esac
}

# 1. 代码库结构检查
echo -e "${BLUE}📁 代码库结构检查${NC}"
echo "----------------------------------------"

# 检查关键目录
for dir in "packages/backend" "packages/desktop" "packages/web" "docs" "scripts"; do
    if [ -d "$dir" ]; then
        check_status "目录存在: $dir" "PASS"
    else
        check_status "目录存在: $dir" "FAIL" "目录不存在"
    fi
done

# 检查关键文件
for file in "README.md" "CLAUDE.md" ".env.example"; do
    if [ -f "$file" ]; then
        check_status "文件存在: $file" "PASS"
    else
        check_status "文件存在: $file" "FAIL" "文件不存在"
    fi
done

echo ""

# 2. 依赖检查
echo -e "${BLUE}📦 依赖检查${NC}"
echo "----------------------------------------"

# 检查 Node.js
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    check_status "Node.js 已安装" "PASS" "$NODE_VERSION"
else
    check_status "Node.js 已安装" "FAIL" "未安装 Node.js"
fi

# 检查 Flutter
if command -v flutter >/dev/null 2>&1; then
    FLUTTER_VERSION=$(flutter --version | head -n1)
    check_status "Flutter 已安装" "PASS" "$FLUTTER_VERSION"
else
    check_status "Flutter 已安装" "FAIL" "未安装 Flutter"
fi

# 检查 PostgreSQL
if command -v psql >/dev/null 2>&1; then
    POSTGRES_VERSION=$(psql --version)
    check_status "PostgreSQL 已安装" "PASS" "$POSTGRES_VERSION"
else
    check_status "PostgreSQL 已安装" "WARN" "未安装 PostgreSQL"
fi

echo ""

# 4. 代码质量检查
echo -e "${BLUE}🔍 代码质量检查${NC}"
echo "----------------------------------------"

# 后端代码检查
if [ -d "packages/backend" ]; then
    cd packages/backend

    # 检查 package.json
    if [ -f "package.json" ]; then
        check_status "后端 package.json" "PASS"
    else
        check_status "后端 package.json" "FAIL" "文件不存在"
    fi

    # 检查 TypeScript 配置
    if [ -f "tsconfig.json" ]; then
        check_status "后端 TypeScript 配置" "PASS"
    else
        check_status "后端 TypeScript 配置" "WARN" "tsconfig.json 不存在"
    fi

    # 检查依赖安装
    if [ -d "node_modules" ]; then
        check_status "后端依赖安装" "PASS"
    else
        check_status "后端依赖安装" "WARN" "需要运行 npm install"
    fi

    cd "$PROJECT_ROOT"
fi

# Flutter 代码检查
if [ -d "packages/desktop" ]; then
    cd packages/desktop

    # 检查 pubspec.yaml
    if [ -f "pubspec.yaml" ]; then
        check_status "桌面端 pubspec.yaml" "PASS"
    else
        check_status "桌面端 pubspec.yaml" "FAIL" "文件不存在"
    fi

    # 检查依赖
    if [ -f "pubspec.lock" ]; then
        check_status "桌面端依赖锁定" "PASS"
    else
        check_status "桌面端依赖锁定" "WARN" "需要运行 flutter pub get"
    fi

    cd "$PROJECT_ROOT"
fi

# Web 前端检查
if [ -d "packages/web" ]; then
    cd packages/web

    # 检查 package.json
    if [ -f "package.json" ]; then
        check_status "Web端 package.json" "PASS"
    else
        check_status "Web端 package.json" "FAIL" "文件不存在"
    fi

    # 检查依赖安装
    if [ -d "node_modules" ]; then
        check_status "Web端依赖安装" "PASS"
    else
        check_status "Web端依赖安装" "WARN" "需要运行 npm install"
    fi

    cd "$PROJECT_ROOT"
fi

echo ""

# 5. 测试覆盖率检查
echo -e "${BLUE}🧪 测试覆盖率检查${NC}"
echo "----------------------------------------"

# 后端测试
if [ -d "packages/backend" ]; then
    cd packages/backend

    if [ -f "package.json" ] && grep -q '"test"' package.json; then
        check_status "后端测试脚本配置" "PASS"

        # 尝试运行测试（如果依赖已安装）
        if [ -d "node_modules" ]; then
            echo "正在运行后端测试..."
            if npm test >/dev/null 2>&1; then
                check_status "后端测试执行" "PASS"
            else
                check_status "后端测试执行" "WARN" "测试失败或未配置"
            fi
        fi
    else
        check_status "后端测试脚本配置" "WARN" "未配置测试脚本"
    fi

    cd "$PROJECT_ROOT"
fi

# Flutter 测试
if [ -d "packages/desktop" ]; then
    cd packages/desktop

    if [ -d "test" ]; then
        TEST_COUNT=$(find test -name "*.dart" | wc -l)
        if [ "$TEST_COUNT" -gt 0 ]; then
            check_status "桌面端测试文件" "PASS" "$TEST_COUNT 个测试文件"
        else
            check_status "桌面端测试文件" "WARN" "测试目录为空"
        fi
    else
        check_status "桌面端测试目录" "WARN" "测试目录不存在"
    fi

    cd "$PROJECT_ROOT"
fi

echo ""

# 6. 安全检查
echo -e "${BLUE}🔒 安全检查${NC}"
echo "----------------------------------------"

# 检查敏感文件
SENSITIVE_FILES=(".env" "*.key" "*.pem" "*.p12" "config/secrets.json")
FOUND_SENSITIVE=false

for pattern in "${SENSITIVE_FILES[@]}"; do
    if find . -name "$pattern" -not -path "./node_modules/*" -not -path "./.git/*" | grep -q .; then
        FOUND_SENSITIVE=true
        break
    fi
done

if [ "$FOUND_SENSITIVE" = true ]; then
    check_status "敏感文件检查" "WARN" "发现敏感文件，请确保已加入 .gitignore"
else
    check_status "敏感文件检查" "PASS"
fi

# 检查 .gitignore
if [ -f ".gitignore" ]; then
    if grep -q "\.env" .gitignore && grep -q "node_modules" .gitignore; then
        check_status ".gitignore 配置" "PASS"
    else
        check_status ".gitignore 配置" "WARN" "可能缺少重要的忽略规则"
    fi
else
    check_status ".gitignore 文件" "FAIL" "文件不存在"
fi

echo ""

# 7. 文档完整性检查
echo -e "${BLUE}📚 文档完整性检查${NC}"
echo "----------------------------------------"

# 检查必要文档
REQUIRED_DOCS=("README.md" "CLAUDE.md" "docs/product/architecture.md")

for doc in "${REQUIRED_DOCS[@]}"; do
    if [ -f "$doc" ]; then
        # 检查文档是否为空
        if [ -s "$doc" ]; then
            check_status "文档: $doc" "PASS"
        else
            check_status "文档: $doc" "WARN" "文档为空"
        fi
    else
        check_status "文档: $doc" "FAIL" "文档不存在"
    fi
done

# 检查 API 文档
if [ -d "docs/api" ]; then
    check_status "API 文档目录" "PASS"
else
    check_status "API 文档目录" "WARN" "API 文档目录不存在"
fi

echo ""

# 8. Git 状态检查
echo -e "${BLUE}📝 Git 状态检查${NC}"
echo "----------------------------------------"

if [ -d ".git" ]; then
    check_status "Git 仓库初始化" "PASS"

    # 检查是否有未提交的更改
    if git diff --quiet && git diff --cached --quiet; then
        check_status "工作区状态" "PASS" "工作区干净"
    else
        check_status "工作区状态" "WARN" "有未提交的更改"
    fi

    # 检查当前分支
    CURRENT_BRANCH=$(git branch --show-current)
    check_status "当前分支" "PASS" "$CURRENT_BRANCH"

    # 检查远程仓库
    if git remote -v | grep -q "origin"; then
        check_status "远程仓库配置" "PASS"
    else
        check_status "远程仓库配置" "WARN" "未配置远程仓库"
    fi
else
    check_status "Git 仓库" "FAIL" "不是 Git 仓库"
fi

echo ""

# 9. 环境配置检查
echo -e "${BLUE}⚙️ 环境配置检查${NC}"
echo "----------------------------------------"

# 检查环境变量文件
if [ -f ".env.example" ]; then
    check_status ".env.example 文件" "PASS"

    # 检查是否有对应的 .env 文件
    if [ -f ".env" ]; then
        check_status "环境配置文件" "PASS"
    else
        check_status "环境配置文件" "WARN" "需要创建 .env 文件"
    fi
else
    check_status ".env.example 文件" "WARN" "环境变量示例文件不存在"
fi

# 检查数据库配置
if [ -f "packages/backend/.env" ] || [ -f "packages/backend/.env.example" ]; then
    check_status "后端环境配置" "PASS"
else
    check_status "后端环境配置" "WARN" "后端环境配置文件不存在"
fi

echo ""

# 10. 构建检查
echo -e "${BLUE}🔨 构建检查${NC}"
echo "----------------------------------------"

# 后端构建检查
if [ -d "packages/backend" ]; then
    cd packages/backend

    if [ -f "package.json" ] && grep -q '"build"' package.json; then
        check_status "后端构建脚本" "PASS"
    else
        check_status "后端构建脚本" "WARN" "未配置构建脚本"
    fi

    cd "$PROJECT_ROOT"
fi

# Web 构建检查
if [ -d "packages/web" ]; then
    cd packages/web

    if [ -f "package.json" ] && grep -q '"build"' package.json; then
        check_status "Web端构建脚本" "PASS"
    else
        check_status "Web端构建脚本" "WARN" "未配置构建脚本"
    fi

    cd "$PROJECT_ROOT"
fi

# Flutter 构建检查
if [ -d "packages/desktop" ]; then
    cd packages/desktop

    # 检查是否可以进行 Flutter 分析
    if command -v flutter >/dev/null 2>&1; then
        echo "正在进行 Flutter 代码分析..."
        if flutter analyze >/dev/null 2>&1; then
            check_status "Flutter 代码分析" "PASS"
        else
            check_status "Flutter 代码分析" "WARN" "代码分析发现问题"
        fi
    fi

    cd "$PROJECT_ROOT"
fi

echo ""

# 总结报告
echo -e "${BLUE}📊 检查总结${NC}"
echo "========================================"
echo "总检查项: $TOTAL_CHECKS"
echo -e "通过: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "警告: ${YELLOW}$WARNING_CHECKS${NC}"
echo -e "失败: ${RED}$FAILED_CHECKS${NC}"

# 计算健康分数
if [ $TOTAL_CHECKS -gt 0 ]; then
    HEALTH_SCORE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    echo "健康分数: $HEALTH_SCORE%"

    if [ $HEALTH_SCORE -ge 90 ]; then
        echo -e "项目状态: ${GREEN}优秀${NC} 🎉"
    elif [ $HEALTH_SCORE -ge 75 ]; then
        echo -e "项目状态: ${GREEN}良好${NC} ✅"
    elif [ $HEALTH_SCORE -ge 60 ]; then
        echo -e "项目状态: ${YELLOW}一般${NC} ⚠️"
    else
        echo -e "项目状态: ${RED}需要改进${NC} ❌"
    fi
fi

echo ""

# 建议和下一步行动
if [ $FAILED_CHECKS -gt 0 ] || [ $WARNING_CHECKS -gt 0 ]; then
    echo -e "${BLUE}🔧 建议的改进措施${NC}"
    echo "----------------------------------------"

    if [ $FAILED_CHECKS -gt 0 ]; then
        echo "• 优先解决失败项，这些可能影响项目正常运行"
    fi

    if [ $WARNING_CHECKS -gt 0 ]; then
        echo "• 关注警告项，这些可能影响项目质量"
    fi

    echo "• 定期运行此检查脚本监控项目健康状态"
    echo "• 在提交代码前运行检查确保质量"
fi

echo ""
echo "检查完成时间: $(date)"
echo "========================================"

# 退出码
if [ $FAILED_CHECKS -gt 0 ]; then
    exit 1
else
    exit 0
fi
