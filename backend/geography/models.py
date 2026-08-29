from django.contrib.gis.db import models

class County(models.Model):
    name = models.CharField(max_length=120)
    code = models.CharField(max_length=20, unique=True)
    geometry = models.MultiPolygonField(srid=4326, null=True, blank=True)

    def __str__(self):
        return f"{self.name} ({self.code})"

class Ward(models.Model):
    county = models.ForeignKey(County, on_delete=models.CASCADE, related_name="wards")
    name = models.CharField(max_length=120)
    code = models.CharField(max_length=30, unique=True)
    geometry = models.MultiPolygonField(srid=4326, null=True, blank=True)

    def __str__(self):
        return self.name
