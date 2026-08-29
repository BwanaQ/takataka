from django.db import models

class MaterialBatch(models.Model):
    reference = models.CharField(max_length=40, unique=True)
    material = models.ForeignKey("materials.Material", on_delete=models.PROTECT)
    quantity_kg = models.DecimalField(max_digits=12, decimal_places=3)
    created_at = models.DateTimeField(auto_now_add=True)

class MaterialEvent(models.Model):
    class EventType(models.TextChoices):
        COLLECTED = "COLLECTED", "Collected"
        SORTED = "SORTED", "Sorted"
        TRANSFERRED = "TRANSFERRED", "Transferred"
        PROCESSED = "PROCESSED", "Processed"
        RECOVERED = "RECOVERED", "Recovered"

    batch = models.ForeignKey(MaterialBatch, on_delete=models.CASCADE, related_name="events")
    event_type = models.CharField(max_length=20, choices=EventType.choices)
    quantity_kg = models.DecimalField(max_digits=12, decimal_places=3)
    recorded_at = models.DateTimeField(auto_now_add=True)
