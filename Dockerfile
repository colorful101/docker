ARG CUDA="9.0"
ARG CUDNN="7"

FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-devel-ubuntu16.04
ENV PATH=/opt/conda/bin:$PATH
ENV LC_ALL=C
ENV TZ=Asia/Shanghai

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \
    CONDA_INSTALL="conda install -y" && \
    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && \
    apt-get -y upgrade && \
# ==============================================================
# tools
# ==============================================================
    $APT_INSTALL \
        apt-utils \
        ca-certificates \
        cmake \
        wget \
        git \
        vim \
        curl \
        openssh-client \
        openssh-server \
        libboost-dev \
        libboost-thread-dev \
        libboost-filesystem-dev \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender-dev \
        ffmpeg \
        ninja-build \
        ca-certificates \
        bzip2 \
        tree \
        htop \
        bmon \
        g++
        
# Install Miniconda
RUN curl -o /miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh \
 && chmod +x /miniconda3.sh \
 && /miniconda3.sh -b -p /miniconda3 \
 && rm /miniconda3.sh
 
# Create a Python 3.7 environment
ENV PATH=/miniconda3/bin:$PATH

RUN /miniconda3/bin/conda install -y conda-build \
 && /miniconda3/bin/conda create -y --name mb python=3.7.0 \
 && /miniconda3/bin/conda clean -ya

ENV CONDA_DEFAULT_ENV=mb
ENV CONDA_PREFIX=/miniconda3/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# ==================================================================
# conda
# ------------------------------------------------------------------
RUN $CONDA_INSTALL \
        pytorch=1.1 cudatoolkit=9.0 -c pytorch && \
    $CONDA_INSTALL \
        ipython \
        pillow=5.2.0 && \
    $CONDA_INSTALL \
        -c menpo opencv && \
    $CONDA_INSTALL \
        torchvision=0.3.0 -c pytorch && \
    pip install --upgrade pip && \
    $PIP_INSTALL \
        ninja \
        yacs \
        cython \
        matplotlib \
        tqdm \
        scipy \
        shapely \
        networkx \
        pandas \
        scikit-learn \
        seaborn \
        jupyterlab

RUN $GIT_CLONE https://github.com/cocodataset/cocoapi.git \
 && cd cocoapi/PythonAPI \
 && python setup.py build_ext install \
 && cd ../.. && rm -rf cocoapi

RUN $GIT_CLONE https://github.com/NVIDIA/apex \
 && git checkout f3a960f80244cf9e80558ab30f7f7e8cbf03c0a0 \
 && cd apex \
 && pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ \
 && cd .. && rm -rf apex

RUN $GIT_CLONE https://github.com/mapillary/inplace_abn.git \
 && cd inplace_abn \
 && python setup.py install \
 && cd .. && rm -rf inplace_abn

RUN conda clean -y --all
# ==================================================================
# config & cleanup
# ------------------------------------------------------------------
    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*
