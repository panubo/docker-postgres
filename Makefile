SUBDIRS := 9.4-debian 9.6-debian 10-debian 10-debian-1.6.1 11-debian

.PHONY: build push clean

build:
	for dir in $(SUBDIRS); do \
		make TAG=$$dir -C $$dir $(MAKECMDGOALS); \
	done

push:
	for dir in $(SUBDIRS); do \
		make TAG=$$dir -C $$dir $(MAKECMDGOALS); \
	done

clean:
	for dir in $(SUBDIRS); do \
		make TAG=$$dir -C $$dir $(MAKECMDGOALS); \
	done
