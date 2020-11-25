TAG      := $(shell basename ${PWD})
IMAGE    := panubo/postgres
REGISTRY := docker.io

build:
	docker build -t $(IMAGE):$(TAG) .

.env:
	touch .env

run: .env
	docker run --rm -it --name $(TAG)-run --env-file .env $(IMAGE):$(TAG)

shell:
	docker run --rm -it --name $(TAG)-shell $(IMAGE):$(TAG) bash

exec:
	docker exec -it $(TAG)-run bash

push:
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(TAG)
	docker push $(REGISTRY)/$(IMAGE):$(TAG)

clean:
	docker rmi $(IMAGE):$(TAG) || true
	docker rmi $(REGISTRY)/$(IMAGE):$(TAG) || true
