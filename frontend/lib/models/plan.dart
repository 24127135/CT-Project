import 'dart:convert';

String _humanizeLabel(String raw) {
  var s = raw.replaceAll(RegExp(r'[_\-]+'), ' ');
  s = s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  final parts = s.trim().split(RegExp(r'\s+'));
  final human = parts.map((w) {
    if (w.isEmpty) return w;
    return w[0].toUpperCase() + w.substring(1).toLowerCase();
  }).join(' ');
  return human;
}

class EquipmentItem {
  final String name;
  final String? store;
  final String? price;

  EquipmentItem({required this.name, this.store, this.price});

  factory EquipmentItem.fromDynamic(dynamic d) {
    if (d is String) return EquipmentItem(name: _humanizeLabel(d));
    if (d is Map) {
      final rawName = (d['name'] ?? d['title'] ?? '').toString();
      final name = rawName.isNotEmpty ? _humanizeLabel(rawName) : null;
      return EquipmentItem(
        name: name ?? _humanizeLabel(d.keys.first.toString()),
        store: d['store']?.toString(),
        price: d['price']?.toString(),
      );
    }
    return EquipmentItem(name: d.toString());
  }

  Map<String, dynamic> toJson() => {'name': name, 'store': store, 'price': price};
}

class RouteModel {
  final int? id; // Added ID
  final String? name;
  final String? description; // Added description
  final double? distanceKm;
  final int? elevationGainM;
  final int? durationDays;
  final String? imageUrl;
  final String? difficultyLevel; // Added difficulty

  RouteModel({
    this.id,
    this.name, 
    this.description,
    this.distanceKm, 
    this.elevationGainM, 
    this.durationDays, 
    this.imageUrl,
    this.difficultyLevel
  });

  factory RouteModel.fromDynamic(dynamic d) {
    if (d == null) return RouteModel();
    if (d is Map) {
      double? parseDouble(dynamic v) {
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString());
      }

      int? parseInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        return int.tryParse(v.toString());
      }

      return RouteModel(
        id: parseInt(d['id']),
        name: d['name']?.toString(),
        description: d['description']?.toString(),
        distanceKm: parseDouble(d['totalDistanceKm'] ?? d['total_distance_km'] ?? d['distance_km'] ?? d['distance']),
        elevationGainM: parseInt(d['elevationGainM'] ?? d['elevation_gain_m'] ?? d['elevation_gain']),
        durationDays: parseInt(d['durationDays'] ?? d['estimated_duration_days'] ?? d['duration_days'] ?? d['duration']),
        imageUrl: d['imageUrl']?.toString() ?? d['image_url']?.toString(),
        difficultyLevel: d['difficulty_level']?.toString(),
      );
    }
    return RouteModel();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'distance_km': distanceKm,
        'elevation_gain_m': elevationGainM,
        'duration_days': durationDays,
        'image_url': imageUrl,
      };
}

class Plan {
  final int? id;
  final String? name;
  final String? description;
  final String? location;
  final List<RouteModel> routes;
  final List<EquipmentItem> equipmentList;
  final Map<String, dynamic>? personalizedEquipmentList;

  Plan({
    this.id, 
    this.name, 
    this.description, 
    this.location,
    List<RouteModel>? routes, 
    List<EquipmentItem>? equipmentList,
    this.personalizedEquipmentList,
  }) : routes = routes ?? [],
       equipmentList = equipmentList ?? [];

  factory Plan.fromDynamic(dynamic raw) {
    if (raw == null) return Plan();

    Map data;
    if (raw is Map) {
      data = Map.from(raw);
    } else {
      return Plan();
    }

    List<RouteModel> parsedRoutes = [];
    final routesRaw = data['routes'];
    print("📢 DEBUG PLAN ID: ${data['id']}");
    print("📢 ROUTES RAW TYPE: ${routesRaw.runtimeType}");
    print("📢 ROUTES RAW DATA: $routesRaw");
    if (routesRaw != null) {
      if (routesRaw is List) {
        // Standard list
        parsedRoutes = routesRaw.map((r) => RouteModel.fromDynamic(r)).toList();
      } else if (routesRaw is Map) {
        // Single object (1-to-1 or N-to-1 relation) -> Convert to List of 1
        parsedRoutes = [RouteModel.fromDynamic(routesRaw)];
      } else if (routesRaw is String) {
        try {
          final decoded = jsonDecode(routesRaw);
          if (decoded is List) {
            parsedRoutes = decoded.map((r) => RouteModel.fromDynamic(r)).toList();
          } else if (decoded is Map) {
             parsedRoutes = [RouteModel.fromDynamic(decoded)];
          }
        } catch (_) {}
      }
    }

    // Parse legacy list if needed
    List<EquipmentItem> parsedEquipment = [];
    // ... (Your existing logic for List parsing, omitted for brevity, logic remains valid)

    // 🟢 NEW: Parse the Map structure explicitly
    Map<String, dynamic>? parsedMap;
    final rawEqMap = data['personalized_equipment_list'];
    
    if (rawEqMap is Map) {
      parsedMap = Map<String, dynamic>.from(rawEqMap);
    } else if (rawEqMap is String) {
      try {
        final decoded = jsonDecode(rawEqMap);
        if (decoded is Map) {
          parsedMap = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    int? parseId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return Plan(
      id: parseId(data['id']),
      name: data['name']?.toString(),
      description: data['note']?.toString() ?? data['description']?.toString(),
      location: data['location']?.toString(),
      routes: parsedRoutes,
      equipmentList: parsedEquipment,
      personalizedEquipmentList: parsedMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'location': location,
        'routes': routes.map((r) => r.toJson()).toList(),
        'equipmentList': equipmentList.map((e) => e.toJson()).toList(),
        'personalized_equipment_list': personalizedEquipmentList,
      };
}