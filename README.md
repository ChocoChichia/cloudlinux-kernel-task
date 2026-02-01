## Part 1: Standard Build (Tasks 1 & 2)

The `build-stream8-kernel` tool automates the process of creating the Docker builder, injecting the Source RPM (SRPM), and extracting the binary RPMs.

### 1. Build the Go Tool
Compile the CLI wrapper:
```bash
make build
```

### 2. Run the Build
You can build from a **local file** or a **remote URL**.


**Option A: Build from Local File**
```bash
./build-stream8-kernel <path-to-sprm> <output-folder-path>
```

Specific example : 
```bash
./build-stream8-kernel kernel-4.18.0-448.el8.src.rpm output
```

**Option B: Build from URL**
```bash
./build-stream8-kernel https://vault.centos.org/8-stream/BaseOS/Source/SPackages/kernel-4.18.0-448.el8.src.rpm output
```

### 3. Check Artifacts
Upon completion, the binary RPMs (kernel, kernel-core, kernel-modules, etc.) will be available in the `./output/` directory on your host machine.

---

## Part 2: Patching & Rebuild (Task 3)

This workflow applies specific upstream security patches (commits `80e648` and `f90fff`) to the SRPM and rebuilds it.

### 1. Generate the Patched SRPM
Run the patch automation script. This runs a container that downloads the upstream patches, modifies the `kernel.spec` file, and generates a new `.src.rpm`.


```bash
make patch
```

**Result:** A new SRPM is created at `./patched/kernel-....'


### 2. Build the Patched Kernel
Use the Go tool created in Part 1 to build this new SRPM.

```bash
./build-stream8-kernel patched/kernel-4.18.0-448.el8.src.rpm output-patched
```

**Result:** The patched binary RPMs will be in the `output-patched/` directory.

