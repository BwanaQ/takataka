from django.db import models

class Organisation(models.Model):
    class OrganisationType(models.TextChoices):
        COUNTY = "COUNTY", "County Government"
        COLLECTOR = "COLLECTOR", "Collector"
        PROCESSOR = "PROCESSOR", "Processor"
        GENERATOR = "GENERATOR", "Generator"
        CBO = "CBO", "Community-Based Organisation"
        OTHER = "OTHER", "Other"

    name = models.CharField(max_length=200)
    organisation_type = models.CharField(max_length=30, choices=OrganisationType.choices)
    verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
