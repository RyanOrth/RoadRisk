# Import libraries
import googlemaps
from datetime import datetime
from .models import Route
from django.http import JsonResponse
import polyline
import openrouteservice


def RouteView(request, originLat, originLong, destLat, destLong):
    return_dictionary = {}
    # Init client
    #gmaps = googlemaps.Client(key="AIzaSyAExn3Qa217QIG0it7y5KwFWWPkJmTgcF4")

    coords = ((originLong,originLat),(destLong,destLat))
    #coords = ((8.34234,48.23424),(8.34423,48.26424))
    client = openrouteservice.Client(key='5b3ce3597851110001cf6248157eaf13dcb64422b471b18d03ea2c30') # Specify your personal API key
    routes = client.directions(coords)
    print(routes)

    # Request directions
    '''
    now = datetime.now()
    directions_result = gmaps.directions(f"{originLat},{originLong}", f"{destLat},{destLong}", mode="driving", departure_time=now) #avoid='tolls'
    '''

    # Get risk
    risk = 2

    if len(routes['routes'])>0:
        # Get distance
        '''
        total_distance = 0
        total_duration = 0
        legs = directions_result[0].get("legs")
        for leg in legs:
            total_distance += leg.get("distance").get("value") #in meters
            total_duration += leg.get("duration").get("value") #in seconds
        total_duration /= 60 # needs to be in minutes
        '''
        routeJSON = {
            #"bounds":directions_result[0]["bounds"],
            #"polyline":directions_result[0]["overview_polyline"]['points'],
            "polyline":routes['routes'][0]['geometry'],
            #"decodedPolyline": polyline.decode(directions_result[0]["overview_polyline"]["points"]),
            "decodedPolyline": polyline.decode(routes['routes'][0]['geometry']),
            #"totalDistance":total_distance,
            "totalDistance":routes['routes'][0]['summary']['distance'],
            "totalDuration":routes['routes'][0]['summary']['duration'],
            "risk":risk,
        }
        return JsonResponse(routeJSON)
    else:
        routeJSON = {
            "bounds":0,
            "polyline":0,
            "totalDistance":0,
            "totalDuration":0,
            "risk":0,
        }
        return JsonResponse(routeJSON)