from django.urls import include, path, register_converter 
from rest_framework import routers
from . import converters, views

register_converter(converters.FloatUrlParameterConverter, 'float')
register_converter(converters.BooleanUrlParameterConverter, 'bool')

# Wire up our API using automatic URL routing.
# Additionally, we include login URLs for the browsable API.
urlpatterns = [
    #path('', include(router.urls)),
    path('Route/Origin=<float:originLat>,<float:originLong>&Destination=<float:destLat>,<float:destLong>&AlternateRoutes=<bool:getAlts>', views.RouteView),
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
]