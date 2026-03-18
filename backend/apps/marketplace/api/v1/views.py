from django.contrib.gis.geos import Point
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.measure import D
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from core.mixins import StandardResponseMixin
from apps.marketplace.models import ServiceCategory, Service, ServiceRequest
from .serializers import (
    ServiceCategorySerializer, 
    ServiceSerializer, 
    ServiceRequestSerializer
)

class ServiceCategoryViewSet(StandardResponseMixin, viewsets.ReadOnlyModelViewSet):
    queryset = ServiceCategory.objects.filter(is_active=True)
    serializer_class = ServiceCategorySerializer
    permission_classes = [permissions.AllowAny]

class ServiceViewSet(StandardResponseMixin, viewsets.ModelViewSet):
    queryset = Service.objects.filter(is_active=True)
    serializer_class = ServiceSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['category', 'price_type']

    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'nearby']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        lat = request.query_params.get('latitude')
        lon = request.query_params.get('longitude')
        radius = request.query_params.get('radius', 10)  # Default 10km

        if not lat or not lon:
            return Response(
                {"error": "Latitude and longitude are required"}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        user_location = Point(float(lon), float(lat), srid=43200) # Use appropriate SRID
        
        services = Service.objects.filter(
            location__distance_lte=(user_location, D(km=radius))
        ).annotate(
            distance=Distance('location', user_location)
        ).order_by('distance')

        serializer = self.get_serializer(services, many=True)
        return Response(serializer.data)

class ServiceRequestViewSet(StandardResponseMixin, viewsets.ModelViewSet):
    serializer_class = ServiceRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'provider':
            return ServiceRequest.objects.filter(provider=user)
        return ServiceRequest.objects.filter(client=user)

    @action(detail=True, methods=['put'], url_path='status')
    def update_status(self, request, pk=None):
        instance = self.get_object()
        new_status = request.data.get('status')
        if new_status not in ServiceRequest.Status.values:
            return Response({"error": "Invalid status"}, status=status.HTTP_400_BAD_REQUEST)
        
        instance.status = new_status
        instance.save()
        
        # Here we could trigger a notification
        return Response(self.get_serializer(instance).data)
