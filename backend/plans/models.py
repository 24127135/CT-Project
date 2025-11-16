from django.db import models
# Cảnh báo: Tệp này phụ thuộc vào `users` và `routes`.
# Đảm bảo BE 1 & BE 2 commit code của họ lên Git trước
# để BE 3 có thể `import` mà không bị lỗi.
from users.models import User
from routes.models import Route

class Equipment(models.Model):
    name = models.CharField(max_length=255, unique=True)
    category = models.CharField(max_length=100) # 'Apparel', 'Safety', etc.
    base_price = models.FloatField(default=0)

    def __str__(self):
        return self.name

class Plan(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    route = models.ForeignKey(Route, on_delete=models.CASCADE)
    plan_name = models.CharField(max_length=255)
    start_date = models.DateField()
    duration_days = models.IntegerField()
    group_size = models.IntegerField(default=1)
    budget = models.CharField(max_length=100, blank=True, null=True)
    equipment_list_state = models.JSONField(blank=True, null=True) # Stores the checklist JSON

    def __str__(self):
        return f"{self.plan_name} by {self.user.email}"
