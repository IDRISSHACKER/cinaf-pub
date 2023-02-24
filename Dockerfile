FROM node:18-alpine AS base

FROM base as prodenv
RUN npm install pm2 -g

FROM base AS setup

WORKDIR /app

COPY ecosystem.config.js package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN npm install

FROM base AS builder

WORKDIR /app

COPY --from=setup /app/node_modules ./node_modules
COPY . .

RUN npm run build

FROM prodenv AS runner

WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder --chmod=700 /app/public ./public
COPY --chown=nextjs:nodejs --chmod=700 ./ecosystem.config.js ./

COPY --from=builder --chown=nextjs:nodejs --chmod=700 /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs --chmod=700 /app/.next/static  ./.next/static

USER nextjs
EXPOSE 3000/TCP
ENV PORT 3000

CMD pm2 start ecosystem.config.js && pm2 monit
