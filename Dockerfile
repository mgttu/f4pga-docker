# syntax=docker/dockerfile:1
FROM ubuntu:18.04
SHELL ["/bin/bash", "-c"]

ARG FPGA_FAM
ARG F4PGA_INSTALL_DIR="/opt/f4pga"
ARG F4PGA_PACKAGES
ARG F4PGA_TIMESTAMP
ARG F4PGA_HASH

ENV FPGA_FAM=${FPGA_FAM}
ENV F4PGA_INSTALL_DIR=${F4PGA_INSTALL_DIR}

ARG PATH ${F4PGA_INSTALL_DIR}/${FPGA_FAM}/conda/bin:$PATH

# add conda commands to PATH
ENV PATH ${F4PGA_INSTALL_DIR}/${FPGA_FAM}/conda/bin:$PATH
# add fpga conda environment to the PATH
ENV PATH ${F4PGA_INSTALL_DIR}/${FPGA_FAM}/conda/envs/${FPGA_FAM}/bin:$PATH

WORKDIR /app
RUN apt update -y && apt install -y git wget xz-utils && apt install build-essential -y --no-install-recommends && \
  git clone https://github.com/chipsalliance/f4pga-examples && \
  cd f4pga-examples && \
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./conda_installer.sh && \
  chmod +x ./conda_installer.sh && \
  ./conda_installer.sh -u -b -p ${F4PGA_INSTALL_DIR}/${FPGA_FAM}/conda && \
  rm ./conda_installer.sh && \
  source "${F4PGA_INSTALL_DIR}/${FPGA_FAM}/conda/etc/profile.d/conda.sh" && \
  conda env create -f ${FPGA_FAM}/environment.yml && \
  mkdir -p ${F4PGA_INSTALL_DIR}/${FPGA_FAM} && \
  for PKG in ${F4PGA_PACKAGES}; do \
    wget -qO- "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-$PKG-${F4PGA_HASH}.tar.xz" | tar -xvJC ${F4PGA_INSTALL_DIR}/${FPGA_FAM}; \
  done;

# Mount your PWD to /project, then `docker run` any bash command in the conda environment
WORKDIR /project
