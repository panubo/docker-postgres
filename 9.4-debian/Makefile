GIT_ROOT := $(shell git rev-parse --show-toplevel)
TAG      := $(shell echo $(CURDIR) | sed -E -e 's | $(GIT_ROOT)/||' -e 's|/|-|g')
IMAGE    := panubo/postgres
REGISTRY := docker.io

build:
	docker build --pull -t $(IMAGE):$(TAG) .

run:
	docker run --rm -it $(IMAGE):$(TAG)

push:
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(TAG)
	docker push $(REGISTRY)/$(IMAGE):$(TAG)

clean:
	docker rmi $(IMAGE):$(TAG) || true
	docker rmi $(REGISTRY)/$(IMAGE):$(TAG) || true
