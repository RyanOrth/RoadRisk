import geopandas as gpd
import pandas as pd
import math
from pyproj import Proj, transform

def findClosestMatch(requestedCoords, possibleMatches: pd.DataFrame):
    result = None

    indexOfClosestCoordinate = None
    distanceBetweenRequested = math.inf

    for index, row in possibleMatches.iterrows():
        for coordinate in row['geometry'][0].coords:
            distance = math.sqrt(((requestedCoords[0] - coordinate[0])**2) + ((requestedCoords[1] - coordinate[1])**2))
            if distance < distanceBetweenRequested:
                distanceBetweenRequested = distance
                indexOfClosestCoordinate = index

    print('Min Distance =', distanceBetweenRequested)

    result = possibleMatches.loc[indexOfClosestCoordinate]

    return result


def queryCoordinatePair(coords, gdf: gpd.GeoDataFrame):
    inProj = Proj(init='epsg:3857')
    outProj = Proj(init='epsg:26918')

    coords[0],coords[1] = transform(inProj, outProj, coords[0], coords[1])

    results = gdf.query(f'{coords[0]} >= minLat and {coords[0]} <= maxLat and {coords[1]} >= minLong and {coords[1]} <= maxLong')

    finalResult = findClosestMatch(coords, results)

    return finalResult


def main():
    gdf = gpd.read_file('NYSDOT_Data.gpkg')

    print('Data Loaded')

    gdf = gdf.astype({'minLat': float})
    gdf = gdf.astype({'maxLat': float})
    gdf = gdf.astype({'minLong': float})
    gdf = gdf.astype({'maxLong': float})


    print('Query:')
    coords = input().split()
    while coords != ['quit']:
        finalResult = queryCoordinatePair(coords, gdf)

        print('Final Result')
        print(finalResult.RoadwayName)
        print(finalResult)

        print('Query:')
        coords = input().split()


if __name__ == '__main__':
    main()

# From GeoData:
# EPSG 26918
# (595165.7300000004 4523528.34)
# EPSG 3857
# (-8223269.300130469 4991314.40974841)
