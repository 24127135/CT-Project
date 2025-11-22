from django.urls import path
from .views import RegisterView, LoginView, VerifyOTPView, TripTemplateListCreateView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    
    # New Endpoint for Fast Input
    path('templates/', TripTemplateListCreateView.as_view(), name='trip-templates'),
]