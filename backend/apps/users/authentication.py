import logging
import firebase_admin
from firebase_admin import auth, credentials
from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework import authentication, exceptions

logger = logging.getLogger(__name__)
User = get_user_model()

# Initialize Firebase Admin
try:
    if not firebase_admin._apps:
        # Expecting FIREBASE_CREDENTIALS_PATH in settings
        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
        firebase_admin.initialize_app(cred)
except Exception as e:
    logger.error(f"Error initializing Firebase Admin: {e}")

class FirebaseAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        if not auth_header:
            return None

        id_token = auth_header.split(' ').pop()
        try:
            decoded_token = auth.verify_id_token(id_token)
            uid = decoded_token.get('uid')
        except Exception as e:
            logger.warning(f"Firebase token verification failed: {e}")
            raise exceptions.AuthenticationFailed('Invalid token')

        if not uid:
            raise exceptions.AuthenticationFailed('UID not found in token')

        user, created = User.objects.get_or_create(
            firebase_uid=uid,
            defaults={
                'email': decoded_token.get('email', f"{uid}@firebase.com"),
                'username': decoded_token.get('email', uid),
                'is_active': True,
            }
        )
        
        # Proactively update info if it's missing
        if not user.email and decoded_token.get('email'):
            user.email = decoded_token.get('email')
            user.save()

        return (user, None)
