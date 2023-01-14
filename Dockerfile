FROM ubuntu:22.04


LABEL maintainer="Behzad Valipour Sh. b.valipour.sh@gmail.com"
LABEL version=0.0.1

# WORKDIR /ETL_task

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

COPY main.py ./

CMD [ "python", "./main.py", "--file_name", "precipitation_amount_1hour_Accumulation.nc", "--date", "2022-05", "--timestamp_filter", "2022-05-10", "2022-05-10", "--output_path", "/result/precipitation_amount_20220510_20220510.parquet"]
# /result is a directory inside the container which is mounted with EFS. So if the EFS is mounted in the different EC2 instance can be accessible.