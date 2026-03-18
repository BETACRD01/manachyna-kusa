from rest_framework import serializers
from apps.reviews.models import Review
from apps.users.api.v1.serializers import UserSerializer

class ReviewSerializer(serializers.ModelSerializer):
    reviewer = UserSerializer(read_only=True)
    
    class Meta:
        model = Review
        fields = '__all__'
        read_only_fields = ('reviewer', 'reviewed', 'created_at')

    def validate(self, data):
        request = self.context['request']
        service_request = data.get('service_request')
        
        if service_request.status != 'completed':
            raise serializers.ValidationError("Only completed services can be reviewed.")
            
        if Review.objects.filter(service_request=service_request).exists():
            raise serializers.ValidationError("This service has already been reviewed.")
            
        return data

    def create(self, validated_data):
        service_request = validated_data['service_request']
        validated_data['reviewer'] = self.context['request'].user
        validated_data['reviewed'] = service_request.provider
        return super().create(validated_data)
