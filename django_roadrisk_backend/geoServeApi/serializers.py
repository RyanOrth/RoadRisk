from rest_framework import serializers

from .models import Route

class RouteSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Route
        fields = ('totalDistance', 'totalDurationInMin', 'bounds', 'polylinePoints')