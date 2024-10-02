TAG=arm-cross-grpc

.PHONY: build
build:
	docker build -t ${TAG} .


.PHONY: runb
runb: build
	docker run --rm -it ${TAG} bash
