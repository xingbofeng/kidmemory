import { defineConfig } from "prisma/config";

const databaseUrl =
  process.env.DATABASE_URL
  ?? process.env.POSTGRES_URL
  ?? "postgresql://kidmemory:placeholder@localhost:5432/kidmemory";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    url: databaseUrl,
  },
});
