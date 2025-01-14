FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PATH=/opt/conda/bin:$PATH

# Use NCSU Mirror
# RUN sed -i 's/http://(archive|security).ubuntu.com/ubuntu/|https://mirror.linux.ncsu.edu/ubuntu//g' /etc/apt/sources.list.d/ubuntu.sources

# RUN sed -i -e 's/archive.ubuntu.com/mirror.linux.ncsu.edu/g' /etc/apt/sources.list.d/ubuntu.sources
# RUN sed -i -e 's/security.ubuntu.com/mirror.linux.ncsu.edu/g' /etc/apt/sources.list.d/ubuntu.sources

# Add the LLVM repository for clang-18
RUN apt-get update && apt-get install -y wget gpg && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor > /usr/share/keyrings/llvm.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-18 main" > /etc/apt/sources.list.d/llvm.list

# Install system dependencies
RUN apt-get update && apt-get install -y clang-18 clang-tools-18 clang-18-doc libclang-common-18-dev libclang-18-dev libclang1-18 clang-format-18 python3-clang-18 clangd-18 clang-tidy-18 libc++-18-dev libc++abi-18-dev libomp-18-dev cmake fzf

# Update alternatives to use Clang 18 by default
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100 

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

# Create Conda environment for PyTorch
RUN /opt/conda/bin/conda create -n pytorch-build python=3.12 -y && \
    /opt/conda/bin/conda init bash

COPY ./pytorch/requirements.txt requirements.txt

# Activate the Conda environment and install dependencies
SHELL ["/bin/bash", "-c"]
RUN source activate pytorch-build && \
    conda install -y numpy ninja pyyaml setuptools cmake cffi typing_extensions future six requests dataclasses && \
    conda install -y -c conda-forge libuv mkl mkl-include tbb && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install mkl-static mkl-include

# Set environment variables for CPU-only build
RUN echo 'export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}' >> ~/.bashrc

# Set additional environment variables
ENV _GLIBCXX_USE_CXX11_ABI=1

# Set working directory
WORKDIR /pytorch-src

CMD ["/bin/bash"]
