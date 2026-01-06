# -------------------------
# 1️⃣ Base Image
# -------------------------
FROM node:20-alpine AS base
WORKDIR /app

# -------------------------
# 2️⃣ Dependencies Layer
# -------------------------
FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci

# -------------------------
# 3️⃣ Build Layer
# -------------------------
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# -------------------------
# 4️⃣ Secure Standalone Runner
# -------------------------
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Create non-root user & group
RUN addgroup -g 1001 -S nextjs \
 && adduser -S nextjs -u 1001 -G nextjs

# Copy files with correct ownership
COPY --from=builder --chown=nextjs:nextjs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nextjs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nextjs /app/public ./public

# Switch to non-root user
USER nextjs

EXPOSE 3000
CMD ["node", "server.js"]
