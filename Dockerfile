ARG CUDA="9.0"
ARG CUDNN="7"

FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-devel-ubuntu16.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# install basics
RUN apt-get upgrade -y\
 && apt-get update -y \
 && apt-get install -y apt-utils git curl ca-certificates bzip2 cmake tree htop bmon iotop g++ \
 && apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev \
 && apt-get install unzip

# RUN rm /miniconda.sh

# Install Miniconda
RUN wget -O /miniconda3.sh https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh \
 && chmod +x /miniconda3.sh \
 && /miniconda3.sh -b -p /miniconda3 \
 && rm /miniconda3.sh

# Create a Python 3.6 environment
ENV PATH=/miniconda3/bin:$PATH
RUN /miniconda3/bin/conda install -y conda-build \
 && /miniconda3/bin/conda create -y --name mb python=3.6.7 \
 && /miniconda3/bin/conda clean -ya

ENV CONDA_DEFAULT_ENV=mb
ENV CONDA_PREFIX=/miniconda3/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

RUN conda install -y ipython
RUN conda install -c menpo opencv
RUN pip install ninja yacs cython matplotlib tqdm scipy shapely networkx pandas scikit-learn seaborn
RUN pip install jupyterlab
RUN conda install pillow=5.2.0
# Install PyTorch 1.0 Nightly and OpenCV
RUN conda install -y pytorch=1.0 cudatoolkit=9.0 -c pytorch \
 && conda clean -ya
RUN conda install -y torchvision=0.2 -c pytorch \
 && conda clean -ya

RUN git clone https://github.com/cocodataset/cocoapi.git \
 && cd cocoapi/PythonAPI \
 && python setup.py build_ext install


WORKDIR /code/Box_Discretization_Network
