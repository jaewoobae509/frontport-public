## Compile Pytorch use Docker

```bash
docker buildx build -t pytorch-build .
docker run -it --rm -v $(pwd):/pytorch-src pytorch-build


# or 
# docker run -it --rm  --privileged --memory-swappiness=0 -v $(pwd):/pytorch-src pytorch-build
# docker run  --privileged  --memory=100g --memory-swap=150g -it --rm -v $(pwd):/pytorch-src pytorch-build
```

```bash
source activate pytorch-build
cd pytorch
python setup.py clean
python setup.py develop
python develop.py build
```

## Compile PyTorch from source in a Conda environment

### 1. **Set up the Conda environment**

1. **Create and activate a Conda environment:**
    
    ```bash
    conda create -n pytorch-build python=3.9 -y
    conda activate pytorch-build
    ```
    
2. **Install dependencies:** PyTorch requires various build tools and libraries. Install them with Conda and pip:
    
    ```bash
    conda install -y numpy ninja pyyaml setuptools cmake cffi typing_extensions future six requests dataclasses
    conda install -y -c conda-forge libuv mkl mkl-include tbb
    pip install --upgrade pip
    ```
    
    If you plan to use GPU:
    
    ```bash
    conda install -y cudatoolkit=11.7
    ```
    
### 2. **Clone the PyTorch repository**

1. Clone the repository:
    
    ```bash
    git clone --recursive https://github.com/pytorch/pytorch.git
    cd pytorch
    ```
    
2. If you've cloned the repository before, update the submodules, which is **our recommended way**:
    
    ```bash
    cd pytorch
    git submodule sync
    git submodule update --init --recursive
    ```
    
3. Optionally, checkout a specific branch or tag (e.g., `v2.5.1`):
    
    ```bash
    git checkout v2.5.1
    ```

### 3. **Set up the environment for compilation**

1. **Export environment variables:**
    
    ```bash
    export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
    ```
    
2. **For CUDA (if applicable):** Add the CUDA paths to your environment:
    
    ```bash
    export PATH=/usr/local/cuda/bin:$PATH
    export CUDNN_INCLUDE_DIR=/usr/local/cuda/include
    export CUDNN_LIB_DIR=/usr/local/cuda/lib64
    ```
    
    Adjust paths based on your CUDA installation.
    
3. **Choose build options:**
    
    - To enable CUDA: `USE_CUDA=1`
    - To enable distributed training: `USE_DISTRIBUTED=1`
    - To disable specific features: `USE_MKLDNN=0`, `USE_QNNPACK=0`, etc.

### 4. **Build PyTorch**

1. **Run the build command:**
    
    ```bash
    python setup.py develop
    ```
    
    This will build PyTorch from source and install it into your Conda environment.


2. For faster builds, you can use multiple threads:
    
    ```bash
    MAX_JOBS=8 python setup.py develop

3. If you have a CUDA-compatible GPU, but you don't want to use it, you can build PyTorch without CUDA support:
    ```bash
    USE_CUDA=0 MAX_JOBS=8 python setup.py develop
    ```

4. If you meet AVX-512 errors, you can disable AVX-512 support:
    ```bash
    USE_AVX512=OFF USE_FBGEMM=OFF python setup.py develop
    ```


### 5. **Verify the installation**

1. Check if PyTorch was installed correctly:
    
    ```bash
    python -c "import torch; print(torch.__version__)"
    ```
    
2. If you installed CUDA, verify GPU support:
    
    ```bash
    python -c "import torch; print(torch.cuda.is_available())"
    ```
