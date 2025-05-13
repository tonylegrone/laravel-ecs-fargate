.PHONY: help

CONTAINER_APP=app
CONTAINER_COMPOSER=composer
CONTAINER_NODE=node
CONTAINER_SERVER=server
CONTAINER_REDIS=redis

help: ## Print help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

ps: ## Show containers.
	@docker-compose ps

build: ## Build all containers
	@docker-compose build

start: ## Start all containers
	@docker-compose up --force-recreate -d

fresh: stop destroy build start ## Destroy & recreate all containers

stop: ## Stop all containers
	@docker-compose stop

restart: stop start ## Restart all containers

destroy: stop ## Destroy all containers
	@docker-compose down

cache: ## Cache project
	docker exec -t ${CONTAINER_APP} php artisan view:cache
	docker exec -t ${CONTAINER_APP} php artisan config:cache
	docker exec -t ${CONTAINER_APP} php artisan event:cache
	docker exec -t ${CONTAINER_APP} php artisan route:cache

cache-clear: ## Clear cache
	docker exec -t ${CONTAINER_APP} php artisan cache:clear
	docker exec -t ${CONTAINER_APP} php artisan view:clear
	docker exec -t ${CONTAINER_APP} php artisan config:clear
	docker exec -t ${CONTAINER_APP} php artisan event:clear
	docker exec -t ${CONTAINER_APP} php artisan route:clear

migrate: ## Run migration files
	docker exec -t ${CONTAINER_APP} php artisan migrate

migrate-fresh: ## Clear database and run all migrations
	docker exec -t ${CONTAINER_APP} php artisan migrate:fresh

composer-install: ## Install frontend assets
	docker exec -t ${CONTAINER_COMPOSER} composer install --no-progress --no-interaction

npm-install: ## Install frontend assets
	docker exec -t ${CONTAINER_NODE} npm install

npm-dev: npm-install ## Compile front assets for dev
	@docker exec -t ${CONTAINER_NODE} npm run dev

npm-build: npm-install ## Compile front assets
	@docker exec -t ${CONTAINER_NODE} npm run build

logs: ## Print all docker logs
	docker-compose logs -f

logs-app: ## Print all php container logs
	docker logs ${CONTAINER_APP}

logs-node: ## Print all node container logs
	docker logs ${CONTAINER_NODE}

logs-redis: ## Print all redis container logs
	docker logs ${CONTAINER_REDIS}

logs-server: ## Print all server container logs
	docker logs ${CONTAINER_SERVER}

ssh-app: ## SSH inside php container
	docker exec -it ${CONTAINER_APP} bash

ssh-composer: ## SSH inside composer container
	docker exec -it ${CONTAINER_COMPOSER} bash

ssh-node: ## SSH inside node container
	docker exec -it ${CONTAINER_NODE} bash

ssh-redis: ## SSH inside redis container
	docker exec -it ${CONTAINER_REDIS} bash

ssh-server: ## SSH inside server container
	docker exec -it ${CONTAINER_SERVER} bash
