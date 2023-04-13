TAG      := $(shell basename ${PWD})
IMAGE    := panubo/postgres
REGISTRY := quay.io

build:
	docker build --platform linux/amd64 -t $(REGISTRY)/$(IMAGE):$(TAG) .

run:
	docker run --rm -it --name $(TAG)-run $(REGISTRY)/$(IMAGE):$(TAG)

shell:
	docker run --rm -it --name $(TAG)-shell $(REGISTRY)/$(IMAGE):$(TAG) bash

push:
	docker push $(REGISTRY)/$(IMAGE):$(TAG)

clean:
	docker rmi $(REGISTRY)/$(IMAGE):$(TAG) || true

tags:
	@echo $(REGISTRY)/$(IMAGE):$(TAG)

_ci_test:
	true

_ci_version:
	@echo $(TAG)
