// Shared danger key labels and helpers
const Map<String, String> dangerKeyLabels = {
  'steep_sections': 'Đoạn dốc nguy hiểm',
  'river_crossings': 'Đoạn phải băng suối',
  'rockfall': 'Nguy cơ sạt lở/đá rơi',
  'avalanche_risk': 'Nguy cơ tuyết lở',
  'wild_animals': 'Động vật hoang dã',
  'high_wind': 'Gió mạnh',
  'flood_prone': 'Khu vực dễ ngập',
  'poor_visibility': 'Tầm nhìn kém',
  'bridge_out': 'Cầu hỏng',
  'toxic_plants': 'Thực vật độc',
  // Weather-generated keys
  'heavy_rain': 'Mưa lớn',
  'strong_wind': 'Gió mạnh',
  'extreme_heat': 'Nhiệt độ cực cao',
  'extreme_cold': 'Nhiệt độ cực thấp',
};

String dangerLabelForKey(String key) {
  final k = key.trim();
  if (dangerKeyLabels.containsKey(k)) return dangerKeyLabels[k]!;

  // Fallback: humanize snake_case/camelCase/dashed keys to Title Case
  var s = k.replaceAll(RegExp(r'[_\-]+'), ' ');
  s = s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  final parts = s.trim().split(RegExp(r'\s+'));
  final human = parts.map((w) {
    if (w.isEmpty) return w;
    return w[0].toUpperCase() + w.substring(1).toLowerCase();
  }).join(' ');
  return human;
}
