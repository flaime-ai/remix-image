FROM nvidia/cuda:11.0-runtime-ubuntu18.04

ENV CONDA_PATH=/opt/anaconda3
ENV ENVIRONMENT_NAME=main
SHELL ["/bin/bash", "-c"]

COPY ./aux/libcudnn8_8.0.4.30-1+cuda11.0_amd64.deb /tmp
RUN dpkg -i /tmp/libcudnn8_8.0.4.30-1+cuda11.0_amd64.deb

# curl is required to download Anaconda.
RUN apt-get update && apt-get install curl -y

# Download and install Anaconda.
RUN cd /tmp && curl -O https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh
RUN chmod +x /tmp/Anaconda3-2019.07-Linux-x86_64.sh
RUN mkdir /root/.conda
RUN bash -c "/tmp/Anaconda3-2019.07-Linux-x86_64.sh -b -p ${CONDA_PATH}"

# Initializes Conda for bash shell interaction.
RUN ${CONDA_PATH}/bin/conda init bash

# Upgrade Conda to the latest version
RUN ${CONDA_PATH}/bin/conda update -n base -c defaults conda -y

# Create the work environment and setup its activation on start.
RUN ${CONDA_PATH}/bin/conda create --name ${ENVIRONMENT_NAME} -y
RUN echo conda activate ${ENVIRONMENT_NAME} >> /root/.bashrc

# install conda environment libs
COPY ./environment.yml /tmp/
RUN . ${CONDA_PATH}/bin/activate ${ENVIRONMENT_NAME} \
  && conda env update --file /tmp/environment.yml --prune

COPY ./test-gpu.py /root