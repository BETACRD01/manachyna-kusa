import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import ChatRoom, Message

logger = logging.getLogger(__name__)

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_group_name = f'chat_{self.room_id}'
        self.user = self.scope['user']

        if not self.user.is_authenticated:
            await self.close()
            return

        # Check if user is participant
        if not await self.is_participant(self.user, self.room_id):
            await self.close()
            return

        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message_type = data.get('type', 'text')
        content = data.get('content', '')

        # Save message to DB
        msg = await self.create_message(
            self.user, 
            self.room_id, 
            message_type, 
            data
        )

        # Send to group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message_id': str(msg.id),
                'sender_id': str(self.user.id),
                'message_type': message_type,
                'content': content,
                'created_at': msg.created_at.isoformat(),
                # Include other fields like lat/lon if needed
            }
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event))

    @database_sync_to_async
    def is_participant(self, user, room_id):
        return ChatRoom.objects.filter(id=room_id, participants=user).exists()

    @database_sync_to_async
    def create_message(self, user, room_id, msg_type, data):
        room = ChatRoom.objects.get(id=room_id)
        msg = Message.objects.create(
            room=room,
            sender=user,
            message_type=msg_type,
            content=data.get('content', ''),
            latitude=data.get('latitude'),
            longitude=data.get('longitude')
        )
        return msg
