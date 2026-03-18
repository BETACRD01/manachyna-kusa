from rest_framework import serializers
from apps.payments.models import Payment

class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = '__all__'
        read_only_fields = ('id', 'paid_at', 'created_at')

    def create(self, validated_data):
        if validated_data.get('status') == 'completed':
            from django.utils import timezone
            validated_data['paid_at'] = timezone.now()
        return super().create(validated_data)
