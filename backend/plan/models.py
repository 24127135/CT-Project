# plan/models.py
from django.db import models
from django.conf import settings
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin


class Route(models.Model):
    # Định nghĩa dựa trên Bảng Route [cite: 1329, 1331, 1332]
    name = models.CharField(max_length=255)
    description = models.TextField()
    total_distance_km = models.FloatField()
    elevation_gain_m = models.FloatField()
    path_coordinates = models.JSONField()
    tags = models.JSONField()  # Rất quan trọng cho việc matching [cite: 1332]
    ai_note = models.TextField(null=True, blank=True)

    image_url = models.URLField(max_length=500, null=True, blank=True)
    gallery = models.JSONField(default=list, blank=True)
    def __str__(self):
        return self.name


class Plan(models.Model):
    # Định nghĩa dựa trên Bảng Plan [cite: 1338, 1342, 1343]
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    route = models.ForeignKey(Route, on_delete=models.SET_NULL, null=True, blank=True)
    name = models.CharField(max_length=255)  # "Đặt tên cho chuyến đi" ở Bước 5/5

    # --- Dữ liệu từ các màn hình Trip Info 1-4 ---
    location = models.TextField()
    rest_type = models.TextField()
    group_size = models.IntegerField()
    start_date = models.DateField()
    duration_days = models.IntegerField()
    difficulty = models.TextField()
    dangers_snapshot = models.JSONField(null=True, blank=True)
    # --- ---

    # Dữ liệu do AI/Service tạo ra [cite: 1343]
    personalized_equipment_list = models.JSONField(null=True, blank=True)
    dangers = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name


class HistoryInput(models.Model):

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)

    # Các trường này sao chép từ Plan, dùng để lưu template
    location = models.TextField()
    rest_type = models.TextField()
    group_size = models.IntegerField()
    start_date = models.DateField()
    duration_days = models.IntegerField()
    difficulty = models.TextField()
    personal_interest = models.JSONField()

    template_name = models.CharField(max_length=255, default="Mẫu nhập nhanh")

    def __str__(self):
        return f"{self.template_name} (của {self.user.email})"