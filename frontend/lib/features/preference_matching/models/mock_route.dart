import 'route_model.dart';

// Dữ liệu này sẽ được thay thế bằng dữ liệu từ API sau này
final List<RouteModel> mockRoutes = [
  RouteModel(
      id: 1,
      name: "Núi Chứa Chan",
      location: "Đồng Nai",
      description: "Cận Sài Gòn, có thể cắm trại qua đêm, view hoàng hôn/bình minh xuống đồng bằng rất thoáng và đẹp.",
      imageUrl: "https://images.pexels.com/photos/933054/pexels-photo-933054.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",

      // 👇 THÊM DÒNG NÀY ĐỂ SỬA LỖI
      gallery: [
        "https://images.pexels.com/photos/933054/pexels-photo-933054.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80",
        "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80",
      ],

      distanceKm: 10,
      durationDays: 2,
      durationNights: 1,
      elevationGainM: 800,
      terrain: "Đồi núi, rừng",
      aiNote: "Lorem ipsum dolor sit amet consectetur. Aenean pellentesque tellus senectus vitae et tempor dui."
  ),
  RouteModel(
      id: 2,
      name: "Pù Luông",
      location: "Thanh Hóa",
      description: "Thăm quan/trải nghiệm ruộng bậc thang tuyệt đẹp, chụp ảnh săn mây buổi sáng sớm, thăm quan Hang Dơi, Kho Mường.",
      imageUrl: "https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",

      // 👇 THÊM DÒNG NÀY ĐỂ SỬA LỖI
      gallery: [
        "https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80",
        "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80",
      ],

      distanceKm: 25,
      durationDays: 2,
      durationNights: 1,
      elevationGainM: 700,
      terrain: "Đồi, ruộng bậc thang, rừng tre",
      aiNote: "Lorem ipsum dolor sit amet consectetur. Aenean pellentesque tellus senectus vitae et tempor dui."
  ),
];