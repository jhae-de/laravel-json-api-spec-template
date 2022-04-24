include .env

node := docker compose exec node

.PHONY: start
start:
	@docker compose up --detach

.PHONY: stop
stop:
	@docker compose down

.PHONY: bash
bash: start
	@$(node) bash

.PHONY: install
install: start
	@$(node) yarn install

.PHONY: lint
lint: start
	@$(node) yarn run lint

.PHONY: docs
docs: start
	@$(node) yarn run docs

.PHONY: bundle
bundle: start
	@$(node) sh -ec "\
		yarn run openapi bundle spec/v1/openapi.yaml --output dist/openapi.json; \
		sed -i \"s!%API_TITLE%!\$${API_TITLE}!g\" dist/openapi.json; \
		sed -i \"s!%API_DESCRIPTION%!\$${API_DESCRIPTION}!g\" dist/openapi.json; \
		sed -i \"s!%API_VERSION%!\$${API_VERSION}!g\" dist/openapi.json;"

.PHONY: build
build: start
	@$(node) sh -ec "\
		yarn run openapi bundle spec/v1/openapi.yaml --output /tmp/openapi.yaml; \
		sed -i \"s!%API_TITLE%!\$${API_TITLE}!g\" /tmp/openapi.yaml; \
		sed -i \"s!%API_DESCRIPTION%!\$${API_DESCRIPTION}!g\" /tmp/openapi.yaml; \
		sed -i \"s!%API_VERSION%!\$${API_VERSION}!g\" /tmp/openapi.yaml; \
		yarn run redoc-cli build /tmp/openapi.yaml --output dist/index.html;"
