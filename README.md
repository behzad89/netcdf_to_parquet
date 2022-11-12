# Jua.ai’s Geospatial Data Engineering Assessment

Pipeline to transform the data into the Apache Parquet datasource

# Setting up the environment

Use provided `requirements.txt` or `Dockerfile` to set up the envirnment.

## Instructions for Docker
### Build new image
Build a new docker image using provided `Dockerfile`. All the required packages would be installed for this pipeline. e.g.

```
docker build -t jua_env:0.0.1 .
```
### Running container
The script can run directly or inside the container using the foolowing code.

```
docker run --rm -it \
            -v $(pwd):/jua_ETL_task \
            --name jua_task \
            jua_env:0.0.1 \
            bash python main.py --file_name precipitation_amount_1hour_Accumulation.nc --date 2022-05 --fileter_date 2022-05-10 2022-05-10 --output_path ./test.parquet
```