from django.db import models
from users.models import User
from routes.models import Route

class Community_Report(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    route = models.ForeignKey(Route, null=True, blank=True, on_delete=models.SET_NULL)
    report_content = models.TextField()
    severity = models.CharField(max_length=50) # 'High', 'Medium', 'Low'
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Report by {self.user.email} on {self.route.name if self.route else 'N/A'}"

class Static_Hazard(models.Model):
    route = models.ForeignKey(Route, related_name='static_hazards', on_delete=models.CASCADE)
    description = models.TextField() # e.g., "Slippery slope"
    condition = models.CharField(max_length=100, blank=True) # e.g., "Rainy season"

    def __str__(self):
        return f"Hazard on {self.route.name}: {self.description}"
