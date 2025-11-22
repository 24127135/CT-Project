from django.contrib.auth import get_user_model
from rest_framework import serializers
from .models import TripTemplate

User = get_user_model()

class UserRegisterSerializer(serializers.ModelSerializer):
    password_confirm = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('email', 'full_name', 'password', 'password_confirm')
        extra_kwargs = {
            'password': {'write_only': True},
        }

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Mật khẩu không khớp.")
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(
            email=validated_data['email'],
            full_name=validated_data.get('full_name', ''),
            password=validated_data['password']
        )
        return user

# --- NEW SERIALIZER: TRIP TEMPLATE ---
class TripTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = TripTemplate
        fields = [
            'id', 'name', 'location', 'accommodation', 
            'pax_group', 'duration_days', 'difficulty', 
            'note', 'interests', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

    def validate_name(self, value):
        """
        Check if the user already has a template with this name.
        We need to access 'request.user' from the context.
        """
        user = self.context['request'].user
        if TripTemplate.objects.filter(user=user, name=value).exists():
            raise serializers.ValidationError("Bạn đã có mẫu chuyến đi với tên này. Vui lòng đổi tên khác.")
        return value