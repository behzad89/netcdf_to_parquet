FROM ubuntu:20.04


LABEL maintainer="Behzad Valipour Sh. b.valipour.sh@gmail.com"
LABEL version=0.0.1

WORKDIR /jua_ETL_task

RUN apt-get update \
    && apt-get install -y \
    git\
    nano \
    libopenblas-dev \
    liblapack-dev \
    libpq-dev \
    python-is-python3 \
    python3-pip \
    python3-dev \
    proj-bin \
    && rm -rf /var/lib/apt/lists/*

ARG DEBIAN_FRONTEND=noninteractive

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

#ENTRYPOINT [ "python" ]
CMD [/bin/bash] 
# should be used in case want to have access to container