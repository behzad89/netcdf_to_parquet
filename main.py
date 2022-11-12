# Name: training_validation_process.py
# Description: Pipeline for process and convert NetCDF file into parquet file
# Author: Behzad Valipour Sh. <b.valipour.sh@gmail.com>
# Date:11.11.2022

import argparse
import logging
import multiprocessing as mp
import os
from functools import partial
from typing import List, Optional

import coloredlogs
import h3.api.numpy_int as h3
import numpy as np
import pandas as pd
import pyarrow as pa
import pyarrow.compute as pc
import pyarrow.parquet as pq
import s3fs
import xarray as xr

# Constants
logger = logging.getLogger(__name__)

coloredlogs.install(fmt="%(levelname)s:%(message)s", level="INFO",
                    level_styles={"info": {"color": "white"},
                                  "error": {"color": "red"},
                                  "warning": {"color": "yellow"}})
BUCKET = "era5-pds" 

def _read_obj_from_s3(s3path: str):
    # e.g. s3path = 'era5-pds/2022/05/data/precipitation_amount_1hour_Accumulation.nc'
    fs_s3 = s3fs.S3FileSystem(anon=True)
    remote_file_obj = fs_s3.open(s3path, mode='rb')
    return remote_file_obj

def _geo_to_h3_array(coordinates, resolution: int) -> List[int]:
    hexes = [h3.geo_to_h3(coordinates[i, 0], coordinates[i, 1], resolution) for i in range(coordinates.shape[0])]
    return hexes


def _H3Index(coordinates: np.ndarray, resolution: int = 10) -> np.ndarray:
    cpus = mp.cpu_count()
    arrays = np.array_split(coordinates, cpus)
    fn = partial(_geo_to_h3_array, resolution=resolution)
    with mp.Pool(processes=cpus) as pool:
        results = pool.map(fn, arrays)
    flattened = [item for sublist in results for item in sublist]
    h3arr = np.array(flattened, dtype=np.uint64)
    return h3arr

def convert_netCDF_to_parquet(file_path, output_path: str, timestamp_filter: Optional[tuple] = None, spatial_filter: Optional[tuple] = None, resolution: int = 10):
    """Convert the downloaded netCDF file to parquet """

    # Read file & extract corrosponding info
    logger.info("Reading climate file from %s",BUCKET)
    ds = xr.open_dataset(file_path,engine='h5netcdf')
    variable_name = list(ds.keys())[1]
    list_coords = list(ds.coords)

    if timestamp_filter is not None:
        logger.info("Filtering datestampe between %s & %s", timestamp_filter[0], timestamp_filter[1])
        filter = {list_coords[2]: slice(
            timestamp_filter[0], timestamp_filter[1])}
        ds = ds.sel(filter)

    logger.info("Extract coordinates & value")
    latitudes = ds[list_coords[0]].values
    longitudes = ds[list_coords[1]].values
    times = ds[list_coords[2]].values
    ds_values = ds[variable_name].values
    coordinates = np.vstack((latitudes,longitudes)).T

    # Apply spatial index
    logger.info("Apply Spatial Index")
    IndxH3 = _H3Index(coordinates=coordinates,resolution=resolution)

    table = pa.Table.from_arrays([IndxH3,times,ds_values], names=[f'h3Index_{resolution}','time',f'{variable_name}'])

    if spatial_filter is not None:
        logger.info("Apply Spatial Filter")
        h3IndexValue = h3.geo_to_h3(spatial_filter[0],spatial_filter[1], resolution=resolution)
        expr = (pc.field("h3Index") == h3IndexValue)
        table = table.filter(expr)

    return pq.write_table(table, f'{output_path}.parquet')

def main():
    parser = argparse.ArgumentParser(description="Transform the data into the Apache Parquet datasource")

    parser.add_argument("--file_name", help="The file name e.g. precipitation_amount_1hour_Accumulation.nc",type=str, required=True)
    parser.add_argument("--date", help="Timestamp of data as YYYY_MM",type=str, required=True)
    parser.add_argument("--timestamp_filter", nargs=2,metavar=('StartDate', 'EndDate'), help="Filtering by timestamp.",type=str, default=(None,None))
    parser.add_argument("--spatial_filter", nargs=2,metavar=('latitude', 'longitude'), help="Filtering by coordinates.",type=str, default=(None,None))
    parser.add_argument("--resolution", help="Hierarchical geospatial index of your choice.",type=int,default=10,required=False)
    parser.add_argument("--output_path", help="Path to save the parquet file.",type=str,required=True)

    # Arguments
    args = parser.parse_args()
    FILE = args.file_name
    StartDate, EndDate = args.timestamp_filter
    lat, lon = args.spatial_filter
    RESOLUTION = args.resolution
    OUTPATH = args.output_path
    DATE = args.date

    # Main code
    KEY = f"{DATE.split('-')[0]}/{DATE.split('-')[1]}/data/{FILE}"
    FILE_PATH = _read_obj_from_s3(os.path.join(BUCKET, KEY))
    convert_netCDF_to_parquet(FILE_PATH, OUTPATH, (StartDate, EndDate), (lat, lon), RESOLUTION)
    logger.info("File was save in %s",OUTPATH)

if __name__ == "__main__":
    main()