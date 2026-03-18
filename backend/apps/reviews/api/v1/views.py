from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from apps.reviews.models import Review
from .serializers import ReviewSerializer

class ReviewViewSet(viewsets.ModelViewSet):
    queryset = Review.objects.all()
    serializer_class = ReviewSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        user_id = self.request.query_params.get('user')
        if user_id:
            return Review.objects.filter(reviewed_id=user_id)
        return super().get_queryset()

    def perform_create(self, serializer):
        serializer.save()
