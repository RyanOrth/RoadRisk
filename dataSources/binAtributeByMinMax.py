# -*- coding: utf-8 -*-
from qgis.core import QgsCoordinateReferenceSystem
from qgis.core import QgsCoordinateTransform
from qgis.core import QgsProject
from qgis.core import QgsFeature
from qgis.core import QgsGeometry
from qgis.core import QgsPoint

"""
***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************
"""

from qgis.PyQt.QtCore import QCoreApplication
from qgis.core import (QgsProcessing,
                       QgsFeatureSink,
                       QgsProcessingException,
                       QgsProcessingAlgorithm,
                       QgsProcessingParameterFeatureSource,
                       QgsProcessingParameterFeatureSink)
from qgis import processing


class ExampleProcessingAlgorithm(QgsProcessingAlgorithm):
    """
    This is an example algorithm that takes a vector layer and
    creates a new identical one.

    It is meant to be used as an example of how to create your own
    algorithms and explain methods and variables used to do it. An
    algorithm like this will be available in all elements, and there
    is not need for additional work.

    All Processing algorithms should extend the QgsProcessingAlgorithm
    class.
    """

    # Constants used to refer to parameters and outputs. They will be
    # used when calling the algorithm from another algorithm, or when
    # calling from the QGIS console.

    INPUT = 'INPUT'
    OUTPUT = 'OUTPUT'

    def tr(self, string):
        """
        Returns a translatable string with the self.tr() function.
        """
        return QCoreApplication.translate('Processing', string)

    def createInstance(self):
        return ExampleProcessingAlgorithm()

    def name(self):
        """
        Returns the algorithm name, used for identifying the algorithm. This
        string should be fixed for the algorithm, and must not be localised.
        The name should be unique within each provider. Names should contain
        lowercase alphanumeric characters only and no spaces or other
        formatting characters.
        """
        return 'myscript'

    def displayName(self):
        """
        Returns the translated algorithm name, which should be used for any
        user-visible display of the algorithm name.
        """
        return self.tr('My Script')

    def group(self):
        """
        Returns the name of the group this algorithm belongs to. This string
        should be localised.
        """
        return self.tr('Example scripts')

    def groupId(self):
        """
        Returns the unique ID of the group this algorithm belongs to. This
        string should be fixed for the algorithm, and must not be localised.
        The group id should be unique within each provider. Group id should
        contain lowercase alphanumeric characters only and no spaces or other
        formatting characters.
        """
        return 'examplescripts'

    def shortHelpString(self):
        """
        Returns a localised short helper string for the algorithm. This string
        should provide a basic description about what the algorithm does and the
        parameters and outputs associated with it..
        """
        return self.tr("Example algorithm short description")

    def initAlgorithm(self, config=None):
        """
        Here we define the inputs and output of the algorithm, along
        with some other properties.
        """

        # We add the input vector features source. It can have any kind of
        # geometry.
        self.addParameter(
            QgsProcessingParameterFeatureSource(
                self.INPUT,
                self.tr('Input layer'),
                [QgsProcessing.TypeVectorAnyGeometry]
            )
        )

        # We add a feature sink in which to store our processed features (this
        # usually takes the form of a newly created vector layer when the
        # algorithm is run in QGIS).
        self.addParameter(
            QgsProcessingParameterFeatureSink(
                self.OUTPUT,
                self.tr('Output layer')
                [QgsProcessing.TypeRaster]
            )
        )

    

    def processAlgorithm(self, parameters, context, feedback):
        """
        Here is where the processing itself takes place.
        """
        def generateLatLongHash(lat, long, numberBasketsLat, numberBasketsLong, minLat, maxLat, minLong, maxLong):
            lat = min(lat, maxLat)
            long = min(long, maxLong)
            latitudeKey = (lat-minLat)*(numberBasketsLat/(maxLat-minLat))
            longitudeKey = (long-minLong)*(numberBasketsLong/(maxLat-minLat))
            return f"{int(round(latitudeKey))}, {int(round(longitudeKey))}"
            
        def numPointsInMultiPolyline(multiPolyline):
            numPoints = 0
            for part in multiPolyline:
                numPoints += len(part)
            return numPoints
        
        def evenSpacedPointsOnPolyline(polyline, distTweenPoints, length):
            points = []
            distance = 0
            while distance <= length:
                temp_point = polyline.interpolate(distance)
                points.append(temp_point.asPoint())
                distance += distTweenPoints
            return points

        # Retrieve the feature source and sink. The 'dest_id' variable is used
        # to uniquely identify the feature sink, and must be included in the
        # dictionary returned by the processAlgorithm function.
        source = self.parameterAsSource(
            parameters,
            self.INPUT,
            context
        )

        # If source was not found, throw an exception to indicate that the algorithm
        # encountered a fatal error. The exception text can be any string, but in this
        # case we use the pre-built invalidSourceError method to return a standard
        # helper text for when a source cannot be evaluated
        if source is None:
            raise QgsProcessingException(self.invalidSourceError(parameters, self.INPUT))

        (sink, dest_id) = self.parameterAsSink(
            parameters,
            self.OUTPUT,
            context,
            source.fields(),
            source.wkbType(),
            source.sourceCrs()
        )

        # If sink was not created, throw an exception to indicate that the algorithm
        # encountered a fatal error. The exception text can be any string, but in this
        # case we use the pre-built invalidSinkError method to return a standard
        # helper text for when a sink cannot be evaluated
        if sink is None:
            raise QgsProcessingException(self.invalidSinkError(parameters, self.OUTPUT))
        
        # Compute the number of steps to display within the progress bar and
        # get features from source
        total = 100.0 / source.featureCount() if source.featureCount() else 0
        features = source.getFeatures()
        baseUnits = QgsCoordinateReferenceSystem(26918)
        newUnits = QgsCoordinateReferenceSystem("OGC:CRS84h") #4326==GPS 
        transform = QgsCoordinateTransform(baseUnits, newUnits, QgsProject.instance())
        basketedData = {}
        minLong = -80
        maxLong = -71.5
        minLat = 40
        maxLat = 45.5
        lod = 649.35 # This LOD gets us squares about the size of a block in NYC
        distanceBetweenPointsOnLine = 75 # uses cartesian distance
        numberBasketsLat = int((maxLat-minLat)*lod)
        numberBasketsLong = int((maxLong-minLong)*lod)
        info = {"minLat":minLat, "maxLat":maxLat,
                "minLong":minLong, "maxLong":maxLong,
                "numberBasketsLat":numberBasketsLat,
                "numberBasketsLong":numberBasketsLong,
                "Coordinates":"Lat Long"}
        basketedData["info"] = info
        for current, feature in enumerate(features):
            if feedback.isCanceled():
                break
            if feature.geometry().isEmpty() or feature.geometry().isNull():
                continue
            polyline = feature.geometry().asMultiPolyline()
            #numberOfPointsInLine = numPointsInMultiPolyline(polyline)
            lineGoesThroughBaskets = Set()
            colectionOfPoints = Set()
            for part in polyline:
                synthPolyline = QgsGeometry.fromPolyline([QgsPoint(x) for x in part])
                feat = QgsFeature()
                feat.setGeometry(synthPolyline)
                points = evenSpacedPointsOnPolyline(synthPolyline, distanceBetweenPointsOnLine, feat.geometry().length())
                colectionOfPoints.update(points)
            
            setOfHashes = Set()
            for point in colectionOfPoints:
                latLongPoint = transform.transform(point)
                hash = generateLatLongHash(latLongPoint.x(), latLongPoint.y(), numberBasketsLat, numberBasketsLong, minLat, maxLat, minLong, maxLong)
                setOfHashes.add(hash)

            for hash in setOfHashes:
                if basketedData.get(hash) is None:
                    if isinstance(feature['AADT'], float):
                        basketedData[hash] = int(feature['AADT'])
                else:
                    if isinstance(feature['AADT'], float):
                        basketedData[hash] = int(basketedData[hash])+int(feature['AADT'])

            #if current==1:
                #break
            # Update the progress bar
            feedback.setProgress(int(current * total))
        import json
        import os
        outputDir = "C:\\Users\\gabri\\Downloads\\basketedAADT.json"
        print(f"Out file will be in: {outputDir}")
        with open(outputDir, "w") as outfile:
            json.dump(basketedData, outfile)

        # To run another Processing algorithm as part of this algorithm, you can use
        # processing.run(...). Make sure you pass the current context and feedback
        # to processing.run to ensure that all temporary layer outputs are available
        # to the executed algorithm, and that the executed algorithm can send feedback
        # reports to the user (and correctly handle cancellation and progress reports!)
        if False:
            buffered_layer = processing.run("native:buffer", {
                'INPUT': dest_id,
                'DISTANCE': 1.5,
                'SEGMENTS': 5,
                'END_CAP_STYLE': 0,
                'JOIN_STYLE': 0,
                'MITER_LIMIT': 2,
                'DISSOLVE': False,
                'OUTPUT': 'memory:'
            }, context=context, feedback=feedback)['OUTPUT']

        # Return the results of the algorithm. In this case our only result is
        # the feature sink which contains the processed features, but some
        # algorithms may return multiple feature sinks, calculated numeric
        # statistics, etc. These should all be included in the returned
        # dictionary, with keys matching the feature corresponding parameter
        # or output names.
        return {self.OUTPUT: dest_id}
