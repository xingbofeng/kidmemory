module.exports = {
  apps: [
    {
      name: 'kidmemory-cloud-api',
      script: './packages/cloud-api/dist/main.js',
      cwd: process.env.PROJECT_PATH || '/home/ubuntu/kidmemory',
      env: {
        NODE_ENV: 'production',
        CLOUD_API_HOST: '127.0.0.1',
        CLOUD_API_PORT: 3002
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: './logs/cloud-api-error.log',
      out_file: './logs/cloud-api-out.log',
      log_file: './logs/cloud-api-combined.log',
      time: true
    }
  ]
};
