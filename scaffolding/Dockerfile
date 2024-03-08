FROM node:20.11.1-bookworm-slim

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

# RUN set -ex \
#     && npm create vue@latest \
#     vite-vue-project \
#     --typescript \
#     --jsx \
#     --router \
#     --pinia \
#     --vitest \
#     --cypress \
#     --eslint \
#     --prettier

RUN set -ex \
    && yarn create vite vite-vue-project --template vue

RUN set -ex \
    && ln -s -f /dev/stdout /var/log/container.log

# wootechspace/init-vite-vue-project:node-20.11.1-bookworm-slim