class RouteModel {
  final int id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final List<String> gallery;
  final double distanceKm;
  final int durationDays;
  final int durationNights;
  final int elevationGainM;
  final String terrain;
  final String aiNote;
  final String matchReason;

  RouteModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.gallery,
    required this.distanceKm,
    required this.durationDays,
    required this.durationNights,
    required this.elevationGainM,
    required this.terrain,
    required this.aiNote,
    this.matchReason = '',
  });

  RouteModel copyWith({
    int? id,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    List<String>? gallery,
    double? distanceKm,
    int? durationDays,
    int? durationNights,
    int? elevationGainM,
    String? terrain,
    String? aiNote,
    String? matchReason,
  }) {
    return RouteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      distanceKm: distanceKm ?? this.distanceKm,
      durationDays: durationDays ?? this.durationDays,
      durationNights: durationNights ?? this.durationNights,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      terrain: terrain ?? this.terrain,
      aiNote: aiNote ?? this.aiNote,
      matchReason: matchReason ?? this.matchReason,
    );
  }

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // 1. Xử lý Tags
    List<String> tags = [];
    if (json['tags'] != null) {
      // Supabase trả về List<dynamic>, cần ép kiểu sang List<String>
      tags = List<String>.from(json['tags']);
    }

    // 2. Xử lý Gallery (Tên cột mới: gallery_image_urls)
    List<String> galleryList = [];
    if (json['gallery_image_urls'] != null) {
      galleryList = List<String>.from(json['gallery_image_urls']);
    }

    // 3. Xử lý Ảnh đại diện
    // Nếu có gallery thì lấy ảnh đầu tiên, nếu không thì dùng ảnh placeholder
    String img = galleryList.isNotEmpty
        ? galleryList.first
        : 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?q=80';

    // 4. Xử lý Địa điểm
    // Logic: Script seed đẩy [..., Location, Difficulty] vào cuối mảng tags.
    // Nên Location thường nằm ở vị trí KẾ CUỐI (tags[length - 2]) nếu có đủ tag.

    // Tìm đoạn xử lý locationName và thay bằng đoạn này:
    String locationName = "Việt Nam";
    if (tags.isNotEmpty) {
      String lastTag = tags.last;
      // Danh sách từ khóa độ khó cần tránh
      const difficulties = ['người mới', 'easy', 'có kinh nghiệm', 'medium', 'chuyên nghiệp', 'hard'];

      // Nếu tag cuối là độ khó, lùi lại lấy tag kế cuối
      if (difficulties.contains(lastTag.toLowerCase()) && tags.length >= 2) {
        locationName = tags[tags.length - 2];
      } else {
        locationName = lastTag;
      }
    }

    // 5. Xử lý Địa hình (Lọc bỏ các tag hệ thống để lấy tag địa hình hiển thị)
    final ignoredKeywords = [
      'easy', 'medium', 'hard', 'người mới', 'có kinh nghiệm', 'chuyên nghiệp',
      'beginner-friendly', 'endurance', 'technical', 'extreme', 'restricted',
      'long-distance', 'short', 'highest-peak', 'flat-but-hard',
      'border-landmark', 'scenic', 'scenic-rock', 'views', 'sunrise',
      locationName.toLowerCase(), // Bỏ tên địa điểm khỏi phần địa hình
      _removeDiacritics(locationName), // Bỏ tên không dấu
    ];

    final terrainTags = tags.where((tag) {
      final t = tag.toLowerCase();
      if (ignoredKeywords.contains(t)) return false;
      // Bỏ các tag trùng tên địa điểm
      if (t.contains(locationName.toLowerCase())) return false;
      return true;
    }).toList();

    // Dịch sang Tiếng Việt (dùng lại logic cũ)
    final translatedTerrain = terrainTags.map((t) => _translateTag(t)).where((t) => t.isNotEmpty).toList();

    return RouteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: locationName,
      description: json['description'] ?? '',
      imageUrl: img,
      gallery: galleryList,

      // --- MAP CỘT SUPABASE (Snake_case) ---
      distanceKm: (json['total_distance_km'] ?? 0).toDouble(),
      elevationGainM: (json['elevation_gain_m'] ?? 0).toInt(),
      durationDays: json['estimated_duration_days'] ?? 2,
      durationNights: (json['estimated_duration_days'] ?? 2) - 1, // Tự tính đêm

      terrain: translatedTerrain.isNotEmpty ? translatedTerrain.join(', ') : 'Đồi núi tự nhiên',
      aiNote: json['ai_note'] ?? '',
      matchReason: '',
    );
  }

  // Các hàm helper nhỏ để file gọn
  static String _removeDiacritics(String str) {
    const withDia = 'áàảãạăắằẳẵặâấầẩẫậđéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵ';
    const withoutDia = 'aaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyy';
    var result = str.toLowerCase();
    for (int i = 0; i < withDia.length; i++) {
      result = result.replaceAll(withDia[i], withoutDia[i]);
    }
    return result;
  }

  static String _translateTag(String t) {
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
      case 'leeches': return 'Nhiều vắt';
      case 'wild': return 'Hoang dã';
      case 'flowers': return 'Mùa hoa';
      case 'historical': return 'Di tích';
      case 'camping': return 'Cắm trại';
      default: return "";
    }
  }
}