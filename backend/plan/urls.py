# plan/urls.py (Tạo file này)
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

# DRF Router tự động tạo các URL cho ViewSets (GET, POST, PUT, DELETE)
router = DefaultRouter()
router.register(r'plans', views.PlanViewSet, basename='plan')
router.register(r'history-inputs', views.HistoryInputViewSet, basename='historyinput')

urlpatterns = [
    # Các URL do Router tạo:
    # /api/plans/ (GET, POST)
    # /api/plans/<id>/ (GET, PUT, DELETE)
    # /api/history-inputs/ (GET, POST)
    path('', include(router.urls)),

    # URL tùy chỉnh cho việc gợi ý Route
    # /api/routes/suggested/ (GET)
    path('routes/suggested/',
         views.RouteSuggestionView.as_view(),
         name='route-suggestion'),
]