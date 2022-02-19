from ubuntu:18.04

LABEL maintainer="Jinzhe Zeng <jinzhe.zeng@rutgers.edu>"

# install python
ARG PYTHON_VERSION=3.10
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN apt-get -y update \
    && apt-get -y install software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get -y update \
	&& apt-get -y install python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-distutils\
	&& update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 999 \
	&& apt-get -y remove software-properties-common \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/*

# install gcc
ARG GCC_VERSION=8
env CC gcc-${GCC_VERSION}
env CXX g++-${GCC_VERSION}

RUN apt-get -y update \
    && apt-get -y install gcc-${GCC_VERSION} \
	     g++-${GCC_VERSION} \
	     libopenmpi-dev \
	     openmpi-bin \
		 cmake \
		 git \
	&& rm -rf /var/lib/apt/lists/*

# install requirements
COPY setup.py /tmp/dpte/setup.py
ARG TENSORFLOW_VERSION=2
ARG GCC_VERSION=8
RUN	python --version \
    && apt-get -y update \
    && apt-get -y install curl \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python \
	&& apt-get -y remove curl \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/* \
    && python -m pip install -U pip packaging \
    && python -m pip install -e /tmp/dpte \
    && HOROVOD_WITHOUT_GLOO=1 HOROVOD_WITH_TENSORFLOW=1 python -m pip install -e /tmp/dpte[mpi]

CMD [ "/bin/bash" ]

