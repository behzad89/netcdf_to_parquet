# Name: AWS_Bootstrapping_File.sh
# Description: The script to set up the EC2 instance in AWS
# Author: Behzad Valipour Sh. <b.valipour.sh@gmail.com>
# Date:13.01.2023
#!/bin/bash -xe


apt-get -y update
apt-get -y upgrade

# STEP Necessary  Package
apt-get install -y \
       python3-pip\
       awscli \
	   figlet

# STEP GDAL Package
apt-get update \
    && apt-get install -y \
       software-properties-common \
    && apt-get update \
    && add-apt-repository ppa:ubuntugis/ppa \
    && apt-get update \
    && apt-get install -y \
               gdal-bin \
               libgdal-dev\
    && apt-get update
	

	
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal

# STEP Python Package
sudo pip install -U \
	aiobotocore==2.4.0 \
	aiohttp==3.8.3 \
	aioitertools==0.11.0 \
	aiosignal==1.3.1 \
	async-timeout==4.0.2 \
	attrs==22.1.0 \
	botocore==1.27.59 \
	charset-normalizer==2.1.1 \
	coloredlogs==15.0.1 \
	frozenlist==1.3.3 \
	fsspec==2022.11.0 \
	h3==3.7.4 \
	h5netcdf==1.0.2 \
	h5py==3.7.0 \
	humanfriendly==10.0 \
	idna==3.4 \
	jmespath==1.0.1 \
	multidict==6.0.2 \
	numpy==1.23.4 \
	packaging==21.3 \
	pandas==1.5.1 \
	pyarrow==10.0.0 \
	pyparsing==3.0.9 \
	pyreadline3==3.4.1 \
	python-dateutil==2.8.2 \
	pytz==2022.6 \
	s3fs==2022.11.0 \
	six==1.16.0 \
	typing_extensions==4.4.0 \
	urllib3==1.26.12 \
	wrapt==1.14.1 \
	xarray==2022.11.0 \
	yarl==1.8.1 \
	jupyterlab \
	ray==2.2.0 \
	boto3 \
	pystac_client \
	stackstac \
	dask

# STEP Welcome Message (Optional)
chmod -x /etc/update-motd.d/*
echo "#!/bin/sh" > /etc/update-motd.d/01-custom
echo 'figlet  Linux Ubuntu' >> /etc/update-motd.d/01-custom
echo 'figlet AWS Geo-Server' >> /etc/update-motd.d/01-custom
echo 'echo Author: Behzad Valipour Sh.' >> /etc/update-motd.d/01-custom
chmod +x /etc/update-motd.d/01-custom

 