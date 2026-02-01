package main

import (
	"errors"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)


func validatePath(path string){
	if _, err := os.Stat(path); errors.Is(err, os.ErrNotExist) {
  		fmt.Fprintln(os.Stderr, "SRPM file does not exist",err)
        os.Exit(1)
	}
}

func validateSRPM(srpmPath string){
	if !strings.HasSuffix(srpmPath,"src.rpm") {
		fmt.Fprintln(os.Stderr, "Error: invalid type of file")
        os.Exit(1)
	}
}


func IsUrl(str string)  {
    u, err := url.Parse(str)
	if err != nil || ( u.Scheme != "http" && u.Scheme != "https" ) {
		fmt.Fprintln(os.Stderr, "Error: Invalid url",err)
        os.Exit(1)
	}
}

func getSrpmName(srpmUrl string) string {
	parts := strings.Split(srpmUrl, "/")
	return parts[len(parts)-1]
}

func handleDonwload(srpmUrl string) {
	IsUrl(srpmUrl)

	fmt.Println("Starting curl downlaod for srpm")
	cmd := exec.Command("curl", "-LO", srpmUrl)
	err := cmd.Run()

	if err != nil {
		fmt.Fprintln(os.Stderr, "Error: curl failed",err)
		os.Exit(1)
    }

	fmt.Println("Curl finished !")
}

func buildDocker(srpmPath string){
	srpmName := getSrpmName(srpmPath)

	fmt.Println("Beginning docker build for srpm : ",srpmName)
	cmd := exec.Command(
		"docker",
		"build",
		"--build-arg", "srpmName="+srpmName,
		"--build-arg", "srpmPath="+srpmPath,
		"-t", "kernel-builder",
		".",
	)
	
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error: Docker build failed !",err)
		os.Exit(1)
    }

	fmt.Println("build finished !")
}


func runImage(outputPath string) {
	
	absOut, err := filepath.Abs(outputPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if err := os.MkdirAll(absOut, 0755); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Println("Beginning image run")

	cmd := exec.Command(
		"docker",
		"run",
		"--rm",
		"-v", absOut+":/root/rpmbuild/RPMS",
		"kernel-builder",
	)

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		fmt.Fprintln(os.Stderr, "docker run failed ! ", err)
		os.Exit(1)
	}
}

func main() {
    argsWithoutProg := os.Args[1:]
	if len(argsWithoutProg) != 2 {
		fmt.Fprintln(os.Stderr, "Error: Number of argumnets must be 2")
        os.Exit(1)
	}

    fmt.Println(argsWithoutProg[0],argsWithoutProg[1])

	firstArg := argsWithoutProg[0]
	srpmPath := firstArg
	outputPath := argsWithoutProg[1]

	if strings.HasPrefix(firstArg,"http") {
		handleDonwload(firstArg)
		srpmPath = getSrpmName(firstArg)
	} 

	validateSRPM(srpmPath)
	buildDocker(srpmPath)
	runImage(outputPath)
}



