# Build stage
FROM node:18.17.1-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json yarn.lock .yarnrc.yml nx.json tsconfig.base.json ./
COPY .yarn ./.yarn

# Copy all package.json files
COPY packages/twenty-emails/package.json ./packages/twenty-emails/
COPY packages/twenty-server/package.json ./packages/twenty-server/
COPY packages/twenty-server/patches ./packages/twenty-server/patches
COPY packages/twenty-ui/package.json ./packages/twenty-ui/
COPY packages/twenty-shared/package.json ./packages/twenty-shared/
COPY packages/twenty-front/package.json ./packages/twenty-front/

# Install dependencies
RUN yarn install && npx nx reset

# Copy source code
COPY packages ./packages

# Build everything in order
RUN npx nx build twenty-emails && \
    npx nx build twenty-ui && \
    npx nx build twenty-shared && \
    npx nx build twenty-front --configuration=production && \
    npx nx build twenty-server --configuration=production

# Production stage
FROM node:18.17.1-alpine

WORKDIR /app

# Copy built artifacts and dependencies
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/packages/twenty-server/package.json ./packages/twenty-server/

ENV NODE_ENV=production
EXPOSE 8080

# Start the server
CMD ["node", "dist/packages/twenty-server/src/main.js"]
