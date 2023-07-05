ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION}

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
ENV CC gcc-${GCC_VERSION}
ENV CXX g++-${GCC_VERSION}
RUN apt-get -y update \
    && apt-get -y install software-properties-common \
    && add-apt-repository ppa:git-core/ppa \
    && apt-get -y update \
    && apt-get -y install gcc-${GCC_VERSION} \
	     g++-${GCC_VERSION} \
	     libopenmpi-dev \
	     openmpi-bin \
		 cmake \
		 git \
	&& apt-get -y remove software-properties-common \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/*
# resolves dist issue
ARG PYTHON_VERSION=3.10
RUN ln -s /usr/local/lib/python${PYTHON_VERSION}/dist-packages /usr/lib/python${PYTHON_VERSION}/site-packages

# install requirements
COPY setup.py /tmp/dpte/setup.py
ARG TENSORFLOW_VERSION=2
ARG PYTHON_VERSION=3.10
ARG GCC_VERSION=8
RUN	python --version \
    && apt-get -y update \
    && apt-get -y install curl \
    && (curl -sS https://bootstrap.pypa.io/get-pip.py | python \
    || curl -sS https://bootstrap.pypa.io/pip/${PYTHON_VERSION}/get-pip.py | python) \
	&& apt-get -y remove curl \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/* \
    && python -m pip install -U pip packaging \
    && python -m pip install -e /tmp/dpte \
    && HOROVOD_WITHOUT_GLOO=1 HOROVOD_WITH_TENSORFLOW=1 python -m pip install -e /tmp/dpte[mpi]

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
# add everything to safe.directory
# see https://github.com/pypa/setuptools_scm/issues/707
RUN git config --global --add safe.directory '*'
ENV PYTHONIOENCODING utf8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US
ENV LC_ALL en_US.UTF-8

CMD [ "/bin/bash" ]

