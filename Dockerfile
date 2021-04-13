FROM bit:5000/ubuntu18.04_cuda10.1_devel_cudnn7
# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.7    (conda)
# pytorch       1.6    (pip)
# torchvision   0.7    (pip)
# ==================================================================

ENV PATH /opt/conda/bin:$PATH
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
# ==================================================================
# tools
# ------------------------------------------------------------------
    $APT_INSTALL \
        apt-utils \
        ca-certificates \
        cmake \
        wget \
        git \
        vim \
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
        && \
# ==================================================================
# Miniconda3
# ------------------------------------------------------------------
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
        /bin/bash ~/miniconda.sh -b -p /opt/conda && \
        rm ~/miniconda.sh && \
        #echo "export PATH=/opt/conda/bin:$PATH" >> ~/.bashrc && \
# ==================================================================
# conda
# ------------------------------------------------------------------
    $CONDA_INSTALL \
        python=3.7 && \
    pip install --upgrade pip && \
    $PIP_INSTALL \
        torch==1.6.0+cu101 torchvision==0.7.0+cu101 -f https://download.pytorch.org/whl/torch_stable.html && \
    $PIP_INSTALL \
        mmcv-full==1.2.6 -f https://download.openmmlab.com/mmcv/dist/cu101/torch1.6.0/index.html && \
    $PIP_INSTALL \
        numpy \
        pyyaml \
        tqdm \
        tensorboardX \
        opencv-python \
        scipy \
        sortedcontainers \
        shapely \
        gevent \
        gevent-websocket \
        flask \
        editdistance \
        scikit-image \
        imgaug \
        cython \
        six \
        matplotlib \
        mmpycocotools \
        terminaltables \
        jupyterlab \
        && \
    conda clean -y --all && \
# ==================================================================
# config & cleanup
# ------------------------------------------------------------------
    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*
