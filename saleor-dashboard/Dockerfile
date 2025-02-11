# Builder Stage
FROM node:18-alpine AS builder

WORKDIR /app
RUN apk add --no-cache bash

# Copy dependency files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --legacy-peer-deps

# Copy application files
COPY . .


COPY nginx/ assets/ locale/ scripts/ src .featureFlags/ ./
COPY vite.config.js tsconfig.json *.d.ts schema.graphql introspection.json introspection*.json ./

#Configure Environment Variables
ARG API_URL=http://localhost:8000/graphql/
ARG APP_MOUNT_URI=/dashboard/
ARG APPS_MARKETPLACE_API_URL=https://apps.saleor.io/api/v2/saleor-apps
ARG APPS_TUNNEL_URL_KEYWORDS=
ARG STATIC_URL=/dashboard/
ARG SKIP_SOURCEMAPS=true
ARG LOCALE_CODE=EN

# Bind ARG values to environment variables (ENV)
ENV API_URL=${API_URL}
ENV APP_MOUNT_URI=${APP_MOUNT_URI}
ENV APPS_MARKETPLACE_API_URL=${APPS_MARKETPLACE_API_URL}
ENV APPS_TUNNEL_URL_KEYWORDS=${APPS_TUNNEL_URL_KEYWORDS}
ENV STATIC_URL=${STATIC_URL}
ENV SKIP_SOURCEMAPS=${SKIP_SOURCEMAPS}
ENV LOCALE_CODE=${LOCALE_CODE}

# Build the application
RUN npm run build

# Runner Stage
FROM nginx:stable-alpine AS runner

# Set working directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app/build/ .
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./nginx/replace-env-vars.sh /docker-entrypoint.d/50-replace-env-vars.sh

RUN chmod +x /docker-entrypoint.d/50-replace-env-vars.sh


# Expose Dashboard port
EXPOSE 80

# Start Nginx
RUN nginx -t 
CMD ["nginx", "-g", "daemon off;"]
