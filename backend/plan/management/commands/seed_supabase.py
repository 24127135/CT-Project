import time
import random
from django.core.management.base import BaseCommand
from duckduckgo_search import DDGS
from supabase import create_client, Client

# ==============================================================================
# CẤU HÌNH SUPABASE (GIỮ NGUYÊN KEY CỦA BẠN)
# ==============================================================================
SUPABASE_URL = "https://qesmaldvlbfznrkrzdhc.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlc21hbGR2bGJmem5ya3J6ZGhjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzcyMDc4MSwiZXhwIjoyMDc5Mjk2NzgxfQ.Y4imE0GdoKHhGgcqQMFbjexsXxXgBt5Pi9iF2ikbF3c"

class Command(BaseCommand):
    help = 'Cào ảnh và nạp 36 cung đường trekking (Có thêm tag Homestay/Camping)'

    def handle(self, *args, **options):
        self.stdout.write(self.style.WARNING('🚀 Đang kết nối Supabase...'))
        try:
            supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'❌ Lỗi kết nối Supabase: {e}'))
            return

        # ==============================================================================
        # DỮ LIỆU ĐÃ CẬP NHẬT TAG "Cắm trại" / "Homestay"
        # ==============================================================================
        routes_data = [
            # --- TÂY BẮC ---
            {"name": "Nam Kang Ho Tao", "loc": "Lai Châu", "km": 36.0, "elev": 1600, "days": 3, "diff": "Chuyên nghiệp",
             "desc": "Cung trekking khắc nghiệt nhất Tây Bắc.", "tags": ["extreme", "hard", "cliff", "Cắm trại"]},
            {"name": "Pu Si Lung", "loc": "Lai Châu", "km": 60.0, "elev": 2200, "days": 4, "diff": "Chuyên nghiệp",
             "desc": "Hành trình marathon biên giới.", "tags": ["endurance", "hard", "Cắm trại"]},
            {"name": "Pu Ta Leng", "loc": "Lai Châu", "km": 34.0, "elev": 2000, "days": 3, "diff": "Chuyên nghiệp",
             "desc": "Vương quốc hoa Đỗ Quyên.", "tags": ["steep", "hard", "flowers", "Cắm trại"]},
            {"name": "Kỳ Quan San (Bạch Mộc)", "loc": "Lào Cai", "km": 30.0, "elev": 2100, "days": 3, "diff": "Chuyên nghiệp",
             "desc": "Sống lưng khủng long và biển mây.", "tags": ["cloud-hunting", "hard", "Cắm trại", "Homestay"]}, # Có lán nghỉ
            {"name": "Ngũ Chỉ Sơn", "loc": "Lào Cai", "km": 12.0, "elev": 1400, "days": 2, "diff": "Chuyên nghiệp",
             "desc": "Đệ nhất hùng quan Tây Bắc.", "tags": ["technical", "hard", "Homestay"]}, # Ngủ lán/nhà dân dưới chân
            {"name": "Fansipan", "loc": "Lào Cai", "km": 20.0, "elev": 1900, "days": 2, "diff": "Chuyên nghiệp",
             "desc": "Chinh phục Nóc nhà Đông Dương.", "tags": ["highest-peak", "hard", "Cắm trại"]},
            {"name": "Tà Xùa", "loc": "Sơn La", "km": 22.4, "elev": 1600, "days": 2, "diff": "Chuyên nghiệp",
             "desc": "Đi trên sống lưng khủng long hẹp.", "tags": ["ridge-walk", "hard", "Cắm trại", "Homestay"]},
            {"name": "Tà Chì Nhù", "loc": "Yên Bái", "km": 12.0, "elev": 1800, "days": 2, "diff": "Chuyên nghiệp",
             "desc": "Đại dương mây trên đồi trọc.", "tags": ["hard", "flowers", "Cắm trại"]},
            {"name": "Tây Côn Lĩnh", "loc": "Hà Giang", "km": 20.0, "elev": 1400, "days": 2, "diff": "Chuyên nghiệp",
             "desc": "Nóc nhà Đông Bắc, rừng rậm.", "tags": ["jungle", "hard", "Homestay"]}, # Ngủ bản

            # --- MEDIUM / EASY ---
            {"name": "Lảo Thẩn", "loc": "Lào Cai", "km": 16.0, "elev": 1000, "days": 2, "diff": "Người mới",
             "desc": "Cung nhập môn săn mây lý tưởng.", "tags": ["easy", "cloud-hunting", "Cắm trại", "Homestay"]},
            {"name": "Nhìu Cồ San", "loc": "Lào Cai", "km": 13.0, "elev": 1200, "days": 2, "diff": "Có kinh nghiệm",
             "desc": "Con đường đá cổ Pavi.", "tags": ["historical", "medium", "Homestay"]},
            {"name": "Lùng Cúng", "loc": "Yên Bái", "km": 25.0, "elev": 1300, "days": 2, "diff": "Có kinh nghiệm",
             "desc": "Địa hình đa dạng, táo mèo.", "tags": ["medium", "Cắm trại"]},
            {"name": "Pha Luông", "loc": "Sơn La", "km": 10.0, "elev": 800, "days": 1, "diff": "Có kinh nghiệm",
             "desc": "Nóc nhà Mộc Châu.", "tags": ["border", "medium", "Homestay"]}, # Đi về trong ngày hoặc ngủ đồn biên phòng/nhà dân
            {"name": "Chiêu Lầu Thi", "loc": "Hà Giang", "km": 8.0, "elev": 900, "days": 1, "diff": "Có kinh nghiệm",
             "desc": "Săn mây trên chín tầng thang.", "tags": ["cloud-hunting", "medium", "Cắm trại"]},
            {"name": "Phia Oắc", "loc": "Cao Bằng", "km": 10.0, "elev": 800, "days": 1, "diff": "Có kinh nghiệm",
             "desc": "Rừng rêu ôn đới ma mị.", "tags": ["moss-forest", "medium", "Homestay"]},

            # --- ĐÔNG BẮC & ĐỒNG BẰNG ---
            {"name": "Bình Liêu (Mốc 1305)", "loc": "Quảng Ninh", "km": 8.0, "elev": 700, "days": 1, "diff": "Có kinh nghiệm",
             "desc": "Sống lưng khủng long biên giới.", "tags": ["medium", "border-landmark", "Homestay"]},
            {"name": "Tây Yên Tử", "loc": "Bắc Giang", "km": 12.0, "elev": 1000, "days": 1, "diff": "Có kinh nghiệm",
             "desc": "Hành trình tâm linh.", "tags": ["spiritual", "medium", "Homestay"]},
            {"name": "Hàm Lợn", "loc": "Hà Nội", "km": 10.0, "elev": 400, "days": 1, "diff": "Người mới",
             "desc": "Sân tập trekking cuối tuần.", "tags": ["easy", "near-hanoi", "Cắm trại"]},
            {"name": "Cúc Phương", "loc": "Ninh Bình", "km": 18.0, "elev": 400, "days": 1, "diff": "Có kinh nghiệm",
             "desc": "Trekking xuyên rừng nguyên sinh.", "tags": ["jungle", "medium", "Homestay"]},

            # --- MIỀN TRUNG ---
            {"name": "Sơn Đoòng", "loc": "Quảng Bình", "km": 25.0, "elev": 800, "days": 4, "diff": "Chuyên nghiệp",
             "desc": "Hang động lớn nhất thế giới.", "tags": ["caving", "hard", "Cắm trại"]},
            {"name": "Tú Làn", "loc": "Quảng Bình", "km": 30.0, "elev": 600, "days": 3, "diff": "Chuyên nghiệp",
             "desc": "Trải nghiệm bơi trong hang tối.", "tags": ["caving", "hard", "Cắm trại"]},
            {"name": "Hang Én", "loc": "Quảng Bình", "km": 22.0, "elev": 500, "days": 2, "diff": "Có kinh nghiệm",
             "desc": "Hang động lớn thứ 3 thế giới.", "tags": ["caving", "medium", "Cắm trại"]},
            {"name": "Pù Luông", "loc": "Thanh Hóa", "km": 15.0, "elev": 600, "days": 2, "diff": "Có kinh nghiệm",
             "desc": "Đi bộ qua các bản làng, ruộng bậc thang.", "tags": ["cultural", "medium", "Homestay"]},
            {"name": "Pù Mát", "loc": "Nghệ An", "km": 15.0, "elev": 800, "days": 2, "diff": "Chuyên nghiệp",
             "desc": "Thám hiểm vùng lõi.", "tags": ["jungle", "hard", "Cắm trại"]},
            {"name": "Bạch Mã", "loc": "Thừa Thiên Huế", "km": 16.0, "elev": 900, "days": 1, "diff": "Có kinh nghiệm",
             "desc": "Leo trèo qua Ngũ Hồ.", "tags": ["waterfall", "medium", "Homestay"]}, # Ngủ biệt thự/camping chân núi

            # --- TÂY NGUYÊN ---
            {"name": "Ngọc Linh", "loc": "Kon Tum", "km": 18.0, "elev": 1200, "days": 3, "diff": "Chuyên nghiệp",
             "desc": "Nóc nhà Tây Nguyên.", "tags": ["hard", "moss-forest", "Cắm trại"]},
            {"name": "Thác K50", "loc": "Gia Lai", "km": 17.0, "elev": 500, "days": 2, "diff": "Chuyên nghiệp",
             "desc": "Thác nước hùng vĩ giữa rừng.", "tags": ["waterfall", "hard", "Cắm trại"]},
            {"name": "Chư Yang Sin", "loc": "Đắk Lắk", "km": 25.0, "elev": 1400, "days": 3, "diff": "Chuyên nghiệp",
             "desc": "Đỉnh cao nhất Đắk Lắk.", "tags": ["hard", "forest", "Cắm trại"]},
            {"name": "Chư Đăng Ya", "loc": "Gia Lai", "km": 5.0, "elev": 400, "days": 1, "diff": "Người mới",
             "desc": "Miệng núi lửa cổ đã tắt.", "tags": ["volcano", "easy", "Cắm trại"]},
            {"name": "Chư Nâm", "loc": "Gia Lai", "km": 8.0, "elev": 700, "days": 1, "diff": "Có kinh nghiệm",
             "desc": "Ngọn núi cao nhất Tây Pleiku.", "tags": ["medium", "grassland", "Cắm trại"]},
            {"name": "Bidoup Núi Bà", "loc": "Lâm Đồng", "km": 27.0, "elev": 1000, "days": 2, "diff": "Có kinh nghiệm",
             "desc": "Nóc nhà Lâm Đồng.", "tags": ["forest", "medium", "Cắm trại"]},
            {"name": "Tà Năng - Phan Dũng", "loc": "Lâm Đồng", "km": 55.0, "elev": 1100, "days": 3, "diff": "Chuyên nghiệp",
             "desc": "Cung trekking đẹp nhất Việt Nam.", "tags": ["hard", "long-distance", "Cắm trại"]},

            # --- MIỀN NAM ---
            {"name": "Núi Chúa", "loc": "Ninh Thuận", "km": 22.0, "elev": 1000, "days": 2, "diff": "Chuyên nghiệp",
             "desc": "Rừng khô hạn độc đáo.", "tags": ["hot", "hard", "Cắm trại"]},
            {"name": "Cực Đông", "loc": "Khánh Hòa", "km": 12.0, "elev": 200, "days": 1, "diff": "Chuyên nghiệp",
             "desc": "Điểm cực Đông trên đất liền.", "tags": ["hard", "heat", "Cắm trại"]},
            {"name": "Núi Bà Đen", "loc": "Tây Ninh", "km": 7.0, "elev": 900, "days": 1, "diff": "Chuyên nghiệp",
             "desc": "Cung Ma Thiên Lãnh.", "tags": ["hard", "bouldering", "Cắm trại"]}, # Ngủ đỉnh núi
            {"name": "Côn Đảo", "loc": "Bà Rịa - Vũng Tàu", "km": 6.0, "elev": 300, "days": 1, "diff": "Người mới",
             "desc": "Trekking xuyên rừng quốc gia.", "tags": ["easy", "island", "Homestay"]}, # Ngủ khách sạn/homestay
        ]

        total = len(routes_data)
        self.stdout.write(f"🚀 Bắt đầu xử lý {total} cung đường...")

        for index, data in enumerate(routes_data):
            route_name = data["name"]

            # --- 1. CÀO ẢNH TỪ DUCKDUCKGO ---
            search_query = f"{route_name} trekking vietnam scenery nature"
            gallery_urls = []

            self.stdout.write(f"[{index + 1}/{total}] Đang tìm ảnh cho: {route_name}...")

            # Thử cào ảnh (Retry 3 lần để chống lỗi mạng)
            for attempt in range(3):
                try:
                    with DDGS() as ddgs:
                        # Lấy 4 ảnh
                        results = list(ddgs.images(search_query, region="vn-vi", safesearch="off", max_results=4))
                        if results:
                            gallery_urls = [r['image'] for r in results]
                            self.stdout.write(self.style.SUCCESS(f"   -> Tìm thấy {len(results)} ảnh."))
                            break
                except Exception:
                    time.sleep(2)  # Đợi 2s rồi thử lại nếu lỗi

            # Fallback nếu không có ảnh
            if not gallery_urls:
                gallery_urls = ["https://images.unsplash.com/photo-1501555088652-021faa106b9b?q=80"]

            # --- 2. CHUẨN BỊ PAYLOAD CHO SUPABASE (ĐÚNG THỨ TỰ CỘT) ---
            # Thêm location và difficulty vào tags để search
            final_tags = data["tags"] + [data["loc"], data["diff"]]

            # Chú ý: path_coordinates và ai_note tạm thời để trống
            payload = {
                "name": route_name,  # name
                "description": data["desc"],  # description
                "total_distance_km": data["km"],  # total_distance_km
                "elevation_gain_m": data["elev"],  # elevation_gain_m
                "difficulty_level": data["diff"],  # difficulty_level
                "estimated_duration_days": data["days"],  # estimated_duration_days
                "path_coordinates": {},  # path_coordinates (JSONB)
                "tags": final_tags,  # tags (JSONB)
                "ai_note": "",  # ai_note
                "gallery_image_urls": gallery_urls  # gallery_image_urls (TEXT ARRAY)
            }

            # --- 3. ĐẨY LÊN SUPABASE ---
            try:
                supabase.table('routes').insert(payload).execute()
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"   ❌ Lỗi Supabase: {e}"))

            # Nghỉ ngẫu nhiên để tránh bị chặn IP
            time.sleep(random.uniform(1.5, 3.0))

        self.stdout.write(self.style.SUCCESS("\n🎉 ĐÃ HOÀN TẤT ĐẨY DỮ LIỆU LÊN SUPABASE!"))