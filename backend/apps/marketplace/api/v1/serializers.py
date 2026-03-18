from rest_framework import serializers
from django.contrib.gis.geos import Point
from apps.marketplace.models import ServiceCategory, Service, ServiceRequest
from apps.users.api.v1.serializers import UserSerializer

class ServiceCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceCategory
        fields = '__all__'

class ServiceSerializer(serializers.ModelSerializer):
    provider = UserSerializer(read_only=True)
    category_name = serializers.ReadOnlyField(source='category.name')
    distance = serializers.FloatField(read_only=True, required=False)

    class Meta:
        model = Service
        fields = (
            'id', 'provider', 'category', 'category_name', 
            'title', 'description', 'price', 'price_type',
            'latitude', 'longitude', 'radius_km', 'is_active',
            'rating_average', 'total_reviews', 'distance', 'created_at'
        )
        read_only_fields = ('rating_average', 'total_reviews', 'created_at')

    def create(self, validated_data):
        lat = validated_data.get('latitude')
        lon = validated_data.get('longitude')
        validated_data['location'] = Point(float(lon), float(lat))
        validated_data['provider'] = self.context['request'].user
        return super().create(validated_data)

class ServiceRequestSerializer(serializers.ModelSerializer):
    client = UserSerializer(read_only=True)
    provider = UserSerializer(read_only=True)
    service_title = serializers.ReadOnlyField(source='service.title')

    class Meta:
        model = ServiceRequest
        fields = '__all__'
        read_only_fields = ('client', 'provider', 'status', 'created_at')

    def create(self, validated_data):
        lat = validated_data.get('latitude')
        lon = validated_data.get('longitude')
        validated_data['location'] = Point(float(lon), float(lat))
        validated_data['client'] = self.context['request'].user
        # Provider is the owner of the service
        validated_data['provider'] = validated_data['service'].provider
        return super().create(validated_data)
