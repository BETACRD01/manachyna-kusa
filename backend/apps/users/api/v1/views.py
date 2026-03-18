from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from core.mixins import StandardResponseMixin
from apps.users.models import User
from .serializers import (
    UserSerializer, 
    UserLocationUpdateSerializer, 
    UserFCMTokenSerializer
)

class UserViewSet(StandardResponseMixin, viewsets.GenericViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get', 'put', 'patch'], url_path='profile')
    def profile(self, request):
        user = request.user
        if request.method == 'GET':
            serializer = self.get_serializer(user)
            return Response(serializer.data)
        
        serializer = self.get_serializer(user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    @action(detail=False, methods=['post'], url_path='sync')
    def sync_firebase(self, request):
        # The user is already authenticated and created by FirebaseAuthentication middleware
        serializer = self.get_serializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['put'], url_path='fcm-token')
    def update_fcm_token(self, request):
        serializer = UserFCMTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        request.user.fcm_token = serializer.validated_data['fcm_token']
        request.user.save()
        return Response({'success': True, 'message': 'FCM token updated'})

    @action(detail=False, methods=['put'], url_path='location')
    def update_location(self, request):
        serializer = UserLocationUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        request.user.update_location(
            serializer.validated_data['latitude'],
            serializer.validated_data['longitude']
        )
        return Response({'success': True, 'message': 'Location updated'})
