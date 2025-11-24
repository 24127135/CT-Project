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
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // 1. Lấy danh sách tags từ API
    List<String> tags = (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];

    // 2. Danh sách các từ khóa CẦN LOẠI BỎ (Độ khó & Tag hệ thống)
    final ignoredKeywords = [
      'easy', 'medium', 'hard',
      'người mới', 'có kinh nghiệm', 'chuyên nghiệp',
      'beginner-friendly', 'endurance', 'technical', 'extreme', 'restricted',
      'long-distance', 'short', 'highest-peak', 'flat-but-hard',
      'border-landmark', 'scenic', 'scenic-rock', 'views', 'sunrise'
    ];

    // Lấy tên địa điểm để loại bỏ khỏi phần địa hình
    String locationName = (json['location'] ?? '').toString().toLowerCase();

    // 3. Lọc tags
    final terrainTags = tags.where((tag) {
      final t = tag.toLowerCase();

      // Bỏ qua nếu là từ khóa độ khó
      if (ignoredKeywords.contains(t)) return false;

      // Bỏ qua nếu tag trùng tên địa điểm (Lào Cai, Lao-cai...)
      if (locationName.isNotEmpty) {
        // So sánh chứa (contains) nhưng phải cẩn thận không xóa nhầm từ ghép
        // Ví dụ: location="Lào Cai", tag="lao-cai" -> Xóa
        // Ví dụ: location="Lào Cai", tag="cloud-hunting" -> Giữ

        // Xóa các biến thể của tên địa điểm (viết liền, có gạch nối)
        String cleanLoc = locationName.replaceAll(' ', '-');
        if (t == locationName || t == cleanLoc) return false;
      }

      return true;
    }).toList();

    // Xử lý Gallery
    List<String> galleryList = [];
    if (json['gallery'] != null) {
      galleryList = List<String>.from(json['gallery']);
    }

    // 4. Dịch sang Tiếng Việt (Bổ sung thêm từ điển)
    final translatedTerrain = terrainTags.map((t) {
      switch (t.toLowerCase()) {
      // Nhóm Rừng & Cây cối
        case 'jungle': return 'Rừng rậm';
        case 'forest': return 'Rừng';
        case 'primary-forest': return 'Rừng nguyên sinh';
        case 'bamboo-forest': return 'Rừng tre';
        case 'moss-forest': return 'Rừng rêu';
        case 'tea-forest': return 'Rừng chè';

      // Nhóm Nước & Thác
        case 'waterfall': return 'Thác nước';
        case 'stream': return 'Suối';
        case 'stream-crossing': return 'Lội suối';
        case 'river-crossing': return 'Vượt sông';
        case 'wetland': return 'Đầm lầy';

      // Nhóm Núi & Địa hình
        case 'mountain': return 'Núi';
        case 'rocky': return 'Núi đá';
        case 'cliff': return 'Vách đá';
        case 'steep': return 'Dốc đứng';
        case 'ridge-walk': return 'Sống núi';
        case 'exposed': return 'Lộ thiên (Ít cây)';
        case 'open-terrain': return 'Thoáng đãng'; // Đã dịch từ open-terrain
        case 'grassland': return 'Đồi cỏ';
        case 'volcano': return 'Núi lửa';
        case 'sand-dunes': return 'Đồi cát';
        case 'bouldering': return 'Nhảy đá';
        case 'diverse-terrain': return 'Địa hình đa dạng';

      // Nhóm Trải nghiệm & Cảnh quan
        case 'cloud-hunting': return 'Săn mây';
        case 'rice-terraces': return 'Ruộng bậc thang';
        case 'caving': return 'Hang động';
        case 'wet-cave': return 'Hang nước';
        case 'snow': return 'Tuyết';
        case 'coastal': return 'Ven biển';
        case 'island': return 'Hải đảo';
        case 'leeches': return 'Nhiều vắt';
        case 'wild': return 'Hoang dã';
        case 'flowers': return 'Mùa hoa';
        case 'historical': return 'Di tích lịch sử';
        case 'spiritual': return 'Tâm linh';
        case 'cultural': return 'Văn hóa bản địa';
        case 'camping': return 'Cắm trại';

        default: return ""; // Trả về rỗng để lọc bỏ các tag lạ chưa dịch
      }
    }).where((t) => t.isNotEmpty).toList(); // Lọc bỏ các chuỗi rỗng

    return RouteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Chưa cập nhật tên',
      location: json['location'] ?? 'Việt Nam',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?q=80&w=2073',

      gallery: galleryList.isNotEmpty ? galleryList : [
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80',
        'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80',
      ],

      distanceKm: (json['totalDistanceKm'] ?? 0).toDouble(),
      elevationGainM: (json['elevationGainM'] ?? 0).toInt(),
      durationDays: 2,
      durationNights: 1,

      // Hiển thị kết quả
      terrain: translatedTerrain.isNotEmpty ? translatedTerrain.join(', ') : 'Đồi núi tự nhiên',
      aiNote: json['aiNote'] ?? '',
    );
  }
}