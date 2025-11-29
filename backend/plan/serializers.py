from rest_framework import serializers
from .models import Plan, Route, HistoryInput

# 1. RouteSerializer (Đây là cái bạn đang thiếu)
class RouteSerializer(serializers.ModelSerializer):
    """
    Serializer để HIỂN THỊ các lộ trình phù hợp
    """
    class Meta:
        model = Route
        fields = '__all__'

# 2. HistoryInputSerializer
class HistoryInputSerializer(serializers.ModelSerializer):
    """
    Serializer để TẠO "Mẫu nhập nhanh"
    """
    class Meta:
        model = HistoryInput
        exclude = ['user']

# 3. PlanSerializer (Đã sửa lỗi dangers_snapshot)
class PlanSerializer(serializers.ModelSerializer):
    """
    Serializer để TẠO một Plan MỚI
    """
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    route = serializers.PrimaryKeyRelatedField(queryset=Route.objects.all())

    class Meta:
        model = Plan
        # Khớp với tên cột trong Database mà chúng ta đã sửa
        read_only_fields = ['personalized_equipment_list', 'dangers_snapshot']
        fields = '__all__'

    def create(self, validated_data):
        """
        Ghi đè hàm create để gọi các service AI
        """
        # 1. Mô phỏng dịch vụ tạo equipment
        mock_equipment_list = {
            "Gear": [{"item": "Backpack", "qty": 1, "note": "30-40L recommended"}],
            "Safety": [{"item": "First Aid Kit", "qty": 1, "note": "Essential"}]
        }

        # 2. Mô phỏng dịch vụ phân tích rủi ro
        mock_dangers_list = [
            {"name": "Leech Risk", "detail": "High risk during rainy season."}
        ]

        # Gán vào đúng tên cột trong DB
        validated_data['personalized_equipment_list'] = mock_equipment_list
        validated_data['dangers_snapshot'] = mock_dangers_list

        # Tạo Plan
        plan = Plan.objects.create(**validated_data)
        return plan