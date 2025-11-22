class RouteModel {
  final int id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final double distanceKm;
  final int durationDays;
  final int durationNights;
  final int elevationGainM;
  final String terrain;
  final String aiNote;

  RouteModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.distanceKm,
    required this.durationDays,
    required this.durationNights,
    required this.elevationGainM,
    required this.terrain,
    required this.aiNote,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // 1. Lấy danh sách tags từ API
    List<String> tags = (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];

    // 2. Danh sách các từ khóa CẦN LOẠI BỎ (Độ khó & Tag hệ thống)
    final ignoredKeywords = [
      'easy', 'medium', 'hard',
      'người mới', 'có kinh nghiệm', 'chuyên nghiệp',
      'beginner-friendly', 'endurance', 'technical', 'extreme', 'restricted',
      'long-distance', 'short', 'highest-peak'
    ];

    // Lấy tên địa điểm để loại bỏ khỏi phần địa hình (Ví dụ: không hiện "Lào Cai" ở mục Địa hình)
    String locationName = (json['location'] ?? '').toString().toLowerCase();

    // 3. Lọc tags: Chỉ giữ lại các tag mô tả địa hình thực tế
    final terrainTags = tags.where((tag) {
      final t = tag.toLowerCase();

      // Bỏ qua nếu là từ khóa độ khó
      if (ignoredKeywords.contains(t)) return false;

      // Bỏ qua nếu tag trùng tên địa điểm (hoặc chứa tên địa điểm)
      if (t.contains(locationName)) return false;

      // Bỏ qua các tag viết không dấu của địa điểm (nếu backend gửi về)
      return true;
    }).toList();

    // 4. Dịch một số từ vựng tiếng Anh sang tiếng Việt cho đẹp (Optional)
    final translatedTerrain = terrainTags.map((t) {
      switch (t.toLowerCase()) {
        case 'jungle': return 'Rừng rậm';
        case 'forest': return 'Rừng';
        case 'waterfall': return 'Thác nước';
        case 'stream': return 'Suối';
        case 'mountain': return 'Núi';
        case 'cloud-hunting': return 'Săn mây';
        case 'rice-terraces': return 'Ruộng bậc thang';
        case 'cliff': return 'Vách đá';
        case 'caving': return 'Hang động';
        case 'snow': return 'Tuyết';
        case 'grassland': return 'Đồi cỏ';
        case 'bamboo-forest': return 'Rừng tre';
        case 'moss-forest': return 'Rừng rêu';
        case 'volcano': return 'Núi lửa';
        case 'coastal': return 'Ven biển';
        case 'island': return 'Hải đảo';
        default: return t; // Giữ nguyên nếu không có trong từ điển
      }
    }).toList();

    return RouteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Chưa cập nhật tên',
      location: json['location'] ?? 'Việt Nam',
      description: json['description'] ?? '',
      // Ảnh placeholder nếu thiếu
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?q=80&w=2073&auto=format&fit=crop',

      distanceKm: (json['totalDistanceKm'] ?? 0).toDouble(),
      elevationGainM: (json['elevationGainM'] ?? 0).toInt(),

      // Giả lập thời gian (hoặc lấy từ backend nếu sau này có trường này)
      durationDays: 2,
      durationNights: 1,

      // GÁN DANH SÁCH ĐÃ LỌC VÀO ĐÂY
      terrain: translatedTerrain.isNotEmpty ? translatedTerrain.join(', ') : 'Đồi núi tự nhiên',

      aiNote: json['aiNote'] ?? '',
    );
  }
}