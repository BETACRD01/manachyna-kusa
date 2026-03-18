from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChatRoomViewSet

router = DefaultRouter()
router.register('rooms', ChatRoomViewSet, basename='chat_rooms')

urlpatterns = [
    path('', include(router.urls)),
]
