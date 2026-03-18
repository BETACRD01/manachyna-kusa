import uuid
from django.db import models
from django.db.models import Avg
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.marketplace.models import ServiceRequest, Service

class Review(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    service_request = models.OneToOneField(
        ServiceRequest, 
        on_delete=models.CASCADE, 
        related_name='review'
    )
    reviewer = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='reviews_given'
    )
    reviewed = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='reviews_received'
    )
    rating = models.PositiveSmallIntegerField(
        choices=[(i, str(i)) for i in range(1, 6)]
    )
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Review {self.rating}* by {self.reviewer.email}"

@receiver(post_save, sender=Review)
def update_user_service_rating(sender, instance, created, **kwargs):
    if created:
        # Update Service Rating
        service = instance.service_request.service
        service_reviews = Review.objects.filter(service_request__service=service)
        service.rating_average = service_reviews.aggregate(Avg('rating'))['rating__avg']
        service.total_reviews = service_reviews.count()
        service.save()

        # Update Provider Rating
        provider = instance.reviewed
        all_reviews = Review.objects.filter(reviewed=provider)
        provider.rating_average = all_reviews.aggregate(Avg('rating'))['rating__avg']
        provider.save()
