import logging
from firebase_admin import messaging
from .models import NotificationLog
from django.utils import timezone

logger = logging.getLogger(__name__)

class PushNotificationService:
    @staticmethod
    def send_push(user, title, body, data=None, notification_type=None):
        if not user.fcm_token:
            logger.warning(f"User {user.email} has no FCM token. Skipping notification.")
            return None

        # Prepare message
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=user.fcm_token,
        )

        try:
            # Send message
            response = messaging.send(message)
            
            # Log notification
            NotificationLog.objects.create(
                user=user,
                title=title,
                body=body,
                notification_type=notification_type or 'general',
                data=data or {},
                fcm_response_id=response,
                is_sent=True,
                sent_at=timezone.now()
            )
            return response
        except Exception as e:
            logger.error(f"FCM Error: {e}")
            NotificationLog.objects.create(
                user=user,
                title=title,
                body=body,
                notification_type=notification_type or 'error',
                data={'error': str(e)},
                is_sent=False
            )
            return None
