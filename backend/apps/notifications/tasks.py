from celery import shared_task
from django.contrib.auth import get_user_model
from integrations.notifications import PushNotificationService

User = get_user_model()

@shared_task(name='notifications.send_push_notification')
def send_push_notification_task(user_id, title, body, data=None, notification_type=None):
    try:
        user = User.objects.get(id=user_id)
        PushNotificationService.send_push(user, title, body, data, notification_type)
        return True
    except User.DoesNotExist:
        return False
    except Exception as e:
        return str(e)
