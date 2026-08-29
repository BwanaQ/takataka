from django.contrib.gis.db import models

class WasteListing(models.Model):
    class Status(models.TextChoices):
        OPEN = "OPEN", "Open"
        MATCHED = "MATCHED", "Matched"
        COLLECTED = "COLLECTED", "Collected"
        CLOSED = "CLOSED", "Closed"

    material = models.ForeignKey("materials.Material", on_delete=models.PROTECT)
    quantity_kg = models.DecimalField(max_digits=12, decimal_places=3)
    location = models.PointField(srid=4326)
    description = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.OPEN)
    created_at = models.DateTimeField(auto_now_add=True)
