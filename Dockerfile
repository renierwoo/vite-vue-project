FROM node:20.11.1-bookworm-slim AS builder

RUN set -ex \
    && temp_arch="$(arch)" \
    && if [ "$temp_arch" = "x86_64" ]; then \
    echo "Arquitectura: $temp_arch (x86_64)"; \
    export ARCH="amd64"; \
    elif [ "$temp_arch" = "aarch64" ]; then \
    echo "Arquitectura: $temp_arch (ARM64)"; \
    export ARCH="arm64"; \
    else \
    echo "Arquitectura desconocida: $temp_arch"; \
    exit 1; \
    fi \
    && echo "ARCH=$ARCH" >> /etc/environment \
    && apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends --no-install-suggests \
    curl \
    && npm install -g npm@latest \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/*

WORKDIR /home/node

COPY package*.json ./

RUN set -ex \
    && yarn

COPY . .

RUN set -ex \
    && yarn build



FROM nginx:1.25.4-bookworm AS production

RUN set -ex \
    && rm -rf /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/nginx.conf

COPY --from=builder /home/node/dist /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# wootechspace/vite-vue-app:nginx-1.25.4-bookworm