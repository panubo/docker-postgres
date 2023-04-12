TAG        := $(shell basename ${PWD})
IMAGE      := panubo/postgres
REGISTRY   := docker.io
TAG_SUFFIX := "-dev"

PG_VERSION = $(shell docker inspect $(IMAGE):$(TAG) | jq -r '.[0].Config.Env[] | select(match("PG_VERSION"))')
PG_VERSION_MAJOR = $(shell sed -E 's/.*=([0-9]+\.[0-9]+).*/\1/' <<<"$(PG_VERSION)")
PG_VERSION_MINOR = $(shell sed -E 's/.*=[0-9]+\.[0-9]+\.([0-9]+).*/\1/' <<<"$(PG_VERSION)")

TS_VERSION = $(shell docker inspect $(IMAGE):$(TAG) | jq -r '.[0].Config.Env[] | select(match("TIMESCALEDB_VERSION"))')
TS_VERSION_MAJOR = $(shell sed -E 's/.*=([0-9]+)\..*/\1/' <<<"$(TS_VERSION)")
TS_VERSION_MINOR = $(shell sed -E 's/.*=[0-9]+\.([0-9]+).*/\1/' <<<"$(TS_VERSION)")
TS_VERSION_PATCH = $(shell sed -E 's/.*=[0-9]+\.[0-9]+\.([0-9]+).*/\1/' <<<"$(TS_VERSION)")

build:
	docker build --platform linux/amd64 -t $(IMAGE):$(TAG) .

run:
	docker run --rm -it --name $(TAG)-run $(IMAGE):$(TAG)

shell:
	docker run --rm -it --name $(TAG)-shell $(IMAGE):$(TAG) bash

push:
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(TAG)
	docker push $(REGISTRY)/$(IMAGE):$(TAG)

push:
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR)$(TAG_SUFFIX)
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)$(TAG_SUFFIX)
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR).$(PG_VERSION_MINOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR).$(TS_VERSION_PATCH)$(TAG_SUFFIX)
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(PG_VERSION_MAJOR)-$(TS_VERSION_MAJOR).$(TS_VERSION_MINOR)$(TAG_SUFFIX)
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
	docker rmi $(IMAGE):$(TAG) || true
	docker rmi $(REGISTRY)/$(IMAGE):$(TAG) || true
