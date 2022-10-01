from django.urls import include, path, register_converter 
from django.views.static import serve
from rest_framework import routers
from . import converters, views
import os

register_converter(converters.FloatUrlParameterConverter, 'float')

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FLUTTER_WEB_APP = os.path.join(BASE_DIR, '../build/web/')

def flutter_redirect(request, resource):
    return serve(request, resource, FLUTTER_WEB_APP)

# Wire up our API using automatic URL routing.
# Additionally, we include login URLs for the browsable API.
urlpatterns = [
    path('roadrisk/', lambda r: flutter_redirect(r, 'index.html')),
    path('roadrisk/<path:resource>', flutter_redirect),
    path('Route/Origin=<float:originLat>,<float:originLong>&Destination=<float:destLat>,<float:destLong>', views.RouteView),
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
]
