import logging
from channels.db import database_sync_to_async
from firebase_admin import auth
from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser

logger = logging.getLogger(__name__)
User = get_user_model()

@database_sync_to_async
def get_user_from_firebase(token):
    try:
        decoded_token = auth.verify_id_token(token)
        uid = decoded_token.get('uid')
        return User.objects.get(firebase_uid=uid)
    except Exception as e:
        logger.error(f"WebSocket Firebase Auth Error: {e}")
        return AnonymousUser()

class FirebaseAuthMiddleware:
    def __init__(self, inner):
        self.inner = inner

    async def __call__(self, scope, receive, send):
        query_params = scope.get('query_string', b'').decode()
        token = None
        
        for param in query_params.split('&'):
            if param.startswith('token='):
                token = param.split('=')[1]
                break

        if token:
            scope['user'] = await get_user_from_firebase(token)
        else:
            scope['user'] = AnonymousUser()

        return await self.inner(scope, receive, send)
