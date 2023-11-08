FROM python:3.7.17-bookworm

RUN mkdir -p /opt2 && mkdir -p /data2
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt-get -y upgrade
# Set the locale
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		locales build-essential cmake cpanminus && \
	localedef -i en_US -f UTF-8 en_US.UTF-8 && \
	cpanm FindBin Term::ReadLine

RUN apt-get update && apt-get install -y \
	curl \
  libffi-dev \
  libdeflate-dev \
  libsqlite3-dev \
  libcurl4-openssl-dev \
	pigz \
	unzip \
  wget

# Install conda and give write permissions to conda folder
RUN echo 'export PATH=/opt2/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-pypy3-$(uname)-$(uname -m).sh" -O ~/miniforge3.sh && \
    /bin/bash ~/miniforge3.sh -b -p /opt2/conda && \
    rm ~/miniforge3.sh && chmod 777 -R /opt2/conda/
ENV PATH=$PATH:/opt2/conda/bin
# install most mimseq deps from conda
RUN mamba install -c bioconda -c conda-forge \
    python=3.7 \
    'r-base>=4.1' \
    'biopython>=1.79' \
    'matplotlib-base>=3.4.2' \
    'numpy>=1.21.1' \
    'pandas>=1.3.1' \
    'requests>=2.26.0' \
    'pybedtools>=0.8.2' \
    'pyfiglet>=0.8.post1' \
    'pysam>=0.16.0.1' \
    'seaborn-base>=0.11.1' \
    'statsmodels>=0.13.1' \
    'infernal>=1.1.4' \
    'blast>=2.10.1' \
    'gmap<=2019.02.26' \
    'samtools>=1.11' \
    'bedtools>=2.30.0' \
    'r-ggplot2>=3.3.5' \
    'r-ggpol>=0.0.7' \
    'bioconductor-complexheatmap>=2.2.0' \
    'bioconductor-deseq2>=1.26.0' \
    'r-pheatmap>=1.0.12' \
    'r-calibrate>=1.7.7' \
    'r-gridextra>=2.3' \
    'r-plyr>=1.8.6' \
    'r-dplyr>=1.0.6' \
    'r-tidyverse>=1.3.0' \
    'r-devtools>=2.4.1' \
    'r-reshape2>=1.4.4'

# install usearch
RUN wget https://drive5.com/downloads/usearch10.0.240_i86linux32.gz && \
        gunzip usearch10.0.240_i86linux32.gz && \
        chmod a+x usearch10.0.240_i86linux32 && \
        mkdir -p /opt2/usearch && \
        mv usearch10.0.240_i86linux32 /opt2/usearch/usearch && \
        rm -f usearch10.0.240_i86linux32.gz
ENV PATH=/opt2/usearch:$PATH

# install local mimseq
COPY . /opt2/mim-tRNAseq
WORKDIR /opt2/mim-tRNAseq
RUN pip install --upgrade pip && \
  pip install . && \
  mimseq --version

# check mimseq installation
WORKDIR /opt2
RUN which mimseq && mimseq --version
RUN python --version

# cleanup
RUN apt-get clean && apt-get purge && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

COPY Dockerfile /opt2/Dockerfile
RUN chmod -R a+rX /opt2/Dockerfile

WORKDIR /data2