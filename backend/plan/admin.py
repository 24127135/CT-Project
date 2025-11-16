# plan/admin.py
from django.contrib import admin
from .models import Route, Plan, HistoryInput

# Đăng ký các model để hiển thị trên trang admin
admin.site.register(Route)
admin.site.register(Plan)
admin.site.register(HistoryInput)
