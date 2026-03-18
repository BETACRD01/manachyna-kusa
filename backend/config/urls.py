from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

from core.constants import ApiVersion

api_v1_patterns = [
    path('users/', include('apps.users.api.v1.urls')),
    path('marketplace/', include('apps.marketplace.api.v1.urls')),
    path('reviews/', include('apps.reviews.api.v1.urls')),
    path('chat/', include('apps.chat.api.v1.urls')),
    path('payments/', include('apps.payments.api.v1.urls')),
    path('notifications/', include('apps.notifications.api.v1.urls')),
]

urlpatterns = [
    path('admin/', admin.site.urls),
    path(f'api/{ApiVersion.V1}/', include(api_v1_patterns)),
    
    # OpenAPI Schema
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    
    # Health check
    path('api/health/', lambda r: HttpResponse("OK"), name='health'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += [path('__debug__/', include('debug_toolbar.urls'))]
