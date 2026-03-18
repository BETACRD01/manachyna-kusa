from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ServiceCategoryViewSet, ServiceViewSet, ServiceRequestViewSet

router = DefaultRouter()
router.register('categories', ServiceCategoryViewSet, basename='categories')
router.register('requests', ServiceRequestViewSet, basename='requests')
router.register('', ServiceViewSet, basename='marketplace')

urlpatterns = [
    path('', include(router.urls)),
]
