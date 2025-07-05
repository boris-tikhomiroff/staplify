FROM node:20-alpine AS builder
WORKDIR /app

COPY package.json yarn.lock ./
COPY apps/web/package.json ./apps/web/
COPY apps/api/package.json ./apps/api/
COPY packages/ ./packages/

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build

FROM node:20-alpine AS runner
WORKDIR /app

RUN apk add --no-cache curl caddy

COPY package.json yarn.lock ./
COPY apps/web/package.json ./apps/web/
COPY apps/api/package.json ./apps/api/
COPY packages/ ./packages/

RUN yarn install --frozen-lockfile --production && yarn cache clean

RUN yarn global add serve concurrently

COPY --from=builder /app/apps/web/dist ./apps/web/dist
COPY --from=builder /app/apps/api/dist ./apps/api/dist

COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 3000

CMD ["npx", "concurrently", \
     "--names", "WEB,API,CADDY", \
     "--prefix-colors", "cyan,green,yellow", \
     "serve -s apps/web/dist -p 8080", \
     "node apps/api/dist/main.js", \
     "caddy run --config /etc/caddy/Caddyfile"]