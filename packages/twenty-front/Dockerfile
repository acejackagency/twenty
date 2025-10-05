# Build stage
FROM node:18.17.1-alpine AS builder

WORKDIR /app

# Copy root package files
COPY package.json yarn.lock .yarnrc.yml nx.json tsconfig.base.json ./
COPY .yarn ./.yarn

# Copy all package.json files for dependency resolution
COPY packages/twenty-emails/package.json ./packages/twenty-emails/
COPY packages/twenty-server/package.json ./packages/twenty-server/
COPY packages/twenty-ui/package.json ./packages/twenty-ui/
COPY packages/twenty-shared/package.json ./packages/twenty-shared/
COPY packages/twenty-front/package.json ./packages/twenty-front/

# Install dependencies using yarn
RUN yarn install --frozen-lockfile && npx nx reset

# Copy source code
COPY packages ./packages

# Build dependencies and frontend
RUN npx nx build twenty-emails && \
    npx nx build twenty-ui && \
    npx nx build twenty-shared && \
    npx nx build twenty-front --configuration=production

# Production stage - serve with nginx
FROM nginx:alpine

# Copy built frontend files
COPY --from=builder /app/dist/packages/twenty-front /usr/share/nginx/html

# Copy nginx configuration
COPY packages/twenty-front/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
