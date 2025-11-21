// File: lib/features/preference_matching/models/route_model.dart

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

  // --- THÊM ĐOẠN NÀY ĐỂ NHẬN DỮ LIỆU TỪ BACKEND ---
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Chưa cập nhật tên',

      // Backend chưa gửi location, tạm lấy từ mô tả hoặc hardcode
      location: json['location'] ?? 'Việt Nam',

      description: json['description'] ?? '',

      // Backend chưa có ảnh, dùng ảnh placeholder đẹp
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?q=80&w=2073&auto=format&fit=crop',

      // Mapping đúng tên trường từ Serializer
      distanceKm: (json['totalDistanceKm'] ?? 0).toDouble(),
      elevationGainM: (json['elevationGainM'] ?? 0).toInt(),

      // Backend chưa gửi thời gian, cố gắng lấy từ backend hoặc tính toán từ startDate/endDate nếu có
      durationDays: json['durationDays'] ??
          (() {
            if (json['startDate'] != null && json['endDate'] != null) {
              try {
                final start = DateTime.parse(json['startDate']);
                final end = DateTime.parse(json['endDate']);
                final days = end.difference(start).inDays;
                return days > 0 ? days : 2;
              } catch (e) {
                return 2;
              }
            }
            return 2;
          })(),
      durationNights: json['durationNights'] ??
          (() {
            if (json['startDate'] != null && json['endDate'] != null) {
              try {
                final start = DateTime.parse(json['startDate']);
                final end = DateTime.parse(json['endDate']);
                final nights = end.difference(start).inDays;
                return nights > 0 ? nights - 1 : 1;
              } catch (e) {
                return 1;
              }
            }
            return 1;
          })(),

      // Lấy tags từ backend gán vào địa hình
      terrain: (json['tags'] as List?)?.join(', ') ?? 'Đồi núi',

      // AI Note giả lập hoặc lấy từ backend nếu có
      aiNote: json['aiNote'] ?? 'Cung đường này rất phù hợp với sở thích của bạn dựa trên dữ liệu phân tích.',
    );
  }
}