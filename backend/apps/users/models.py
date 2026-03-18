import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.gis.db import models as gis_models
from django.core.validators import MinValueValidator, MaxValueValidator

class User(AbstractUser):
    class UserType(models.TextChoices):
        CLIENT = 'client', 'Cliente'
        PROVIDER = 'provider', 'Proveedor'
        ADMIN = 'admin', 'Administrador'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    fcm_token = models.TextField(blank=True, null=True)
    firebase_uid = models.CharField(max_length=128, unique=True)
    user_type = models.CharField(
        max_length=10, 
        choices=UserType.choices, 
        default=UserType.CLIENT
    )
    is_verified = models.BooleanField(default=False)
    
    # Location using PostGIS
    location = gis_models.PointField(null=True, blank=True)
    latitude = models.DecimalField(max_digits=12, decimal_places=9, null=True, blank=True)
    longitude = models.DecimalField(max_digits=12, decimal_places=9, null=True, blank=True)
    
    rating_average = models.DecimalField(
        max_digits=3, decimal_places=2, default=0.00,
        validators=[MinValueValidator(0), MaxValueValidator(5)]
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    REQUIRED_FIELDS = ['email', 'firebase_uid']

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.email} ({self.user_type})"

    def update_location(self, lat, lon):
        from django.contrib.gis.geos import Point
        self.latitude = lat
        self.longitude = lon
        self.location = Point(float(lon), float(lat))
        self.save()
