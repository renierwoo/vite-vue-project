# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Environment variables
# ---------------------------------------------------------------------------------------------------------------------------------------------------
INIT_IMAGE_NAME="wootechspace/init-vite-vue-project"
INIT_IMAGE_TAG="node-20.11.1-bookworm-slim"
IMAGE_NAME="wootechspace/vite-vue-app"
IMAGE_TAG="nginx-1.25.4-bookworm"

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Makefile functions
# ---------------------------------------------------------------------------------------------------------------------------------------------------
default: help

.PHONY: help
help: ## list makefile targets
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build-init
build-init: ## build docker image wootechspace/init-vite-vue-project
		@cd ./scaffolding && docker build --tag $(INIT_IMAGE_NAME):$(INIT_IMAGE_TAG) .

.PHONY: build-init-if-not-exists
build-init-if-not-exists: ## build docker image wootechspace/init-vite-vue-project if not exists
		@if [ "$$(docker images --quiet $(INIT_IMAGE_NAME):$(INIT_IMAGE_TAG) 2> /dev/null)" = "" ]; then \
			echo "Docker Image '$(INIT_IMAGE_NAME):$(INIT_IMAGE_TAG)' does not exist"; \
			make --no-print-directory build-init; \
		fi

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# WARNINGS!!! This function initialized the project files from scratch
# ---------------------------------------------------------------------------------------------------------------------------------------------------
.PHONY: init
init: build-init-if-not-exists ## init vite-vue project
		@docker container run --detach --name temp-container $(INIT_IMAGE_NAME):$(INIT_IMAGE_TAG) /bin/bash > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/index.html ./ > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/package.json ./ > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/public ./ > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/src ./ > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/vite.config.js ./ > /dev/null 2>&1 || true
		@docker container stop temp-container > /dev/null 2>&1 || true
		@docker container rm temp-container > /dev/null 2>&1 || true
		@echo "Project files extracted"

.PHONY: build
build: ## build docker image wootechspace/vite-vue-app:nginx-1.25.4-bookworm
		@docker build --tag $(IMAGE_NAME):$(IMAGE_TAG) .

.PHONY: build-if-not-exists
build-if-not-exists: ## build docker image wootechspace/vite-vue-app:nginx-1.25.4-bookworm if not exists
		@if [ "$$(docker images --quiet $(IMAGE_NAME):$(IMAGE_TAG) 2> /dev/null)" = "" ]; then \
			echo "Docker Image '$(IMAGE_NAME):$(IMAGE_TAG)' does not exist"; \
			make --no-print-directory build; \
		fi

.PHONY: up
up: build-if-not-exists ## Run docker container from image wootechspace/vite-vue-app:nginx-1.25.4-bookworm
		@docker container run --interactive --tty --detach --publish 8080:80 --name vite-vue-app $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: shell
shell: ## Start bash shell session in docker container vite-vue-app
		@docker container exec --interactive --tty vite-vue-app /bin/bash

.PHONY: down
down: ## Stop and remove docker container vite-vue-app
		@docker container stop vite-vue-app
		@docker container rm vite-vue-app
