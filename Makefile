COMPOSE_FILE?=testproject/docker-compose.yml
COMPOSE_CMD=docker-compose -f $(COMPOSE_FILE)
RUN_DJANGO = $(COMPOSE_CMD) run --rm django
RUN_DJANGO_NO_DEPS = $(COMPOSE_CMD) run --rm --no-deps django
RUN_MANAGE = $(RUN_DJANGO) python manage.py

SOURCE = . ../trench
ISORT := $(COMPOSE_CMD) run --rm django isort -c -rc -df
FLAKE8 := $(COMPOSE_CMD) run --rm django flake8

default:
	make build
	make test

build:
	$(COMPOSE_CMD) build

runserver:
	$(COMPOSE_CMD) run --service-ports --rm django runserver

test:
	$(RUN_DJANGO) py.test --cov-report term-missing --cov=../trench

migrate:
	$(RUN_MANAGE) migrate

create_admin:
	$(RUN_MANAGE) createsuperuser --username admin

backend:
	$(COMPOSE_CMD) run -p 8000:8000 --rm django

client:
	make backend
	make frontend
	make start

frontend:
	docker build -d -t django-trench-frontend ./examples/client/

start:
	docker run -p 3000:3000 django-trench-frontend

isort:
	$(foreach dir,$(SOURCE),cd $(dir); $(ISORT))

flake8:
	$(foreach dir,$(SOURCE),cd $(dir); $(FLAKE8))
