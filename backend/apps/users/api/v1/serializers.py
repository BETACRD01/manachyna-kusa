from rest_framework import serializers
from apps.users.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            'id', 'email', 'username', 'phone', 'avatar', 
            'user_type', 'is_verified', 'latitude', 'longitude', 
            'rating_average', 'created_at'
        )
        read_only_fields = ('id', 'is_verified', 'rating_average', 'created_at')

class UserLocationUpdateSerializer(serializers.Serializer):
    latitude = serializers.DecimalField(max_digits=12, decimal_places=9)
    longitude = serializers.DecimalField(max_digits=12, decimal_places=9)

class UserFCMTokenSerializer(serializers.Serializer):
    fcm_token = serializers.CharField(required=True)
