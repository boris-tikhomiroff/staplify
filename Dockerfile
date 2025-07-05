# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files first (cache layer)
COPY package.json yarn.lock ./
COPY apps/web/package.json ./apps/web/
COPY apps/api/package.json ./apps/api/
COPY packages/ ./packages/

# Install ALL dependencies (dev + prod for build)
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Build both apps
RUN yarn build

# Production stage
FROM node:20-alpine AS runner
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache curl caddy

# Copy package files for production install
COPY package.json yarn.lock ./
COPY apps/web/package.json ./apps/web/
COPY apps/api/package.json ./apps/api/
COPY packages/ ./packages/

# Install only production dependencies
RUN yarn install --frozen-lockfile --production && yarn cache clean

# Install global packages
RUN yarn global add serve concurrently

# ⭐ CRUCIAL: Copy built applications from builder stage
COPY --from=builder /app/apps/web/dist ./apps/web/dist
COPY --from=builder /app/apps/api/dist ./apps/api/dist

# Copy Caddy configuration
COPY Caddyfile /etc/caddy/Caddyfile

# Expose port
EXPOSE 3000

# Start all services
CMD ["npx", "concurrently", \
     "--names", "WEB,API,CADDY", \
     "--prefix-colors", "cyan,green,yellow", \
     "serve -s apps/web/dist -p 8080", \
     "node apps/api/dist/main.js", \
     "caddy run --config /etc/caddy/Caddyfile"]