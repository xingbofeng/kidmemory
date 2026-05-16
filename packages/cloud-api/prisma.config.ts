import { defineConfig } from "prisma/config";

const fallbackConnectionString = "postgresql://kidmemory:kidmemory@localhost:5432/kidmemory_cloud";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    url: process.env.DATABASE_URL ?? fallbackConnectionString,
  },
});
