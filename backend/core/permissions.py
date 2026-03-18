from rest_framework import permissions

class IsProvider(permissions.BasePermission):
    def has_permission(self, request, view):
        return bool(request.user and request.user.user_type == 'provider')

class IsClient(permissions.BasePermission):
    def has_permission(self, request, view):
        return bool(request.user and request.user.user_type == 'client')

class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Depends on the object type
        if hasattr(obj, 'provider'):
            return obj.provider == request.user
        if hasattr(obj, 'client'):
            return obj.client == request.user
        return False
