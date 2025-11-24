from django.core.management.base import BaseCommand
from plan.models import Route

class Command(BaseCommand):
    help = 'Seeds the database with 36 master trekking routes including Difficulty Levels.'

    def handle(self, *args, **options):
        self.stdout.write(self.style.WARNING('Bắt đầu nạp dữ liệu Master (Kèm độ khó)...'))

        # Xóa dữ liệu cũ để tránh trùng lặp
        Route.objects.all().delete()
        self.stdout.write(self.style.SUCCESS('Đã dọn sạch các cung đường cũ.'))

        # Dữ liệu 36 cung đường chuẩn (Đã thêm tags độ khó)
        routes_data = [
            # --- LEVEL: HARD (Chuyên nghiệp) ---
            {
                "name": "Nam Kang Ho Tao Expedition",
                "location": "Lai Châu",
                "description": "Cung trekking khắc nghiệt nhất Tây Bắc. Vách đá dựng đứng, suối trơn trượt và nguy cơ lũ ống. Yêu cầu kỹ năng sinh tồn cao.",
                "distance": 36.0, "elevation": 1600.0,
                "tags": ["extreme", "hard", "Chuyên nghiệp", "cliff", "stream-crossing"],
            },
            {
                "name": "Pusilung Border Trek",
                "location": "Lai Châu",
                "description": "Hành trình marathon đến đỉnh núi cao thứ 2 Việt Nam. Dài hơn 60km, băng rừng già biên giới. Cần giấy phép biên phòng.",
                "distance": 60.0, "elevation": 2200.0,
                "tags": ["endurance", "hard", "Chuyên nghiệp", "border-landmark", "long-distance", "lai-chau"],
            },
            {
                "name": "Putaleng Rhododendron Trail",
                "location": "Lai Châu",
                "description": "Vương quốc hoa Đỗ Quyên. Dốc gắt liên tục, vượt suối lớn. Thử thách thể lực cực đại.",
                "distance": 34.0, "elevation": 2000.0,
                "tags": ["steep", "hard", "Chuyên nghiệp", "flowers", "jungle", "lai-chau"],
            },
            {
                "name": "Kỳ Quan San (Bạch Mộc Lương Tử)",
                "location": "Lào Cai",
                "description": "Sống lưng khủng long và biển mây. Địa hình đa dạng, gió mạnh trên đỉnh Muối. Cần thể lực tốt.",
                "distance": 30.0, "elevation": 2100.0,
                "tags": ["cloud-hunting", "hard", "Chuyên nghiệp", "ridge-walk", "scenic", "lao-cai"],
            },
            {
                "name": "Ngũ Chỉ Sơn",
                "location": "Lào Cai",
                "description": "Đệ nhất hùng quan. Kỹ thuật leo trèo cao (scrambling) với vách đá dựng đứng và thang gỗ.",
                "distance": 12.0, "elevation": 1400.0,
                "tags": ["technical", "hard", "Chuyên nghiệp", "scramble", "exposed", "lao-cai"],
            },
            {
                "name": "Fansipan (Cát Cát/Sín Chải)",
                "location": "Lào Cai",
                "description": "Tuyến kỹ thuật chinh phục nóc nhà Đông Dương. Dốc gắt, khó hơn nhiều so với đường du lịch Trạm Tôn.",
                "distance": 20.0, "elevation": 1900.0,
                "tags": ["highest-peak", "hard", "Chuyên nghiệp", "steep", "technical", "lao-cai"],
            },
            {
                "name": "Tà Xùa (Sống Lưng Khủng Long)",
                "location": "Sơn La",
                "description": "Đi trên sống núi hẹp, hai bên là vực sâu. Nguy hiểm khi gió mạnh. Cảnh quan hùng vĩ.",
                "distance": 22.4, "elevation": 1600.0,
                "tags": ["ridge-walk", "hard", "Chuyên nghiệp", "exposed", "cloud-hunting", "son-la"],
            },
            {
                "name": "Tà Chì Nhù",
                "location": "Yên Bái",
                "description": "Đại dương mây trên đồi trọc. Dốc đứng, nắng nóng, không có bóng cây. Mùa hoa Chi Pâu tím.",
                "distance": 12.0, "elevation": 1800.0,
                "tags": ["exposed", "hard", "Chuyên nghiệp", "steep", "flowers", "yen-bai"],
            },
            {
                "name": "Tây Côn Lĩnh",
                "location": "Hà Giang",
                "description": "Nóc nhà Đông Bắc. Rừng rậm, nhiều vắt, đường đi khó định vị. Xuyên rừng chè cổ thụ.",
                "distance": 20.0, "elevation": 1400.0,
                "tags": ["jungle", "hard", "Chuyên nghiệp", "leeches", "remote", "ha-giang"],
            },
            {
                "name": "Sơn Đoòng Expedition",
                "location": "Quảng Bình",
                "description": "Thám hiểm hang động lớn nhất thế giới. Leo bức tường 90m, bơi lội, trekking dài ngày.",
                "distance": 25.0, "elevation": 800.0,
                "tags": ["caving", "hard", "Chuyên nghiệp", "expedition", "extreme", "quang-binh"],
            },
            {
                "name": "Tú Làn Cave System",
                "location": "Quảng Bình",
                "description": "Trải nghiệm bơi trong hang tối (wet caving). Leo núi đá vôi sắc nhọn.",
                "distance": 30.0, "elevation": 600.0,
                "tags": ["caving", "hard", "Chuyên nghiệp", "swimming", "adventure", "quang-binh"],
            },
            {
                "name": "Ngọc Linh",
                "location": "Kon Tum",
                "description": "Nóc nhà Tây Nguyên. Rừng già ẩm ướt, rêu phong. Khu vực bảo tồn sâm nghiêm ngặt.",
                "distance": 18.0, "elevation": 1200.0,
                "tags": ["restricted", "hard", "Chuyên nghiệp", "moss-forest", "sacred", "kon-tum"],
            },
            {
                "name": "Thác K50 (Hang Én)",
                "location": "Gia Lai",
                "description": "Thám hiểm rừng già Kon Chư Răng. Nhiều vắt, đường trơn, tiếp cận khó khăn.",
                "distance": 17.0, "elevation": 500.0,
                "tags": ["waterfall", "hard", "Chuyên nghiệp", "jungle", "leeches", "gia-lai"],
            },
            {
                "name": "Chư Yang Sin",
                "location": "Đắk Lắk",
                "description": "Đỉnh cao nhất Đắk Lắk. Địa hình rừng núi hiểm trở, thay đổi liên tục.",
                "distance": 25.0, "elevation": 1400.0,
                "tags": ["biodiversity", "hard", "Chuyên nghiệp", "remote", "dak-lak"],
            },
            {
                "name": "Tà Năng - Phan Dũng",
                "location": "Lâm Đồng",
                "description": "Cung đường trekking đẹp nhất. Băng qua 3 tỉnh, đồi cỏ cháy. Cần sức bền tốt.",
                "distance": 55.0, "elevation": 1100.0,
                "tags": ["grassland", "hard", "Chuyên nghiệp", "endurance", "camping", "lam-dong"],
            },
            {
                "name": "Núi Chúa (Dry Forest)",
                "location": "Ninh Thuận",
                "description": "Rừng khô hạn khắc nghiệt. Nắng nóng, thiếu nước, cây bụi gai.",
                "distance": 22.0, "elevation": 1000.0,
                "tags": ["hot", "hard", "Chuyên nghiệp", "dry-forest", "coastal", "ninh-thuan"],
            },
            {
                "name": "Cực Đông (Mũi Đôi)",
                "location": "Khánh Hòa",
                "description": "Hành trình sa mạc cát. Nắng cháy, nhảy ghềnh đá. Cần sức bền chịu nhiệt.",
                "distance": 12.0, "elevation": 200.0,
                "tags": ["sand-dunes", "hard", "Chuyên nghiệp", "heat", "coastal", "khanh-hoa"],
            },
            {
                "name": "Bà Đen (Ma Thiên Lãnh)",
                "location": "Tây Ninh",
                "description": "Cung đường nguy hiểm. Nhảy đá (bouldering), vách đứng, dễ lạc.",
                "distance": 7.0, "elevation": 900.0,
                "tags": ["technical", "hard", "Chuyên nghiệp", "bouldering", "dangerous", "tay-ninh"],
            },
            {
                "name": "Pu Ta Leng",
                "location": "Lai Châu",
                "description": "Rừng rêu cổ tích và suối thác. Rừng rậm rạp, nhiều đoạn leo trèo khó khăn.",
                "distance": 35.0, "elevation": 3049.0,
                "tags": ["hard", "Chuyên nghiệp", "jungle", "scenic", "lai-chau"],
            },

            # --- LEVEL: MEDIUM (Có kinh nghiệm) ---
            {
                "name": "Lùng Cúng",
                "location": "Yên Bái",
                "description": "Địa hình đa dạng: đồi cỏ, rừng già, thung lũng Táo Mèo. Độ khó vừa phải.",
                "distance": 25.0, "elevation": 1300.0,
                "tags": ["diverse-terrain", "medium", "Có kinh nghiệm", "scenic", "yen-bai"],
            },
            {
                "name": "Pha Luông",
                "location": "Sơn La",
                "description": "Nóc nhà Mộc Châu. Vách đá bàn cờ hùng vĩ. Đường dốc nhưng ngắn.",
                "distance": 10.0, "elevation": 800.0,
                "tags": ["border", "medium", "Có kinh nghiệm", "scenic-rock", "short", "son-la"],
            },
            {
                "name": "Chiêu Lầu Thi",
                "location": "Hà Giang",
                "description": "Săn mây trên chín tầng thang. Núi đá xen rừng già.",
                "distance": 8.0, "elevation": 900.0,
                "tags": ["cloud-hunting", "medium", "Có kinh nghiệm", "rocky", "ha-giang"],
            },
            {
                "name": "Bình Liêu (Mốc 1305)",
                "location": "Quảng Ninh",
                "description": "Sống lưng khủng long biên giới. Bậc thang bê tông dài, gió mạnh.",
                "distance": 8.0, "elevation": 700.0,
                "tags": ["steps", "medium", "Có kinh nghiệm", "border-landmark", "scenic", "quang-ninh"],
            },
            {
                "name": "Phia Oắc",
                "location": "Cao Bằng",
                "description": "Rừng rêu ôn đới. Khí hậu mát mẻ, có biệt thự cổ.",
                "distance": 10.0, "elevation": 800.0,
                "tags": ["moss-forest", "medium", "Có kinh nghiệm", "historical", "cao-bang"],
            },
            {
                "name": "Tây Yên Tử",
                "location": "Bắc Giang",
                "description": "Hành trình tâm linh và thể lực. Hoang sơ hơn phía Đông.",
                "distance": 12.0, "elevation": 1000.0,
                "tags": ["spiritual", "medium", "Có kinh nghiệm", "bamboo-forest", "bac-giang"],
            },
            {
                "name": "Cúc Phương (Xuyên Rừng)",
                "location": "Ninh Bình",
                "description": "Trekking xuyên lõi rừng già. Ẩm ướt, nhiều vắt, cần kiểm lâm.",
                "distance": 18.0, "elevation": 400.0,
                "tags": ["jungle", "medium", "Có kinh nghiệm", "biodiversity", "ninh-binh"],
            },
            {
                "name": "Pù Luông (Kho Mường - Hiêu)",
                "location": "Thanh Hóa",
                "description": "Kết nối bản làng giữa ruộng bậc thang. Cảnh quan văn hóa đẹp.",
                "distance": 15.0, "elevation": 600.0,
                "tags": ["cultural", "medium", "Có kinh nghiệm", "rice-terraces", "thanh-hoa"],
            },
            {
                "name": "Hang Én",
                "location": "Quảng Bình",
                "description": "Cổng vào thế giới ngầm. Lội suối nhiều lần, cắm trại trong hang.",
                "distance": 22.0, "elevation": 500.0,
                "tags": ["caving", "medium", "Có kinh nghiệm", "river-crossing", "camping", "quang-binh"],
            },
            {
                "name": "Chư Nâm",
                "location": "Gia Lai",
                "description": "Cao nguyên lộng gió. Dốc đứng cỏ tranh, view ruộng bàn cờ.",
                "distance": 8.0, "elevation": 700.0,
                "tags": ["views", "medium", "Có kinh nghiệm", "grassland", "steep", "gia-lai"],
            },
            {
                "name": "Bạch Mã (Ngũ Hồ)",
                "location": "Thừa Thiên Huế",
                "description": "Leo trèo qua các hồ nước và thác Đỗ Quyên. Rừng mát mẻ.",
                "distance": 16.0, "elevation": 900.0,
                "tags": ["waterfall", "medium", "Có kinh nghiệm", "swimming", "hue"],
            },
            {
                "name": "Bidoup Núi Bà",
                "location": "Lâm Đồng",
                "description": "Nóc nhà Lâm Đồng. Rừng thông, cây Pơ Mu ngàn năm, kéo dây qua sông.",
                "distance": 27.0, "elevation": 1000.0,
                "tags": ["forest", "medium", "Có kinh nghiệm", "ancient-tree", "lam-dong"],
            },

            # --- LEVEL: EASY (Người mới) ---
            {
                "name": "Lảo Thẩn",
                "location": "Lào Cai",
                "description": "Nóc nhà Y Tý. Cung nhập môn săn mây, đồi cỏ cháy thoáng đãng.",
                "distance": 16.0, "elevation": 1000.0,
                "tags": ["beginner-friendly", "easy", "Người mới", "cloud-hunting", "open-terrain", "lao-cai"],
            },
            {
                "name": "Hàm Lợn",
                "location": "Hà Nội",
                "description": "Sân tập của trekker. Gần Hà Nội, thích hợp cắm trại cuối tuần.",
                "distance": 10.0, "elevation": 400.0,
                "tags": ["training", "easy", "Người mới", "near-hanoi", "camping", "ha-noi"],
            },
            {
                "name": "Chư Đăng Ya",
                "location": "Gia Lai",
                "description": "Miệng núi lửa cổ. Hiking nhẹ nhàng, ngắm hoa dã quỳ.",
                "distance": 5.0, "elevation": 400.0,
                "tags": ["volcano", "easy", "Người mới", "flowers", "scenic", "gia-lai"],
            },
            {
                "name": "Bàu Sấu (Cát Tiên)",
                "location": "Đồng Nai",
                "description": "Xem cá sấu trong đầm lầy. Đi bộ xuyên rừng bằng phẳng.",
                "distance": 10.0, "elevation": 50.0,
                "tags": ["wildlife", "easy", "Người mới", "flat", "wetland", "dong-nai"],
            },
            {
                "name": "Côn Đảo National Park",
                "location": "Bà Rịa - Vũng Tàu",
                "description": "Rừng mưa hải đảo. Trekking xuyên rừng xuống bãi biển.",
                "distance": 6.0, "elevation": 300.0,
                "tags": ["island", "easy", "Người mới", "jungle-to-beach", "wildlife", "ba-ria-vung-tau"],
            },
        ]

        # Nạp dữ liệu
        count = 0
        for data in routes_data:
            final_tags = data["tags"]
            # Thêm location vào tags để search
            if data["location"] not in final_tags:
                final_tags.append(data["location"])

            Route.objects.create(
                name=data["name"],
                description=data["description"],
                total_distance_km=data["distance"],
                elevation_gain_m=data["elevation"],
                path_coordinates={},
                tags=final_tags,
                ai_note=""
            )
            count += 1
            self.stdout.write(f"Đã thêm: {data['name']}")

        self.stdout.write(self.style.SUCCESS(f"\n✅ HOÀN TẤT: Đã nạp thành công {count} cung đường."))