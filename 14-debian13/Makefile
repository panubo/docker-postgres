SHELL      := /bin/bash
TAG        := $(shell basename ${PWD})
IMAGE      := panubo/postgres
REGISTRY   := quay.io
TAG_SUFFIX := -debian11

PG_VERSION = $(shell docker inspect $(REGISTRY)/$(IMAGE):$(TAG) | jq -r '.[0].Config.Env[] | select(match("PG_VERSION"))')
PG_VERSION_MAJOR = $(shell sed -E 's/.*=([0-9]+)\..*/\1/' <<<"$(PG_VERSION)")
PG_VERSION_MINOR = $(shell sed -E 's/.*=[0-9]+\.([0-9]+).*/\1/' <<<"$(PG_VERSION)")

TS_VERSION = $(shell docker inspect $(REGISTRY)/$(IMAGE):$(TAG) | jq -r '.[0].Config.Env[] | select(match("TIMESCALEDB_VERSION"))')
TS_VERSION_MAJOR = $(shell sed -E 's/.*=([0-9]+)\..*/\1/' <<<"$(TS_VERSION)")
TS_VERSION_MINOR = $(shell sed -E 's/.*=[0-9]+\.([0-9]+).*/\1/' <<<"$(TS_VERSION)")
TS_VERSION_PATCH = $(shell sed -E 's/.*=[0-9]+\.[0-9]+\.([0-9]+).*/\1/' <<<"$(TS_VERSION)")

build:
	docker build --pull -t $(REGISTRY)/$(IMAGE):$(TAG) .

.env:
	touch .env

run: .env
	docker run --rm -it --name $(TAG)-run --env-file .env $(REGISTRY)/$(IMAGE):$(TAG)

shell:
	docker run --rm -it --name $(TAG)-shell $(REGISTRY)/$(IMAGE):$(TAG) bash

push:
	docker tag $(REGISTRY)/$(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR)$(TAG_SUFFIX)
	docker tag $(REGISTRY)/$(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)$(TAG_SUFFIX)
	docker tag $(REGISTRY)/$(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR).$(TS_VERSION_PATCH)$(TAG_SUFFIX)
	docker tag $(REGISTRY)/$(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR)$(TAG_SUFFIX)
	docker push $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR)$(TAG_SUFFIX)
	docker push $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)$(TAG_SUFFIX)
	docker push $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR).$(TS_VERSION_PATCH)$(TAG_SUFFIX)
	docker push $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR)$(TAG_SUFFIX)

tags:
	@echo "Tags:"
	@echo $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR)$(TAG_SUFFIX)
	@echo $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)$(TAG_SUFFIX)
	@echo $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR).$(TS_VERSION_PATCH)$(TAG_SUFFIX)
	@echo $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR)$(TAG_SUFFIX)

clean:
	docker rmi $(REGISTRY)/$(IMAGE):$(TAG) || true

_ci_test:
	true

_ci_version:
	@echo $(PG_VERSION_MAJOR)$(TAG_SUFFIX)
	@echo $(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)$(TAG_SUFFIX)
	@echo $(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR).$(TS_VERSION_PATCH)$(TAG_SUFFIX)
	@echo $(PG_VERSION_MAJOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR)$(TAG_SUFFIX)
