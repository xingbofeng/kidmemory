#!/bin/bash

# KidMemory 1.0 开发环境快速设置脚本
# 自动安装和配置项目所需的所有依赖

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

echo -e "${BLUE}🚀 KidMemory 1.0 开发环境设置${NC}"
echo "========================================"
echo "设置时间: $(date)"
echo "项目路径: $PROJECT_ROOT"
echo ""

# 检测操作系统
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo -e "${RED}❌ 不支持的操作系统: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}检测到操作系统: $OS${NC}"
echo ""

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

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 1. 检查和安装 Homebrew (macOS)
if [ "$OS" = "macos" ]; then
    log_info "检查 Homebrew..."
    if check_command brew; then
        log_success "Homebrew 已安装"
    else
        log_info "安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # 添加到 PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        log_success "Homebrew 安装完成"
    fi
    echo ""
fi

# 2. 检查和安装 Node.js
log_info "检查 Node.js..."
if check_command node; then
    NODE_VERSION=$(node --version)
    log_success "Node.js 已安装: $NODE_VERSION"

    # 检查版本是否满足要求 (>= 18)
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        log_warning "Node.js 版本过低，建议升级到 18+ 版本"
    fi
else
    log_info "安装 Node.js..."
    if [ "$OS" = "macos" ]; then
        brew install node
    else
        # Linux 使用 NodeSource 仓库
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    log_success "Node.js 安装完成"
fi

# 检查和安装 npm
if check_command npm; then
    NPM_VERSION=$(npm --version)
    log_success "npm 已安装: $NPM_VERSION"
else
    log_error "npm 未安装，请检查 Node.js 安装"
    exit 1
fi

echo ""

# 3. 检查和安装 Flutter
log_info "检查 Flutter..."
if check_command flutter; then
    FLUTTER_VERSION=$(flutter --version | head -n1)
    log_success "Flutter 已安装: $FLUTTER_VERSION"
else
    log_info "安装 Flutter..."

    # 创建开发工具目录
    mkdir -p ~/development
    cd ~/development

    # 下载 Flutter
    if [ "$OS" = "macos" ]; then
        # 检测 CPU 架构
        if [[ $(uname -m) == "arm64" ]]; then
            FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_stable.zip"
        else
            FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_stable.zip"
        fi
    else
        FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_stable.tar.xz"
    fi

    log_info "下载 Flutter SDK..."
    if [ "$OS" = "macos" ]; then
        curl -o flutter.zip "$FLUTTER_URL"
        unzip -q flutter.zip
        rm flutter.zip
    else
        wget -O flutter.tar.xz "$FLUTTER_URL"
        tar xf flutter.tar.xz
        rm flutter.tar.xz
    fi

    # 添加到 PATH
    FLUTTER_PATH="$HOME/development/flutter/bin"

    # 检查 shell 类型并添加到相应的配置文件
    if [[ $SHELL == *"zsh"* ]]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.bashrc"
    fi

    if ! grep -q "flutter/bin" "$SHELL_RC" 2>/dev/null; then
        echo "export PATH=\"\$PATH:$FLUTTER_PATH\"" >> "$SHELL_RC"
        log_info "已添加 Flutter 到 PATH，请重新启动终端或运行: source $SHELL_RC"
    fi

    # 临时添加到当前会话的 PATH
    export PATH="$PATH:$FLUTTER_PATH"

    cd "$PROJECT_ROOT"
    log_success "Flutter 安装完成"
fi

# 运行 Flutter doctor
log_info "运行 Flutter doctor 检查..."
flutter doctor

echo ""

# 4. 检查和安装 PostgreSQL
log_info "检查 PostgreSQL..."
if check_command psql; then
    POSTGRES_VERSION=$(psql --version)
    log_success "PostgreSQL 已安装: $POSTGRES_VERSION"
else
    log_info "安装 PostgreSQL..."
    if [ "$OS" = "macos" ]; then
        brew install postgresql@15

        # 启动 PostgreSQL 服务
        brew services start postgresql@15

        # 添加到 PATH
        echo 'export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"' >> ~/.zprofile
        export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
    else
        sudo apt-get update
        sudo apt-get install -y postgresql postgresql-contrib
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
    fi
    log_success "PostgreSQL 安装完成"
fi

echo ""

# 5. 检查和安装 pgvector 扩展
log_info "检查 pgvector 扩展..."

# 尝试连接到默认数据库检查扩展
if psql -d postgres -c "SELECT * FROM pg_extension WHERE extname = 'vector';" >/dev/null 2>&1; then
    log_success "pgvector 扩展已安装"
else
    log_info "安装 pgvector 扩展..."
    if [ "$OS" = "macos" ]; then
        brew install pgvector
    else
        # Linux 需要从源码编译
        sudo apt-get install -y postgresql-server-dev-all build-essential git
        cd /tmp
        git clone https://github.com/pgvector/pgvector.git
        cd pgvector
        make
        sudo make install
        cd "$PROJECT_ROOT"
    fi

    # 在数据库中创建扩展
    log_info "在数据库中启用 pgvector 扩展..."
    psql -d postgres -c "CREATE EXTENSION IF NOT EXISTS vector;" || log_warning "无法自动创建 pgvector 扩展，请手动执行"

    log_success "pgvector 扩展安装完成"
fi

echo ""

# 6. 设置项目数据库
log_info "设置项目数据库..."

DB_NAME="kidmemory_dev"
DB_USER="kidmemory"
DB_PASSWORD="kidmemory_dev_password"

# 创建数据库用户和数据库
psql -d postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || log_info "用户 $DB_USER 已存在"
psql -d postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || log_info "数据库 $DB_NAME 已存在"
psql -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" >/dev/null 2>&1

# 在项目数据库中启用扩展
psql -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>/dev/null || log_warning "无法在项目数据库中创建 pgvector 扩展"

log_success "项目数据库设置完成"

echo ""

# 7. 安装项目依赖
log_info "安装项目依赖..."

# 后端依赖
if [ -d "packages/backend" ]; then
    log_info "安装后端依赖..."
    cd packages/backend
    npm install
    log_success "后端依赖安装完成"
    cd "$PROJECT_ROOT"
fi

# Web 前端依赖
if [ -d "packages/web" ]; then
    log_info "安装 Web 前端依赖..."
    cd packages/web
    npm install
    log_success "Web 前端依赖安装完成"
    cd "$PROJECT_ROOT"
fi

# Flutter 依赖
if [ -d "packages/desktop" ]; then
    log_info "安装 Flutter 依赖..."
    cd packages/desktop
    flutter pub get
    log_success "Flutter 依赖安装完成"
    cd "$PROJECT_ROOT"
fi

echo ""

# 8. 创建环境配置文件
log_info "创建环境配置文件..."

# 创建主项目 .env 文件
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
    log_success "已创建主项目 .env 文件"
fi

# 创建后端 .env 文件
if [ -d "packages/backend" ] && [ ! -f "packages/backend/.env" ]; then
    cat > packages/backend/.env << EOF
# 数据库配置
DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=$DB_NAME
POSTGRES_USER=$DB_USER
POSTGRES_PASSWORD=$DB_PASSWORD

# 应用配置
NODE_ENV=development
PORT=3001

# 路径配置
DATA_DIR=.kidmemory/data
WORKSPACE_DIR=.kidmemory/workspace
EXPORT_DIR=.kidmemory/exports

# Agent 配置 (需要自行配置)
# OPENAI_API_KEY=your_openai_api_key_here
# CLAUDE_API_KEY=your_claude_api_key_here

# Web Companion 配置 (可选)
# SUPABASE_URL=your_supabase_url
# SUPABASE_ANON_KEY=your_supabase_anon_key
# SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
EOF
    log_success "已创建后端 .env 文件"
fi

echo ""

# 9. 初始化数据库 schema
log_info "通过 Prisma migrations 初始化数据库 schema..."

(
    cd packages/backend
    DATABASE_URL="postgresql://localhost/$DB_NAME" npm run prisma:migrate >/dev/null 2>&1
)
log_success "数据库 schema 初始化完成"

echo ""

# 10. 验证安装
log_info "验证安装..."

# 运行健康检查脚本
if [ -f "scripts/health-check.sh" ]; then
    log_info "运行健康检查..."
    bash scripts/health-check.sh
else
    log_warning "健康检查脚本不存在"
fi

echo ""

# 11. 创建开发脚本
log_info "创建开发脚本..."

# 创建启动脚本
cat > scripts/dev-start.sh << 'EOF'
#!/bin/bash

# KidMemory 开发环境启动脚本

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 启动 KidMemory 开发环境..."

# 启动后端
echo "启动后端服务..."
cd packages/backend
npm run dev &
BACKEND_PID=$!

# 等待后端启动
sleep 3

# 启动 Web 前端 (可选)
echo "启动 Web 前端..."
cd ../web
npm run dev &
WEB_PID=$!

# 回到项目根目录
cd "$PROJECT_ROOT"

echo "✅ 开发环境已启动"
echo "后端服务: http://localhost:3001"
echo "Web 前端: http://localhost:5173"
echo ""
echo "启动 Flutter 桌面端请运行:"
echo "cd packages/desktop && flutter run -d macos"
echo ""
echo "按 Ctrl+C 停止所有服务"

# 等待中断信号
trap 'kill $BACKEND_PID $WEB_PID 2>/dev/null; exit' INT
wait
EOF

chmod +x scripts/dev-start.sh
log_success "开发启动脚本创建完成"

# 创建测试脚本
cat > scripts/run-tests.sh << 'EOF'
#!/bin/bash

# KidMemory 测试运行脚本

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧪 运行 KidMemory 测试套件..."

# 后端测试
if [ -d "packages/backend" ]; then
    echo "运行后端测试..."
    cd packages/backend
    npm test
    cd "$PROJECT_ROOT"
fi

# Flutter 测试
if [ -d "packages/desktop" ]; then
    echo "运行 Flutter 测试..."
    cd packages/desktop
    flutter test
    cd "$PROJECT_ROOT"
fi

# Web 前端测试
if [ -d "packages/web" ]; then
    echo "运行 Web 前端测试..."
    cd packages/web
    if grep -q '"test"' package.json; then
        npm test
    else
        echo "Web 前端测试未配置"
    fi
    cd "$PROJECT_ROOT"
fi

echo "✅ 测试完成"
EOF

chmod +x scripts/run-tests.sh
log_success "测试运行脚本创建完成"

echo ""

# 完成总结
echo -e "${GREEN}🎉 开发环境设置完成！${NC}"
echo "========================================"
echo ""
echo -e "${BLUE}📋 下一步操作：${NC}"
echo ""
echo "1. 配置 API Keys (可选):"
echo "   编辑 packages/backend/.env 文件"
echo "   添加 OPENAI_API_KEY 或 CLAUDE_API_KEY"
echo ""
echo "2. 启动开发环境:"
echo "   ./scripts/dev-start.sh"
echo ""
echo "3. 启动 Flutter 桌面端:"
echo "   cd packages/desktop && flutter run -d macos"
echo ""
echo "4. 运行测试:"
echo "   ./scripts/run-tests.sh"
echo ""
echo "5. 检查项目健康状态:"
echo "   ./scripts/health-check.sh"
echo ""
echo -e "${BLUE}📚 有用的命令：${NC}"
echo "• 查看后端日志: cd packages/backend && npm run dev"
echo "• 查看数据库: psql -d $DB_NAME"
echo "• Flutter 分析: cd packages/desktop && flutter analyze"
echo "• 重新安装依赖: rm -rf node_modules && npm install"
echo ""
echo -e "${YELLOW}⚠️  注意事项：${NC}"
echo "• 如果遇到权限问题，可能需要重新启动终端"
echo "• macOS 可能需要在系统偏好设置中允许应用运行"
echo "• 首次运行 Flutter 可能需要下载额外依赖"
echo ""
echo "设置完成时间: $(date)"
echo "========================================"
