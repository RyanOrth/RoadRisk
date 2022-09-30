# Import libraries
#import googlemaps
from datetime import datetime
from .models import Route
from django.http import JsonResponse
import polyline
import openrouteservice
import pickle
import numpy as np
from scipy.spatial import distance
import math

file = open('./geoServeApi/accidentPoints.pickle', 'rb')     
accident_latlngs = pickle.load(file)
accident_latlngs = np.array(accident_latlngs)
file.close()

file = open('./geoServeApi/aadtPoints.pickle', 'rb')
aadt_latlng_info = pickle.load(file)
file.close()
aadt_latlngs = [x[0] for x in aadt_latlng_info]
aadt_latlngs = np.array(aadt_latlngs)
latlng_to_aadt = {f"{x[0][0]},{x[0][1]}":x[1] for x in aadt_latlng_info}

def closest_point(point, points):
    closest_index = distance.cdist([point], points).argmin()
    return points[closest_index]

def distance_between_points(p1, p2):
    return math.sqrt((p1[0]-p2[0])**2 + (p1[1]-p2[1])**2)

def risk_along_path(points):
    aadts = []
    accidents_on_route = set()
    for point in points:
        closest_accident = closest_point(point, accident_latlngs)
        if distance_between_points(point, closest_accident) <= 0.00039: # 0.000385 is a bit less than a quarter block
            accidents_on_route.add((closest_accident[0], closest_accident[1]))
        closest_road_point = closest_point(point, aadt_latlngs)
        aadts.append(latlng_to_aadt[f"{closest_road_point[0]},{closest_road_point[1]}"])
    return len(accidents_on_route)/(sum(aadts)/len(aadts)) # accidents/avg(aadt)

print("Risk datasets import complete")

def RouteView(request, originLat, originLong, destLat, destLong):
    return_dictionary = {}
    # Init client
    coords = ((originLong,originLat),(destLong,destLat))
    client = openrouteservice.Client(key='5b3ce3597851110001cf6248157eaf13dcb64422b471b18d03ea2c30') # Specify your personal API key
    routes = client.directions(coords)
    #print(routes)

    # Get risk
    decoded_polyline = polyline.decode(routes['routes'][0]['geometry'])
    risk = risk_along_path(decoded_polyline)
    '''calculated that there is always at least a minimum risk of .00001 based on this article and the minimum traffic a road in New York, https://mirmanlawyers.com/new-york-car-accident-lawyer/statistics/#:~:text=a%20NYC%20Crash%3F-,Total%20Reported%20Collisions%20in%20New%20York%20City,every%20single%20day%20in%20NYC'''
    if float(risk) < .00001:
        risk = .00001

    if len(routes['routes'][0]['summary'])>0:
        routeJSON = {
            "polyline":routes['routes'][0]['geometry'],
            "decodedPolyline": decoded_polyline,
            "totalDistance":routes['routes'][0]['summary']['distance'],
            "totalDuration":routes['routes'][0]['summary']['duration']//60,
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