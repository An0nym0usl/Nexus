# Build
FROM node:22-bookworm-slim AS build
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY package.json package-lock.json tsconfig.base.json ./
COPY packages packages
RUN npm ci
RUN npm run build

# Runtime
FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y libsqlite3-0 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
COPY packages packages
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/packages/simulation/dist ./packages/simulation/dist
COPY --from=build /app/packages/server/dist ./packages/server/dist
COPY --from=build /app/packages/web/dist ./packages/web/dist
RUN mkdir -p data
EXPOSE 3847
CMD ["node", "packages/server/dist/index.js"]
