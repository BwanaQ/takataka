from django.db import models

class DataSource(models.Model):
    name = models.CharField(max_length=200)
    url = models.URLField(blank=True)
    source_type = models.CharField(max_length=80)
    publication_year = models.PositiveIntegerField(null=True, blank=True)
    methodology = models.TextField(blank=True)
    confidence = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)

    def __str__(self):
        return self.name
