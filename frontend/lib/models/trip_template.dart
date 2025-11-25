class TripTemplate {
  final int id;
  final String name;
  final String location;
  final String accommodation;
  final String paxGroup;
  final int durationDays;
  final String difficulty;
  final String note;
  final List<String> interests;

  TripTemplate({
    required this.id,
    required this.name,
    required this.location,
    required this.accommodation,
    required this.paxGroup,
    required this.durationDays,
    required this.difficulty,
    required this.note,
    required this.interests,
  });

  // Factory constructor to create a TripTemplate from JSON (Backend response)
  factory TripTemplate.fromJson(Map<String, dynamic> json) {
    return TripTemplate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      accommodation: json['accommodation'] ?? '',
      paxGroup: json['pax_group'] ?? json['paxGroup'] ?? '',
      durationDays: json['duration_days'] ?? json['durationDays'] ?? 1,
      difficulty: json['difficulty'] ?? '',
      note: json['note'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}