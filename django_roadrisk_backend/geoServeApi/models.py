from django.db import models

# Create your models here.
class Route(models.Model):
    totalDistance = models.CharField(max_length=60)
    totalDurationInMin = models.FloatField()
    bounds = models.CharField(max_length=60)
    polylinePoints = models.CharField(max_length=60) # as google defined polyline points string
    def __str__(self):
        return self.polylinePoints