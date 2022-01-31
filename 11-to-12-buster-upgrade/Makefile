TAG      := $(shell basename ${PWD})
IMAGE    := panubo/postgres
REGISTRY := docker.io

build:
	docker build --pull -t $(IMAGE):$(TAG) .

run:
	docker run --rm -it --name $(TAG)-run $(IMAGE):$(TAG)

shell:
	docker run --rm -it --name $(TAG)-shell $(IMAGE):$(TAG) bash

push:
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(TAG)
	docker push $(REGISTRY)/$(IMAGE):$(TAG)

clean:
	docker rmi $(IMAGE):$(TAG) || true
	docker rmi $(REGISTRY)/$(IMAGE):$(TAG) || true

tags:
	@echo $(REGISTRY)/$(IMAGE):$(TAG)
