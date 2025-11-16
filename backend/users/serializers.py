from django.contrib.auth import get_user_model
from rest_framework import serializers

# Lấy model User mà chúng ta đã định nghĩa (users.User)
User = get_user_model()

class UserRegisterSerializer(serializers.ModelSerializer):
    """Serializer cho việc tạo (đăng ký) user mới."""

    # Thêm trường password_confirm để xác nhận mật khẩu
    password_confirm = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        # Các trường sẽ được dùng để tạo user
        fields = ('email', 'full_name', 'password', 'password_confirm')
        extra_kwargs = {
            'password': {'write_only': True}, # Mật khẩu chỉ dùng để ghi (không bao giờ trả về)
        }

    def validate(self, data):
        """
        Kiểm tra xem 2 mật khẩu có khớp nhau không.
        """
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Mật khẩu không khớp.")
        return data

    def create(self, validated_data):
        """
        Hàm này được gọi khi .save() được gọi từ View.
        Nó xử lý việc tạo user.
        """
        # Xóa trường password_confirm vì model User không có nó
        validated_data.pop('password_confirm')

        # Dùng hàm create_user mà chúng ta đã định nghĩa trong CustomUserManager
        user = User.objects.create_user(
            email=validated_data['email'],
            full_name=validated_data.get('full_name', ''),
            password=validated_data['password']
        )
        return user