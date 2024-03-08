# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Environment variables
# ---------------------------------------------------------------------------------------------------------------------------------------------------
IMAGE_NAME="wootechspace/init-vite-vue-project"
IMAGE_TAG="node-20.11.1-bookworm-slim"

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Makefile functions
# ---------------------------------------------------------------------------------------------------------------------------------------------------
default: help

.PHONY: help
help: ## list makefile targets
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build-init
build-init: ## build docker image wootechspace/init-vite-vue-project
		@cd ./scaffolding && docker build --tag $(IMAGE_NAME):$(IMAGE_TAG) .

.PHONY: build-init-if-not-exists
build-init-if-not-exists: ## build docker image wootechspace/init-vite-vue-project if not exists
		@if [ "$$(docker images --quiet $(IMAGE_NAME):$(IMAGE_TAG) 2> /dev/null)" = "" ]; then \
			echo "Docker Image '$(IMAGE_NAME):$(IMAGE_TAG)' does not exist"; \
			make --no-print-directory build-init; \
		fi

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# WARNINGS!!! This function initialized the project files from scratch
# ---------------------------------------------------------------------------------------------------------------------------------------------------
.PHONY: init
init: build-init-if-not-exists ## init vite-vue project
		@docker container run --detach --name temp-container $(IMAGE_NAME):$(IMAGE_TAG) /bin/bash > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/index.html ./ > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/package.json ./ > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/public ./ > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/src ./ > /dev/null 2>&1 || true
		@docker container cp temp-container:/home/node/vite-vue-project/vite.config.js ./ > /dev/null 2>&1 || true
		@docker container stop temp-container > /dev/null 2>&1 || true
		@docker container rm temp-container > /dev/null 2>&1 || true
		@echo "Project files extracted"
