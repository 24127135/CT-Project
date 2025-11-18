import 'package:flutter/material.dart';

class TripProvider with ChangeNotifier {
  // --- KHAI BÁO CÁC BIẾN DỮ LIỆU ---

  // Bước 1
  String? accommodation; // Loại hình (Cắm trại...)
  String? paxGroup;      // Số người (Đơn lẻ...)
  String searchLocation = ''; // Địa điểm

  // Bước 2
  DateTime? startDate;   // Ngày đi

  // Bước 3
  String? difficultyLevel; // Mức độ (Người mới...)

  // Bước 4
  String note = '';
  List<String> selectedInterests = [];

  // Bước 5
  String tripName = '';

  // --- CÁC HÀM ĐỂ CẬP NHẬT DỮ LIỆU ---

  // Cập nhật Bước 1
  void setAccommodation(String value) {
    accommodation = value;
    notifyListeners(); // Quan trọng: Báo cho UI vẽ lại
  }

  void setPaxGroup(String value) {
    paxGroup = value;
    notifyListeners();
  }

  void setSearchLocation(String value) {
    searchLocation = value;
    notifyListeners();
  }

  // Cập nhật Bước 2
  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  // Cập nhật Bước 3
  void setDifficultyLevel(String value) {
    difficultyLevel = value;
    notifyListeners();
  }

  // Cập nhật Bước 4
  void setNote(String value) {
    note = value;
    notifyListeners(); // (Có thể bỏ notify nếu không cần update realtime)
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    notifyListeners();
  }

  // Cập nhật Bước 5
  void setTripName(String value) {
    tripName = value;
    notifyListeners();
  }

  // Hàm dọn dẹp (Reset) sau khi hoàn tất
  void resetTrip() {
    accommodation = null;
    paxGroup = null;
    searchLocation = '';
    startDate = null;
    difficultyLevel = null;
    note = '';
    selectedInterests = [];
    tripName = '';
    notifyListeners();
  }
}