import numpy as np
import pandas as pd
import os
import pickle
from datetime import datetime

cluster_columns_dict = {
    "pickup": ["pickup_longitude", "pickup_latitude"],
    "dropoff": ["dropoff_longitude", "dropoff_latitude"],
    "route": ['l1_distance', 'longitude_diff', 'pickup_longitude', 'dropoff_longitude', 'distance_km', 'latitude_diff', 'pickup_latitude', 'dropoff_latitude']
}

cluster_pickle_dict = {
    "pickup": "clusterer_pickup.pkl",
    "dropoff": "clusterer_dropoff.pkl",
    "route": "clusterer_route.pkl"
}

def load_clusterers(model_folder_path):
    clusterer_dict = {}
    for k,v in cluster_pickle_dict.items():
        pickle_path = os.path.join(model_folder_path, v)
        with open(pickle_path, 'rb') as f:
            clusterer_dict[k] = pickle.load(f)   
    return(clusterer_dict)

def haversine_np(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)

    All args must be of equal length.

    """
    lon1, lat1, lon2, lat2 = map(np.radians, [lon1, lat1, lon2, lat2])

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = np.sin(dlat/2.0)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon/2.0)**2

    c = 2 * np.arcsin(np.sqrt(a))
    km = 6367 * c
    return(km)

def prepare_df(df):
    df["pickup_datetime_parsed"] = pd.to_datetime(df["pickup_datetime"])
    df["pickup_datetime_parsed_dayofweek"] = df["pickup_datetime_parsed"].apply(
        lambda x: datetime.weekday(x) + 1)
    df["pickup_datetime_parsed_hour"] = df["pickup_datetime_parsed"].apply(
        lambda x: x.hour)
    df["distance_km"] = haversine_np(df['pickup_longitude'], df['pickup_latitude'],
                                 df['dropoff_longitude'], df['dropoff_latitude'])
    df["longitude_diff"] = df["pickup_longitude"] - df["dropoff_longitude"]
    df["latitude_diff"] = df["pickup_latitude"] - df["dropoff_latitude"]
    df["l1_distance"] = np.absolute(df["longitude_diff"]) + np.absolute(df["latitude_diff"])
    return(df)
