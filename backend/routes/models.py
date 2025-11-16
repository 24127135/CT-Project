from django.db import models

class Route(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    total_distance_km = models.FloatField()
    elevation_gain_m = models.FloatField()
    difficulty = models.CharField(max_length=50, blank=True)
    path_coordinates = models.JSONField(blank=True, null=True)
    tags = models.JSONField(default=list, blank=True)
    preference_note = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name

class Waypoint(models.Model):
    route = models.ForeignKey(Route, related_name='waypoints', on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    type = models.CharField(max_length=50) # 'CAMPSITE', 'WATER_SOURCE', etc.
    latitude = models.FloatField()
    longitude = models.FloatField()

class InterestTag(models.Model):
    name = models.CharField(max_length=100, unique=True)
    category = models.CharField(max_length=100, blank=True)

    def __str__(self):
        return self.name

class Route_Tags(models.Model):
    route = models.ForeignKey(Route, on_delete=models.CASCADE)
    tag = models.ForeignKey(InterestTag, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('route', 'tag')
