-include setenv.sh

.PHONY: all create-env build

create-env: ## Force write/overwrite the .env file
	@echo "BASE_IMAGE=${BASE_IMAGE}\n" \
    "PG_VERSION=$(PG_VERSION)\n" \
	"INSTALL_REPO=$(INSTALL_REPO)\n" \
    "CONFIG_DIR=${CONFIG_DIR}\n" \
    "DOCKER_BIN=${DOCKER_BIN}\n" \
    "SERVER_PORT=${SERVER_PORT}\n" \
    "PG_NAME=$(PG_NAME)\n" \
    "DACHS_NAME=$(DACHS_NAME)\n" \
    "GAVO_DATA=$(GAVO_DATA)"> .env

build: create-env ## Build the Docker images using central environment variables
	@echo "Building images with PG_VERSION=$(PG_VERSION)..."
	docker compose build --no-cache=true \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg PG_VERSION=$(PG_VERSION) \
		--build-arg INSTALL_REPO=$(INSTALL_REPO) \
        --build-arg CONFIG_DIR=$(CONFIG_DIR) \
        --build-arg DOCKER_BIN=$(DOCKER_BIN) \
        --build-arg GAVO_DATA=$(GAVO_DATA)

up: create-env ## Start the containers in the background
	docker compose up -d

down: create-env ## Stop and remove containers
	docker compose down

update_config: ## Update gavo.rc and metadata (uses CONFIG_DIR)
	@echo "Updating DaCHS configuration in container from $(CONFIG_DIR)..."
	docker cp "${CONFIG_DIR}/gavo.rc" "${DACHS_NAME}:/etc/gavo.rc"
	##docker cp "${CONFIG_DIR}/defaultmeta.txt" "${DACHS_NAME}:/var/gavo/etc/"
	##docker cp "${CONFIG_DIR}/userconfig.rd" "${DACHS_NAME}:/var/gavo/etc/"
	docker exec -it ${DACHS_NAME} sh -c "dachs pub //services"

restart: ## Restart the DaCHS server
	docker exec $(DACHS_NAME) dachs serve restart
