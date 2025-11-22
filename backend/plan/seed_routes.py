# seed_routes.py (Trong thư mục backend/plan/)
from plan.models import Route

# Dữ liệu 15 cung đường Trekking
routes_data = [
    {
        "name": "Núi Chứa Chan", "location": "Đồng Nai", "description": "Cung đường lý tưởng cho người mới. Có thể cắm trại qua đêm.",
        "distance": 10.0, "elevation": 837,
        "tags": ["easy", "Người mới", "Cắm trại", "Miền Nam", "Đồng Nai", "Núi Chứa Chan"],
    },
    {
        "name": "Núi Bà Đen", "location": "Tây Ninh", "description": "Cung đường dốc đá, là nơi luyện tập thể lực quen thuộc của dân trekking Sài Gòn.",
        "distance": 7.0, "elevation": 986,
        "tags": ["medium", "Có kinh nghiệm", "Miền Nam", "Tây Ninh", "Núi Bà Đen"],
    },
    {
        "name": "Núi Dinh", "location": "Vũng Tàu", "description": "Cung đường dễ đi, rừng tràm mát mẻ, phù hợp cho người mới tập làm quen với trekking.",
        "distance": 8.0, "elevation": 500,
        "tags": ["easy", "Người mới", "Miền Nam", "Vũng Tàu", "Núi Dinh"],
    },
    {
        "name": "Tà Năng - Phan Dũng", "location": "Lâm Đồng", "description": "Cung đường trekking huyền thoại, đi qua 3 tỉnh. Cảnh quan đồi cỏ tuyệt đẹp.",
        "distance": 55.0, "elevation": 1100,
        "tags": ["hard", "Chuyên nghiệp", "Cắm trại", "Miền Nam", "Lâm Đồng", "Tà Năng"],
    },
    {
        "name": "VQG Bidoup Núi Bà", "location": "Lâm Đồng", "description": "Thử thách khám phá rừng nguyên sinh, chinh phục đỉnh núi cao thứ hai của Lâm Đồng. Thích hợp cho Homestay hoặc Cắm trại.",
        "distance": 28.0, "elevation": 2287,
        "tags": ["medium", "Có kinh nghiệm", "Cắm trại", "Homestay", "Miền Nam", "Lâm Đồng", "Bidoup"],
    },
    {
        "name": "Langbiang", "location": "Lâm Đồng", "description": "Chinh phục đỉnh núi huyền thoại của Đà Lạt, cung đường đơn giản, có thể đi xe jeep hoặc trekking.",
        "distance": 14.0, "elevation": 2167,
        "tags": ["medium", "Miền Nam", "Lâm Đồng", "Langbiang"],
    },
    {
        "name": "Hang Én", "location": "Quảng Bình", "description": "Hệ thống hang động lớn thứ ba thế giới, trải nghiệm cắm trại bên bờ sông ngầm trong hang.",
        "distance": 22.0, "elevation": 300,
        "tags": ["medium", "Có kinh nghiệm", "Cắm trại", "Hang động", "Miền Trung", "Quảng Bình", "Hang Én"],
    },
    {
        "name": "Pù Luông", "location": "Thanh Hóa", "description": "Khám phá Khu bảo tồn thiên nhiên, ruộng bậc thang, làng bản người Thái, nghỉ ngơi Homestay sinh thái.",
        "distance": 25.0, "elevation": 1700,
        "tags": ["medium", "Homestay", "Ruộng bậc thang", "Miền Bắc", "Thanh Hóa", "Pù Luông"],
    },
    {
        "name": "Lảo Thẩn", "location": "Lào Cai", "description": "Đỉnh 'nóc nhà Y Tý', cung đường dễ leo, là nơi săn mây lý tưởng cho người mới bắt đầu.",
        "distance": 16.0, "elevation": 2860,
        "tags": ["easy", "Người mới", "Săn mây", "Miền Bắc", "Lào Cai", "Lảo Thẩn"],
    },
    {
        "name": "Fansipan (Trạm Tôn)", "location": "Lào Cai", "description": "Cung đường ngắn và phổ biến nhất để chinh phục đỉnh Fansipan - nóc nhà Đông Dương.",
        "distance": 22.0, "elevation": 3143,
        "tags": ["hard", "Chuyên nghiệp", "Miền Bắc", "Lào Cai", "Fansipan"],
    },
    {
        "name": "Tà Xùa (Sống lưng khủng long)", "location": "Sơn La", "description": "Cung đường săn mây và đi trên sống lưng khủng long nổi tiếng, yêu cầu thể lực tốt và kinh nghiệm.",
        "distance": 18.0, "elevation": 2865,
        "tags": ["hard", "Chuyên nghiệp", "Săn mây", "Miền Bắc", "Sơn La", "Tà Xùa"],
    },
    {
        "name": "Bạch Mộc Lương Tử", "location": "Lào Cai", "description": "Một trong 'tứ đại đỉnh đèo', cung đường dài, hiểm trở nhưng cảnh quan vô cùng hùng vĩ.",
        "distance": 30.0, "elevation": 3046,
        "tags": ["hard", "Chuyên nghiệp", "Miền Bắc", "Lào Cai", "Bạch Mộc"],
    },
    {
        "name": "Hàm Lợn", "location": "Hà Nội", "description": "Núi gần Hà Nội, thích hợp cho chuyến cắm trại cuối tuần, đường đi ngắn, tương đối dễ.",
        "distance": 10.0, "elevation": 462,
        "tags": ["easy", "Người mới", "Cắm trại", "Miền Bắc", "Hà Nội", "Hàm Lợn"],
    },
    {
        "name": "Pu Ta Leng", "location": "Lai Châu", "description": "Đỉnh núi cao thứ hai Việt Nam. Cung đường cực kỳ khó khăn, yêu cầu kỹ năng và thể lực đỉnh cao.",
        "distance": 35.0, "elevation": 3049,
        "tags": ["hard", "Chuyên nghiệp", "Miền Bắc", "Lai Châu", "Pu Ta Leng"],
    },
    {
        "name": "VQG Cúc Phương", "location": "Ninh Bình", "description": "Khám phá rừng nguyên sinh, đi bộ đường dài, quan sát động thực vật đa dạng.",
        "distance": 15.0, "elevation": 600,
        "tags": ["easy", "Người mới", "Miền Bắc", "Ninh Bình", "Cúc Phương"],
    },
]

# --- LOGIC THỰC HIỆN ---
Route.objects.all().delete()
print("--- Đã xóa toàn bộ dữ liệu Route cũ ---")

count = 0
for data in routes_data:
    final_tags = data["tags"]
    if data["location"] not in final_tags:
        final_tags.append(data["location"])

    Route.objects.create(
        name=data["name"],
        description=data["description"],
        total_distance_km=data["distance"],
        elevation_gain_m=data["elevation"],
        path_coordinates={},
        tags=final_tags,
        ai_note="Cung đường này đã được phân tích và đánh giá là một lựa chọn tuyệt vời cho chuyến đi sắp tới.",
    )
    count += 1

print(f"✅ Đã nạp thành công {count} cung đường trekking.")
