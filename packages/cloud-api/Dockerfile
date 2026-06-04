FROM node:22-bookworm-slim AS builder

WORKDIR /app

COPY tsconfig.nest.json ./
COPY packages/protocol/package*.json packages/protocol/
COPY packages/cloud-api/package*.json packages/cloud-api/

RUN cd packages/protocol && npm ci
RUN cd packages/cloud-api && npm ci

COPY packages/protocol packages/protocol
COPY packages/cloud-api packages/cloud-api

RUN cd packages/protocol && npm run build
RUN cd packages/cloud-api && npm run build:prod

FROM node:22-bookworm-slim AS runtime

ENV NODE_ENV=production
ENV CLOUD_API_HOST=0.0.0.0
ENV CLOUD_API_PORT=3000

WORKDIR /app/packages/cloud-api

COPY --from=builder /app/packages/protocol /app/packages/protocol
COPY --from=builder /app/packages/cloud-api/package*.json ./
COPY --from=builder /app/packages/cloud-api/prisma ./prisma
COPY --from=builder /app/packages/cloud-api/dist ./dist

RUN npm ci --include=dev && npm cache clean --force

EXPOSE 3000

CMD ["node", "dist/main.js"]
