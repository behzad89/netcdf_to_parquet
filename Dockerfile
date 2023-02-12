FROM ubuntu:latest


LABEL maintainer="Behzad Valipour Sh. b.valipour.sh@gmail.com"
LABEL version=0.0.2

WORKDIR /BEHZAD_DIR
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --ignore-missing \
    git\
    nano \
    curl \
    unzip \
    awscli \
    rsync \
    screen \
    python3 \
    python3-pip; exit 0

# Add 3.10 to the available alternatives
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
# Set python3.10 as the default python
RUN update-alternatives --set python /usr/bin/python3.10

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

CMD ["/bin/bash"]

# To Run the Container: 
# docker run --rm -it -p 8265:8265 -p 8888:8888 -v C:\Users\valibe\Desktop\RayCluster\.aws:/root/.aws -v C:\Users\valibe\Desktop\RayCluster:/BEHZAD_DIR --name linux_server geo-linux-server:0.0.1

# To connect to the Jupyter Lab in the container:
# jupyter lab --no-browser --port=8888 --ip 0.0.0.0 --LabApp.password='' --LabApp.token= '' --allow-root

# Some Useful info to handle the errors:
# https://stackoverflow.com/a/30717108
# https://stackoverflow.com/a/48986548
# https://stackoverflow.com/a/20851484
# https://dev.to/grigorkh/fix-tzdata-hangs-during-docker-image-build-4o9m

