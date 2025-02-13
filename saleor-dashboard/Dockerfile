# Builder Stage
FROM node:18-alpine AS builder

RUN apk add --no-cache bash
WORKDIR /app

# Copy dependency files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --legacy-peer-deps

COPY nginx/ /app/nginx/
COPY assets/ /app/assets/
COPY locale/ /app/locale/
COPY scripts/ /app/scripts/
COPY src/ /app/src/
COPY .featureFlags/ /app/.featureFlags/
COPY vite.config.js /app/vite.config.js
COPY tsconfig.json /app/tsconfig.json
COPY *.d.ts /app/
COPY schema.graphql /app/schema.graphql
COPY introspection.json /app/introspection.json
COPY introspection*.json /app/



#Configure Environment Variables
ARG API_URL
ARG APP_MOUNT_URI
ARG APPS_MARKETPLACE_API_URL
ARG APPS_TUNNEL_URL_KEYWORDS
ARG STATIC_URL
ARG SKIP_SOURCEMAPS
ARG LOCALE_CODE

ENV API_URL=${API_URL:-http://localhost:8000/graphql/}
ENV APP_MOUNT_URI=${APP_MOUNT_URI:-/dashboard/}
ENV APPS_MARKETPLACE_API_URL=${APPS_MARKETPLACE_API_URL:-https://apps.saleor.io/api/v2/saleor-apps}
ENV APPS_TUNNEL_URL_KEYWORDS=${APPS_TUNNEL_URL_KEYWORDS}
ENV STATIC_URL=${STATIC_URL:-/dashboard/}
ENV SKIP_SOURCEMAPS=${SKIP_SOURCEMAPS:-true}
ENV LOCALE_CODE=${LOCALE_CODE:-EN}

# Build the application
RUN npm run build

# Runner Stage
FROM nginx:stable-alpine AS runner

# Set working directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app/build/ /app/
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./nginx/replace-env-vars.sh /docker-entrypoint.d/50-replace-env-vars.sh

RUN chmod +x /docker-entrypoint.d/50-replace-env-vars.sh


# Expose Dashboard port
EXPOSE 80

# Start Nginx
CMD ["sh", "-c", "nginx -t && nginx -g 'daemon off;'"]

