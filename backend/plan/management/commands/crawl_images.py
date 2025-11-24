import time
import random
from django.core.management.base import BaseCommand
from plan.models import Route
from duckduckgo_search import DDGS


class Command(BaseCommand):
    help = 'Tự động tìm và nạp ảnh cho 36 Route (Chế độ an toàn chống chặn IP)'

    def handle(self, *args, **options):
        routes = Route.objects.all()
        total = routes.count()

        self.stdout.write(self.style.WARNING(f"🚀 Bắt đầu tìm ảnh cho {total} cung đường..."))
        self.stdout.write("---------------------------------------------------")

        for index, route in enumerate(routes):
            query = f"{route.name} trekking vietnam scenery nature"
            self.stdout.write(f"[{index + 1}/{total}] Đang tìm: {route.name}...")

            # Cơ chế thử lại tối đa 3 lần nếu bị lỗi
            max_retries = 3
            success = False

            for attempt in range(max_retries):
                try:
                    with DDGS() as ddgs:
                        # Tìm 4 ảnh
                        results = list(ddgs.images(
                            query,
                            region="vn-vi",
                            safesearch="off",
                            max_results=4
                        ))

                    if results:
                        route.image_url = results[0]['image']
                        gallery_urls = [r['image'] for r in results]
                        route.gallery = gallery_urls
                        route.save()
                        self.stdout.write(self.style.SUCCESS(f"   ✅ Đã lưu {len(results)} ảnh."))
                        success = True
                        break  # Thành công thì thoát vòng lặp thử lại
                    else:
                        self.stdout.write(self.style.WARNING("   ⚠️ Không tìm thấy ảnh."))
                        break

                except Exception as e:
                    error_msg = str(e)
                    if "202" in error_msg or "Ratelimit" in error_msg:
                        wait_time = 30 + (attempt * 10)  # Lần 1: 30s, Lần 2: 40s...
                        self.stdout.write(
                            self.style.ERROR(f"   zzz Bị chặn (Rate Limit). Đang ngủ {wait_time}s để hồi phục..."))
                        time.sleep(wait_time)
                    else:
                        self.stdout.write(self.style.ERROR(f"   ❌ Lỗi khác: {e}"))
                        break  # Lỗi khác thì bỏ qua luôn

            # Nếu thành công, nghỉ ngơi ngẫu nhiên 5-10 giây trước khi qua cung đường tiếp theo
            # (Tăng thời gian nghỉ lên để an toàn hơn)
            if success:
                sleep_time = random.uniform(5.0, 10.0)
                time.sleep(sleep_time)

        self.stdout.write("---------------------------------------------------")
        self.stdout.write(self.style.SUCCESS("\n ĐÃ HOÀN TẤT!"))