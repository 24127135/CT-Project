 # plan/views.py
from django.db.models import Q
from rest_framework import viewsets, permissions, generics
from rest_framework.response import Response
from .models import Plan, Route, HistoryInput
from .serializers import PlanSerializer, RouteSerializer, HistoryInputSerializer


# --- Endpoint 1: Gợi ý Lộ trình (Xử lý nút "Xác nhận") ---
# Tương ứng: GET /api/routes/suggested/
class RouteSuggestionView(generics.ListAPIView):
    """
    API View này mô phỏng 'PreferenceMatcherService'.
    Nó nhận thông tin Trip Info 1-4 làm query params và trả về
    danh sách các Routes phù hợp.
    """
    serializer_class = RouteSerializer
    permission_classes = [permissions.IsAuthenticated]

    # def get_queryset(self):
    #     # 1. Lấy dữ liệu từ query params (gửi từ frontend)
    #     # (Ví dụ: /api/routes/suggested/?difficulty=New&location=Thanh%20H%C3%B3a)
    #     params = self.request.query_params
    #
    #     # Dữ liệu từ Trip Info 3/5
    #     difficulty = params.get('difficulty')
    #     # Dữ liệu từ Trip Info 1/5
    #     location = params.get('location')
    #     # Dữ liệu từ Trip Info 4/5 (dạng list, vd: ?interests=Ngắm%20bình%20minh)
    #     interests = params.getlist('interests')
    #
    #     # 2. Bắt đầu lọc
    #     queryset = Route.objects.all()
    #
    #     # 3. Mô phỏng logic matching (logic thật sẽ phức tạp hơn)
    #     if location:
    #         queryset = queryset.filter(
    #             Q(name__icontains=location) |
    #             Q(description__icontains=location)
    #         )
    #
    #     if difficulty:
    #         # Giả sử 'tags' trong model Route có chứa "easy", "medium", "hard"
    #         # [cite: 1332]
    #         difficulty_map = {
    #             'Người mới': 'easy',
    #             'Có kinh nghiệm': 'medium',
    #             'Chuyên nghiệp': 'hard'
    #         }
    #         tag_to_search = difficulty_map.get(difficulty)
    #         if tag_to_search:
    #             queryset = queryset.filter(tags__contains=tag_to_search)
    #
    #     if interests:
    #         # Tìm các route có chứa BẤT KỲ tag sở thích nào
    #         queryset = queryset.filter(tags__overlap=interests)
    #
    #     # 4. Trả về các Routes đã được lọc
    #     return queryset
    def get_queryset(self):
        # 1. Lấy dữ liệu từ query params
        params = self.request.query_params
        difficulty = params.get('difficulty')
        location = params.get('location')
        interests = params.getlist('interests') # Lấy danh sách sở thích

        # 2. CHUẨN BỊ BỘ LỌC
        # Chuyển đổi difficulty từ text sang tag
        difficulty_map = {
            'Người mới': 'easy',
            'Có kinh nghiệm': 'medium',
            'Chuyên nghiệp': 'hard'
        }
        tag_to_search = difficulty_map.get(difficulty)

        # 3. LẤY TẤT CẢ ROUTE (ĐỂ LỌC BẰNG PYTHON)
        # Đây là cách an toàn nhất cho SQLite
        all_routes = list(Route.objects.all())

        # Gán results bằng tất cả route ban đầu
        results = all_routes

        # 4. LỌC 'location' BẰNG PYTHON
        if location:
            results = [
                route for route in results
                if (location.lower() in route.name.lower()) or \
                   (location.lower() in route.description.lower()) or \
                   (location in route.tags) # <-- SỬA QUAN TRỌNG: TÌM TRONG TAGS
            ]

        # 5. LỌC 'difficulty' BẰNG PYTHON
        if tag_to_search:
            results = [route for route in results if tag_to_search in route.tags]

        # 6. LỌC 'interests' BẰNG PYTHON
        if interests:
            # Chỉ giữ lại route nếu có BẤT KỲ sở thích nào khớp
            results = [
                route for route in results
                if any(interest in route.tags for interest in interests)
            ]

        # 7. Trả về danh sách đã được lọc
        return results


# --- Endpoint 2: Quản lý "Mẫu nhập nhanh" (Xử lý nút "Lưu mẫu này") ---
class HistoryInputViewSet(viewsets.ModelViewSet):
    """
    API View này cho phép TẠO (POST) và XEM (GET) các mẫu
    đã lưu (HistoryInput).
    """
    serializer_class = HistoryInputSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Chỉ trả về các mẫu của user đang đăng nhập
        return HistoryInput.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # Tự động gán 'user' là user đang đăng nhập [cite: 1347]
        serializer.save(user=self.request.user)


# --- Endpoint 3: Quản lý Kế hoạch (Tạo Plan sau khi chọn Route) ---
# Tương ứng: POST /api/plans/ [cite: 1424]
class PlanViewSet(viewsets.ModelViewSet):
    """
    API View này cho phép TẠO (POST) một Plan hoàn chỉnh,
    và xem lại (GET) các Plan đã tạo.
    """
    serializer_class = PlanSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Chỉ trả về các Plan của user đang đăng nhập
        return Plan.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # Tự động gán 'user' là user đang đăng nhập [cite: 1338]
        serializer.save(user=self.request.user)


