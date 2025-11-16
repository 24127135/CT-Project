from rest_framework import generics, permissions
from .serializers import UserRegisterSerializer

class RegisterView(generics.CreateAPIView):
    """
    API View để đăng ký một user mới.
    Chỉ cho phép phương thức POST.
    """
    serializer_class = UserRegisterSerializer

    # Ai cũng có thể gọi API này (kể cả khi chưa đăng nhập)
    permission_classes = [permissions.AllowAny]
