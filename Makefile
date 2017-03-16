export SHELL := /bin/bash
.DEFAULT_GOAL := help

# Platform-specific variables
# ---------------------------
PLATFORM_INFO:= $(shell python -m platform)
ifeq ($(findstring Ubuntu,$(PLATFORM_INFO)),Ubuntu)
	PLATFORM:= ubuntu
	ENV?= $(shell pwd | sed -n 's/.*osm-tasking-manager2-staging/staging/p; s/.*osm-tasking-manager2-production/production/p')
endif
ifeq ($(findstring Darwin,$(PLATFORM_INFO)),Darwin)
	PLATFORM:= darwin
	ENV?= development
	APP_LIVE:= app
	AWS_PROFILE:= hotosm
endif

ENVS = development staging production
## Check ENV
ifeq ($(filter $(ENV),$(ENVS)),)
$(error Valid ENV values include: $(ENVS))
endif

# PHONY (non-file) Targets
# ------------------------
.PHONY: build env check up destroy ps logs restart exec-app exec-db backup restore help

## Docker

BUILD_DB := docker build -t hotosm/taskmanager-db:$(ENV) -f ./Dockerfile.db .
BUILD_APP := docker build -t hotosm/taskmanager-app:$(ENV) -f ./Dockerfile.app .
BUILD_WEB := docker build -t hotosm/taskmanager-web:$(ENV) -f ./Dockerfile.web .
BUILD_STATS := docker build -t hotosm/taskmanager-stats:$(ENV) -f ./Dockerfile.stats .
BUILD_STATIC := docker build -t hotosm/taskmanager-static:$(ENV) -f ./Dockerfile.static .

build: ## build containers
	@$(BUILD_DB)
	@$(BUILD_APP)
	@$(BUILD_STATS)
	@$(BUILD_STATIC)
ifeq ($(ENV),development)
	@$(BUILD_WEB)
endif

## Docker Compose

DOCKER_COMPOSE_CLI := docker-compose -f docker-compose.yml -f docker-compose.$(ENV).yml

ifneq ($(ENV),development)
	LIVE_COLOR:=$(shell $(DOCKER_COMPOSE_CLI) ps | sed -n 's/.*blue.*Up*/blue/p; s/.*green.*Up*/green/p' | awk '{print $$1}')
  APP_LIVE:= app_$(LIVE_COLOR)
endif

ifeq ($(APP_LIVE),app_green)
  APP_DEPLOY=app_blue
else
  APP_DEPLOY=app_green
endif

env: ## check live color
	echo $(APP_LIVE)

up: ## start TM2 or update current services after making compose changes
ifeq ($(ENV),development)
	@$(DOCKER_COMPOSE_CLI) up -d
else ifeq ($(APP_LIVE),app_blue)
	@$(DOCKER_COMPOSE_CLI) up -d db app_blue
else
	@$(DOCKER_COMPOSE_CLI) up -d db app_green
endif

deploy1: ## deploy
	@$(BUILD_APP)

deploy2:
	@$(DOCKER_COMPOSE_CLI) up -d --force-recreate $(APP_DEPLOY)

deploy3:
	@$(DOCKER_COMPOSE_CLI) stop $(APP_LIVE)

deploy: deploy1 deploy2 deploy3

destroy: ## destroy TM2
	@$(DOCKER_COMPOSE_CLI) down -v

ps: ## ps TM2
	@$(DOCKER_COMPOSE_CLI) ps

logs: ## logs TM2
	@$(DOCKER_COMPOSE_CLI) logs -f

restart: ## logs confluence
	@$(DOCKER_COMPOSE_CLI) restart

stats-run: ## bash app
	@$(DOCKER_COMPOSE_CLI) run stats ./env/bin/python taskingDbEndpoint.py

stats-exec: ## bash app
	@$(DOCKER_COMPOSE_CLI) run stats bash

stats-logs: ## bash app
	@$(DOCKER_COMPOSE_CLI) logs -f stats

app-exec: ## bash app
	@$(DOCKER_COMPOSE_CLI) exec $(APP_LIVE) bash

db-exec: ## bash db
	@$(DOCKER_COMPOSE_CLI) exec db bash

static-exec: ## bash static
	@$(DOCKER_COMPOSE_CLI) exec static sh

static-logs: ## bash static
	@$(DOCKER_COMPOSE_CLI) logs -f static

psql: ## connect to database
	@$(DOCKER_COMPOSE_CLI) exec db su -c "psql -h localhost -p 5432 -U postgres -d osmtm"

migrations:
	@$(DOCKER_COMPOSE_CLI) exec $(APP_LIVE) su -c "./env/bin/alembic upgrade head"

BACKUP_BUCKET:=s3://hotosm-backups/osm-tasking-managerv2

backup: ## dump tm2 db and post to S3
	@$(DOCKER_COMPOSE_CLI) exec db su -c "time pg_dump -v -Fc -f /srv/osmtm2.dmp -h localhost -U postgres osmtm"
	@aws s3 cp /tmp/osmtm2.dmp $(BACKUP_BUCKET)/osmtm2_$(ENV)_$(shell date +'%Y%m%d_%H%M%S').dmp

LASTEST_BACKUP = $(shell aws s3 ls $(BACKUP_BUCKET)/ | grep -v staging | sort | tail -n 1 | awk '{print $$4}')
download-backup-s3:
	@echo $(LASTEST_BACKUP)
	@aws s3 cp $(BACKUP_BUCKET)/$(LASTEST_BACKUP) /tmp/osmtm2.dmp

restore-remote: download-backup-s3 restore

fresh-db: env
	@$(DOCKER_COMPOSE_CLI) exec $(APP_LIVE) su -c "./wait-for-postgres.sh db"
	@$(DOCKER_COMPOSE_CLI) stop db
	@$(DOCKER_COMPOSE_CLI) rm -v -f db
	@$(DOCKER_COMPOSE_CLI) up -d db
	@$(DOCKER_COMPOSE_CLI) exec $(APP_LIVE) su -c "./wait-for-postgres.sh db"

restore: env fresh-db ## restore latest backup from S3
	@$(DOCKER_COMPOSE_CLI) exec db su -c "pg_restore -v -h localhost -p 5432 -U postgres -d osmtm /srv/osmtm2.dmp"

# `make help` -  see http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# ------------------------------------------------------------------------------------
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
