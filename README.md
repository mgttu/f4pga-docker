# Introduction
This provides a standalone docker container for synthesizing your Verilog code with the open source FPGA suite F4PGA (originally Symbiflow), which targets the Xilinx 7-Series, Lattice iCE40 (currently [not supported here](https://github.com/chipsalliance/f4pga-examples/issues/122)), and QuickLogic families. If you are stuck on MacOS or Windows, then this tool will allow you to configure and run the Linux command-line tools pretty easily (as opposed to using `vagrant`).

This container is meant to be built once (to download the toolchain and packages for specific architectures), then be spun-up every time you run a toolchain command.

Before proceeding below, first clone the repository:

```
git clone https://github.com/mgttu/f4pga-docker.git
```

# Building the Docker image
## Prerequisites
Docker and Docker Compose are required.

## Foreword
This is a first-time setup that you probably wont need to do again unless you want to update F4PGA in the future. The docker-compose.yml contains configurations for Xilinx 7 and EOS S3 families, so if you are targeting only those, then you can go directly to the sections below. Otherwise, follow this guide closely to find the correct configuration that fits your needs: https://f4pga-examples.readthedocs.io/en/latest/getting.html -- For your convenience, all Docker build arguments have been named after the configurable variables mentioned in the guide, and we will show you how to specify build arguments below.

## Building for the Xilinx 7-Series 35T/50T (Basys 3, Arty A7-35T)
If you are targeting any boards using Xilinx 7-Series 35T/50T, then run this command to build an image:

```bash
docker-compose build f4pga-xc7-a50t
```

## Building for the Xilinx 7-Series 100T (Arty A7-100T, Alphamax NeTV2, Nexys 4 DDR)
If you are targeting any boards using Xilinx 7-Series 100T, then run this command to build an image:

```bash
docker-compose build f4pga-xc7-a100t
```

## Building for the Xilinx 7-Series 200T (Nexys Video)
If you are targeting any boards using Xilinx 7-Series 200T, then run this command to build an image:

```bash
docker-compose build f4pga-xc7-a200t
```

## Building for the Xilinx 7-Series Zynq-7000 (Zybo Z7)
If you are targeting any boards using Xilinx 7-Series Zynq-7000, then run this command to build an image:

```bash
docker-compose build f4pga-xc7-z010
```

## Building for ALL Xilinx 7-Series
**Warning**: This is quite large, >16GB in size.
If you are targeting all supported boards within the Xilinx 7-Series, then you can run this command to build an image:

```bash
docker-compose build f4pga-xc7-all
```

## Building for the QuickLogic EOS S3
If you are targeting QuickLogic EOS S3, then you can run this command to build an image:

```bash
docker-compose build f4pga-eos-s3
```

## Building for other boards / configuring the image
### Adding build arguments
When running `docker build`, you can add build arguments like so `--build-arg NAME=VALUE`, which will influence the Dockerfile to generate a different image depending on your needs. 

Additionally, the `-t` argument followed by a string will tag/name your image as such, so then you can reference something like `docker run f4pga-<name>` later down the line.

As an example, we will generate a Docker image for a QuickLogic EOS S3.

Within the root of this repository, you can run the following command to build an image for a QuickLogic EOS S3:

```bash
docker build -t f4pga-custom-eos-s3 \
  --build-arg FPGA_FAM="eos-s3" \
  --build-arg F4PGA_PACKAGES="install-ql ql-eos-s3_wlcsp" \
  --build-arg F4PGA_TIMESTAMP="20220818-143856" \
  --build-arg F4PGA_HASH="24e8f73" .
```

### Configurable Variables
Just remember that it doesn't hurt to wrap these values in strings!

| Name                  | Default   | Possible choices | Example Docker syntax |
| --------------------- | --------- | ---------------- | --------------------- |
| FPGA\_FAM | `xc7` | xc7, eos-s3 | `--build-arg FPGA_FAM="xc7"` |
| F4PGA\_PACKAGES | `install-xc7 xc7a50t_test` | See [guide](https://f4pga-examples.readthedocs.io/en/latest/getting.html) | `--build-arg F4PGA_PACKAGES="install-xc7 xc7a50t_test"` |
| F4PGA\_TIMESTAMP | `20220818-143856` | See [guide](https://f4pga-examples.readthedocs.io/en/latest/getting.html) | `--build-arg F4PGA_TIMESTAMP="20220818-143856"`  |
| F4PGA\_HASH | `24e8f73` | See [guide](https://f4pga-examples.readthedocs.io/en/latest/getting.html) | `--build-arg F4PGA_HASH="24e8f73"` |

## Remarks
- Currently, this container can only build for one FPGA family at a time, so you must create a new container for each chipset you want to support.
- Note that variables `F4PGA_TIMESTAMP` and `F4PGA_HASH` will change whenever there is an update to F4PGA. Just check the [Getting F4PGA guide](https://f4pga-examples.readthedocs.io/en/latest/getting.html) for latest values.

# Usage / Synthesizing a bitstream in the container
## Foreword
Every time you run `docker run ...`, you tell Docker to create a container that will be cached indefinitely, even after it is done processing. **Ensure you have the `--rm` argument present** to tell Docker to delete the container instance once it is finished.

The default volume is bound to `$PWD:/project`, meaning the container can see your current working directory (and everything else below) in its own /project directory. The naming of `/project` does not mean anything special, it was chosen deliberately as the default directory from where to run the toolchain commands. Thus, ensure that you have the `$PWD:/project` volume binding when running these commands.

Ensure that you are running commands (like `make`) from the _root_ of your project or repository. Some Makefiles do relative inclusions to a parent directory, and Docker cannot see what's beyond your volume. Also, ensure that you take care of absolute paths too by making the necessary volume bindings from your host to the container, like so: `-v /my/host/path:/some/absolute/container/path`

One final remark, if you get an error during the compilation phase (i.e., missing techmaps), then in most cases you probably forgot to specify the correct packages for your targeted chipset. Go back to the Building section in this readme, read the [guide](https://f4pga-examples.readthedocs.io/en/latest/getting.html) again, and double-check the build argument `F4PGA_PACKAGES`.

## General usage / running a command within the container
```bash
docker run --rm -it -v ${PWD}:/project f4pga-<arch> <command>
```

## QUICK START: Building from `f4pga-examples`
The repository [chipsalliance/f4pga-examples](https://github.com/chipsalliance/f4pga-examples) contains examples projects that will be used in the following sections. If you want to follow along with the examples, clone this repository and continue below.

Note: If you want to write a Makefile of your own, the repository contains very useful boilerplate Makefiles that you can use for your own project.

### Synthesizing an `f4pga-examples` Counter project for the Xilinx-7 chip targeting a Basys3
For Xilinx-7 specifically, a TARGET environment variable must be passed to your command in order to target a board. See available targets in the Makefile [here](https://github.com/chipsalliance/f4pga-examples/blob/main/common/common.mk#L8).

Within the f4pga-examples folder, run this command on your host machine:

```bash
docker run --rm -it -v ${PWD}:/project f4pga-xc7-a50t make -C xc7/counter_test TARGET=basys3
```

### Synthesizing an `f4pga-examples` Counter project for the QuickLogic EOS S3
Within the f4pga-examples folder, run this command on your host machine:

```bash
docker run --rm -it -v ${PWD}:/project f4pga-eos-s3 make -C eos-s3/btn_counter
```

# Out of scope: Uploading the bitstream
## Why you can't upload a bitstream in Docker
Docker is finicky with USB port exposure. If you try to use something like openFPGALoader within the container, you will typically get an error like this:

```
> openFPGALoader -b basys3 /project/xc7/counter_test/build/basys3/top.bit
open_device: failed to initialize ftdi
JTAG init failed with: open_device: failed to initialize ftdi
```

## You should upload from the host instead
For the reasons above, you must upload bitstreams from your host machine. Thankfully, `openFPGAloader` supports a [multitude of boards](https://trabucayre.github.io/openFPGALoader/compatibility/board.html) and works on all modern operating systems.

Install openFPGAloader here: https://trabucayre.github.io/openFPGALoader/guide/install.html

## Which file do I upload?
Typically, the synthesizer will generate a `top.bit` file somewhere your build folder. This is your generated bitstream.

## What board name to I provide?
Check here for a list of board names: https://trabucayre.github.io/openFPGALoader/compatibility/board.html

Your board may not be compatible and you may have to configure a different tool like OpenOCD.

### Uploading via openFPGAloader to SRAM
```
openFPGALoader -b <board> top.bit
```

### Uploading via openFPGAloader to flash
```
openFPGALoader -b <board> -f top.bit
```

# TODO

- Allow configuration to download and support all toolchain families in one image instead of requiring the user to build separate instances.
- Emit warning if there are missing build arguments.
- Support "latest" keyword to pull latest tar.xz file manifest from the F4PGA package repository.

# Remarks

1. The build instructions were taken from https://f4pga-examples.readthedocs.io/en/latest/getting.html and modified to run inside a Docker container
2. This has been tested on the Digilent Basys3.
