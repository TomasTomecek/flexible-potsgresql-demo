.PHONY: default build run
CONTAINER_NAME := pg
IMAGE_NAME := $(USER)/postgresql
UPSTREAM_IMAGE_NAME := registry.access.redhat.com/rhscl/postgresql-95-rhel7:latest
TEMPLATE_DIR := /usr/share/container-scripts/postgresql/
TEMPLATE_FILENAME := openshift-custom-postgresql.conf.template
TEMPLATE_PATH := $(TEMPLATE_DIR)$(TEMPLATE_FILENAME)

default: build

build:
	docker build --tag=$(IMAGE_NAME) .

run:
	docker run --rm -e POSTGRESQL_USER=pg_test -e POSTGRESQL_PASSWORD=secret -e POSTGRESQL_DATABASE=test_db \
		-e POSTGRESQL_WORK_MEM=128MB \
		--name $(CONTAINER_NAME) $(IMAGE_NAME)

inject:
	docker run --rm -e POSTGRESQL_USER=pg_test -e POSTGRESQL_PASSWORD=secret -e POSTGRESQL_DATABASE=test_db \
		-v $(TEMPLATE_FILENAME):$(TEMPLATE_DIR) \
		-e POSTGRESQL_WORK_MEM=128MB \
		--name $(CONTAINER_NAME) $(UPSTREAM_IMAGE_NAME)

show_work_mem:
	docker exec $(CONTAINER_NAME) bash -c 'psql --command "show work_mem;"'

$(TEMPLATE_FILENAME):
	docker cp $(CONTAINER_NAME):$(TEMPLATE_PATH) $(TEMPLATE_FILENAME)
