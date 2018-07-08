# Spread cli arguments
ifneq (,$(filter $(firstword $(MAKECMDGOALS)),exec))
    CLI_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(CLI_ARGS):;@:)
endif

docker-compose = docker-compose -f docker-compose.yml $1

-include .env

init:
	cp .env.example .env

config:
	sed -i 's/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=${DBPASS}/g' ./docker-compose.yml
	sed -i 's/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=${DBPASS}/g' ./autoinstall.yml
	sed -i 's/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=${DBPASS}/g' ./docker-compose.yml
	sed -i 's/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=${DBPASS}/g' ./autoinstall.yml
	sudo ./runfirst.bash

up:
	$(call docker-compose, up -d --force-recreate)

down:
	$(call docker-compose, down --volumes)

reup: down up

destroy:
	@if [ -d ./distribution-files/mediawiki ]; then sudo rm -fr ./distribution-files/mediawiki; fi
