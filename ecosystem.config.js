module.exports = {
  apps: [
    {
      name: 'kidmemory-backend',
      script: './packages/backend/dist/main.js',
      cwd: process.env.PROJECT_PATH || '/home/ubuntu/kidmemory',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true
    },
    {
      name: 'kidmemory-web',
      script: 'npm',
      args: 'start',
      cwd: process.env.PROJECT_PATH ? `${process.env.PROJECT_PATH}/packages/web` : '/home/ubuntu/kidmemory/packages/web',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      error_file: './logs/web-error.log',
      out_file: './logs/web-out.log',
      log_file: './logs/web-combined.log',
      time: true
    }
  ]
};