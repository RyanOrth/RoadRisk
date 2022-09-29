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
    coords = ((originLong,originLat),(destLong,destLat))
    client = openrouteservice.Client(key='5b3ce3597851110001cf6248157eaf13dcb64422b471b18d03ea2c30') # Specify your personal API key
    routes = client.directions(coords)
    print(routes)

    # Get risk
    risk = 2

    if len(routes['routes'])>0:
        routeJSON = {
            "polyline":routes['routes'][0]['geometry'],
            "decodedPolyline": polyline.decode(routes['routes'][0]['geometry']),
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