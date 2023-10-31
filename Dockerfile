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

# install python 3.7 & local mimseq
COPY . /opt2/mim-tRNAseq
WORKDIR /opt2/mim-tRNAseq
RUN pip install --upgrade pip && \
  pip install . && \
  mimseq --version

# check mimseq installation
WORKDIR /opt2
RUN which mimseq && mimseq --version
RUN python --version

# install usearch
RUN wget https://drive5.com/downloads/usearch10.0.240_i86linux32.gz && \
        gunzip usearch10.0.240_i86linux32.gz && \
        chmod a+x usearch10.0.240_i86linux32 && \
        mkdir -p /opt2/usearch && \
        mv usearch10.0.240_i86linux32 /opt2/usearch/usearch && \
        rm -f usearch10.0.240_i86linux32.gz
ENV PATH=/opt2/usearch:$PATH


# cleanup
RUN apt-get clean && apt-get purge && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

COPY Dockerfile /opt2/Dockerfile
RUN chmod -R a+rX /opt2/Dockerfile

WORKDIR /data2
