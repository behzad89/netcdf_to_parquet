![](https://github.com/behzad89/netcdf_to_parquet/workflows/ecr/badge.svg)
# Geospatial Data Engineering Assessment

Pipeline to transform the data into the Apache Parquet datasource

```mermaid
graph LR
id1[(AWS S3 Bucket)] --> B(Read datase)
B --> C{Timestamp filter}
C --YES--> D(Apply time filter)
D --> E(Apply time filter)
C --NO--> E(Extract coordinates & value)
E --> F(Apply spatial indexing)
F --> J(Save Apache Parquet file)
```

The pipeline developed in the Python CLI format with following flags:

 - `file_name`: The file name e.g. precipitation_amount_1hour_Accumulation.nc in S3 bucket
 - `date`: Date of corresponding data in **YYYY-MM** format
 - `timestamp_filter`: The span of time between a specific start date and end date in **YYYY-MM-DD** format
 - `resolution`: Resolution for hierarchical geospatial indexing; default:10
 - `output_path`: Path to save the parquet file.

# Setting up the environment

Use provided `requirements.txt` or `Dockerfile` to set up the envirnment.

## Instructions for AWS ECS
### Build new image
Build a new docker image using provided `Dockerfile`. All the required packages would be installed for this pipeline, and save the build image in AWS ECR.

```
docker build -t netcdf_to_parquet:latest .
```
### Save the result
AWS EFS can be used to mount in the container to save the final result. The result can be accessed via diffrent EC2 instances or on-permises servers.

### Running container
Create a cluster with Frgate/EC2 instance, and define the task in AWS ECS. In the Volume part specify the defined EFS. Add the defined volume to the container (Storage and Logging). Finally, you can add as task to the cluster (Logs of the task can be checked to follow the steps)
