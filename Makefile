build:
	docker build --build-arg srpmName=kernel-4.18.0-448.el8.src.rpm \
	 --build-arg srpmPath=./kernel-4.18.0-448.el8.src.rpm -t kernel-builder .

run:
	mkdir -p output
	docker run --rm \
		-v ./output:/root/rpmbuild/RPMS/ \
		kernel-builder

