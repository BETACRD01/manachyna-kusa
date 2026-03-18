from rest_framework import serializers
from apps.chat.models import ChatRoom, Message
from apps.users.api.v1.serializers import UserSerializer

class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    
    class Meta:
        model = Message
        fields = '__all__'
        read_only_fields = ('sender', 'room', 'created_at')

class ChatRoomSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()
    service_request_status = serializers.ReadOnlyField(source='service_request.status')

    class Meta:
        model = ChatRoom
        fields = '__all__'

    def get_last_message(self, obj):
        msg = obj.messages.order_by('-created_at').first()
        if msg:
            return MessageSerializer(msg).data
        return None
