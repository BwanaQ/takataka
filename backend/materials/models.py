from django.db import models

class Material(models.Model):
    name = models.CharField(max_length=120, unique=True)
    category = models.CharField(max_length=120)
    recyclable = models.BooleanField(default=True)
    description = models.TextField(blank=True)

    def __str__(self):
        return self.name
