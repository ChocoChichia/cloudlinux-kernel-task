build:
	docker build . -t kernel-builder 

run:
	docker run --rm kernel-builder
