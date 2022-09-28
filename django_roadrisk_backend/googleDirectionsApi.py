# Import libraries
import googlemaps
from datetime import datetime
from pprint import pprint

# Set coords
coords_0 = '43.70721,-79.3955999'
coords_1 = '43.7077599,-79.39294'

# Init client
gmaps = googlemaps.Client(key="AIzaSyAExn3Qa217QIG0it7y5KwFWWPkJmTgcF4")

# Request directions
now = datetime.now()
directions_result = gmaps.directions(coords_0, coords_1, mode="driving", departure_time=now, avoid='tolls')

# Get distance
distance = 0
pprint(directions_result)
legs = directions_result[0].get("legs")
for leg in legs:
    distance = distance + leg.get("distance").get("value")
print(distance) # 222 i.e. 0.2 km