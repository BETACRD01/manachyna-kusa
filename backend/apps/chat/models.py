import uuid
from django.db import models
from django.conf import settings
from apps.marketplace.models import ServiceRequest

class ChatRoom(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    service_request = models.OneToOneField(
        ServiceRequest, 
        on_delete=models.CASCADE, 
        related_name='chat_room'
    )
    participants = models.ManyToManyField(
        settings.AUTH_USER_MODEL, 
        related_name='chat_rooms'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    last_message_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-last_message_at']

    def __str__(self):
        return f"Chat for Request {self.service_request.id}"

class Message(models.Model):
    class MessageType(models.TextChoices):
        TEXT = 'text', 'Texto'
        AUDIO = 'audio', 'Audio'
        IMAGE = 'image', 'Imagen'
        LOCATION = 'location', 'Ubicación'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    room = models.ForeignKey(
        ChatRoom, 
        on_delete=models.CASCADE, 
        related_name='messages'
    )
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='messages_sent'
    )
    message_type = models.CharField(
        max_length=15, 
        choices=MessageType.choices, 
        default=MessageType.TEXT
    )
    content = models.TextField(blank=True)
    
    audio_file = models.FileField(upload_to='chat/audio/', null=True, blank=True)
    image_file = models.ImageField(upload_to='chat/images/', null=True, blank=True)
    
    latitude = models.DecimalField(max_digits=12, decimal_places=9, null=True, blank=True)
    longitude = models.DecimalField(max_digits=12, decimal_places=9, null=True, blank=True)
    
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"Message by {self.sender.email} at {self.created_at}"
