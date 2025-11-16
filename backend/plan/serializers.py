# plan/serializers.py
from rest_framework import serializers
from .models import Plan, Route, HistoryInput


class RouteSerializer(serializers.ModelSerializer):
    """
    Serializer để HIỂN THỊ các lộ trình phù hợp (kết quả của Preference Matching)
    """

    class Meta:
        model = Route
        # Chỉ hiển thị các trường tóm tắt cho danh sách gợi ý
        fields = ['id', 'name', 'description', 'total_distance_km', 'elevation_gain_m', 'tags']


class HistoryInputSerializer(serializers.ModelSerializer):
    """
    Serializer để TẠO "Mẫu nhập nhanh" (Lưu mẫu này)
    """
    # Chúng ta muốn user_id là read-only, nó sẽ được gán tự động
    class Meta:
        model = HistoryInput
        # Lấy tất cả các trường NGOẠI TRỪ 'user' (vì 'user' sẽ được gán tự động)
        exclude = ['user']


class PlanSerializer(serializers.ModelSerializer):
    """
    Serializer để TẠO một Plan MỚI (sau khi đã chọn Route)
    """
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    # route_id được gửi từ frontend dưới dạng số (ID)
    route = serializers.PrimaryKeyRelatedField(queryset=Route.objects.all())

    class Meta:
        model = Plan
        # Các trường này là do backend tự tính toán, không nhận từ frontend
        read_only_fields = ['personalized_equipment_list', 'dangers']
        fields = '__all__'

    def create(self, validated_data):
        """
        Ghi đè hàm create để gọi các service AI
        (Mô phỏng PersonalizationEquipmentService và RiskAnalyzer)
        """

        # 1. Mô phỏng dịch vụ tạo equipment [cite: 425, 1441]
        # (Logic thật của bạn sẽ phức tạp hơn)
        mock_equipment_list = {
            "Gear": [{"item": "Backpack", "qty": 1, "note": "30-40L recommended"}],
            "Safety": [{"item": "First Aid Kit", "qty": 1, "note": "Essential"}]
        }

        # 2. Mô phỏng dịch vụ phân tích rủi ro [cite: 425, 1441]
        mock_dangers_list = [
            {"name": "Leech Risk", "detail": "High risk during rainy season."}
        ]

        # Gán dữ liệu đã xử lý vào plan
        validated_data['personalized_equipment_list'] = mock_equipment_list
        validated_data['dangers'] = mock_dangers_list

        # Tạo Plan
        plan = Plan.objects.create(**validated_data)
        return plan