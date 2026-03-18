import uuid
from django.db import models
from django.conf import settings

class NotificationLog(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='notifications'
    )
    title = models.CharField(max_length=200)
    body = models.TextField()
    notification_type = models.CharField(max_length=50)
    data = models.JSONField(default=dict, blank=True)
    
    fcm_response_id = models.CharField(max_length=255, blank=True, null=True)
    is_sent = models.BooleanField(default=False)
    is_read = models.BooleanField(default=False)
    
    sent_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} to {self.user.email}"
