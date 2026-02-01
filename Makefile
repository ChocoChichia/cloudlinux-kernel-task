build:
	go build -o build-stream8-kernel main.go 

run:
	./build-stream8-kernel  kernel-4.18.0-448.el8.src.rpm  output 
