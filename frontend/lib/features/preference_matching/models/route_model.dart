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
}