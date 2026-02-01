build:
	go build -o build-stream8-kernel main.go 

run:
	./build-stream8-kernel  kernel-4.18.0-448.el8.src.rpm  output 


patch:
 	# wget "https://vault.centos.org/8-stream/BaseOS/Source/SPackages/kernel-4.18.0-448.el8.src.rpm" -O kernel-4.18.0-448.el8.src.rpm

	docker build . \
		--build-arg srpmName=kernel-4.18.0-448.el8.src.rpm \
		--build-arg srpmPath=kernel-4.18.0-448.el8.src.rpm \
		-t kernel-patcher
	
	docker run \
		-it --entrypoint /apply_patches.sh \
		-v ./patched:/root/rpmbuild/SRPMS \
		kernel-patcher
