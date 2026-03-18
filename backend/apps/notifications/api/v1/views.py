from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from apps.notifications.models import NotificationLog

class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return NotificationLog.objects.filter(user=self.request.user)

    @action(detail=False, methods=['put'], url_path='read-all')
    def read_all(self, request):
        self.get_queryset().filter(is_read=False).update(is_read=True)
        return Response({"success": True})

    @action(detail=True, methods=['put'], url_path='read')
    def mark_as_read(self, request, pk=None):
        instance = self.get_object()
        instance.is_read = True
        instance.save()
        return Response({"success": True})
