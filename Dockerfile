# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./
COPY apps/web/package.json ./apps/web/
COPY apps/api/package.json ./apps/api/

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Build both apps
RUN yarn build

# Production stage
FROM node:20-alpine AS runner
WORKDIR /app

# Install curl + caddy for healthcheck and reverse proxy
RUN apk add --no-cache curl caddy

# Copy package files for production install
COPY package.json yarn.lock ./
COPY apps/web/package.json ./apps/web/
COPY apps/api/package.json ./apps/api/

# Install only production dependencies
RUN yarn install --frozen-lockfile --production

# Copy built applications
COPY --from=builder /app/apps/web/dist ./apps/web/dist
COPY --from=builder /app/apps/api/dist ./apps/api/dist

# Install serve for static files
RUN yarn global add serve concurrently

# Copy Caddy configuration
COPY Caddyfile /etc/caddy/Caddyfile

# Health check
HEALTHCHECK --interval=30s \
            --timeout=5s \
            --start-period=10s \
            --retries=3 \
            CMD curl --silent --fail http://localhost:3000/health || exit 1

# Expose port
EXPOSE 3000

# Start: Frontend (8080), API (3001), Caddy (3000)
CMD ["npx", "concurrently", \
     "serve -s apps/web/dist -p 8080", \
     "node apps/api/dist/main.js", \
     "caddy run --config /etc/caddy/Caddyfile"]