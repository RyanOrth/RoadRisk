# Import libraries
import googlemaps
from datetime import datetime
from .models import Route
from django.http import JsonResponse
import polyline

def RouteView(request, originLat, originLong, destLat, destLong):
    return_dictionary = {}
    # Init client
    gmaps = googlemaps.Client(key="AIzaSyAExn3Qa217QIG0it7y5KwFWWPkJmTgcF4")

    # Request directions
    now = datetime.now()
    directions_result = gmaps.directions(f"{originLat},{originLong}", f"{destLat},{destLong}", mode="driving", departure_time=now) #avoid='tolls'
    print(directions_result)
    if len(directions_result)>0:
        # Get distance
        total_distance = 0
        total_duration = 0
        legs = directions_result[0].get("legs")
        for leg in legs:
            total_distance += leg.get("distance").get("value") #in meters
            total_duration += leg.get("duration").get("value") #in seconds
        total_duration /= 60 # needs to be in minutes
        routeJSON = {
            "bounds":directions_result[0]["bounds"],
            "polyline":directions_result[0]["overview_polyline"]['points'],
            "decodedPolyline": polyline.decode(directions_result[0]["overview_polyline"]["points"]),
            "totalDistance":total_distance,
            "totalDuration":total_duration
        }
        return JsonResponse(routeJSON)
    else:
        routeJSON = {
            "bounds":0,
            "polyline":0,
            "totalDistance":0,
            "totalDuration":0
        }
        return JsonResponse(routeJSON)