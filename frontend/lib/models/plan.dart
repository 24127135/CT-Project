import 'dart:convert';

String _humanizeLabel(String raw) {
  // Replace underscores/dashes with spaces
  var s = raw.replaceAll(RegExp(r'[_\-]+'), ' ');
  // Insert space before camelCase capitals (fooBar -> foo Bar)
  s = s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  // Trim and split into words
  final parts = s.trim().split(RegExp(r'\s+'));
  // Capitalize each word
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
  final String? name;
  final double? distanceKm;
  final int? elevationGainM;
  final int? durationDays;
  final String? imageUrl;

  RouteModel({this.name, this.distanceKm, this.elevationGainM, this.durationDays, this.imageUrl});

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
        name: d['name']?.toString(),
        distanceKm: parseDouble(d['totalDistanceKm'] ?? d['total_distance_km'] ?? d['distance_km'] ?? d['distance']),
        elevationGainM: parseInt(d['elevationGainM'] ?? d['elevation_gain_m'] ?? d['elevation_gain']),
        durationDays: parseInt(d['durationDays'] ?? d['duration_days'] ?? d['duration']),
        imageUrl: d['imageUrl']?.toString() ?? d['image_url']?.toString(),
      );
    }
    return RouteModel();
  }

  Map<String, dynamic> toJson() => {
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
  final List<RouteModel> routes;
  final List<EquipmentItem> equipmentList;

  Plan({this.id, this.name, this.description, List<RouteModel>? routes, List<EquipmentItem>? equipmentList})
      : routes = routes ?? [],
        equipmentList = equipmentList ?? [];

  factory Plan.fromDynamic(dynamic raw) {
    if (raw == null) return Plan();

    Map data;
    if (raw is Map) {
      data = Map.from(raw);
    } else {
      // If it's not a map, return an empty Plan
      return Plan();
    }

    List<RouteModel> parsedRoutes = [];
    final routesRaw = data['routes'];
    if (routesRaw is List) {
      parsedRoutes = routesRaw.map((r) => RouteModel.fromDynamic(r)).toList();
    } else if (routesRaw is String) {
      try {
        final decoded = jsonDecode(routesRaw);
        if (decoded is List) {
          parsedRoutes = decoded.map((r) => RouteModel.fromDynamic(r)).toList();
        }
      } catch (_) {}
    }

    List<EquipmentItem> parsedEquipment = [];
    final eq = data['equipmentList'] ?? data['personalized_equipment_list'] ?? data['personal_equipment_list'] ?? data['equipment_list'];
    if (eq is List) {
      parsedEquipment = eq.map((e) => EquipmentItem.fromDynamic(e)).toList();
    } else if (eq is String) {
      try {
        final decoded = jsonDecode(eq);
        if (decoded is List) {
          parsedEquipment = decoded.map((e) => EquipmentItem.fromDynamic(e)).toList();
        }
        else if (decoded is Map) {
          // map of keys -> value (boolean or object)
          parsedEquipment = decoded.entries.where((en) {
            final v = en.value;
            if (v is bool) return v;
            return v != null;
          }).map((en) => EquipmentItem.fromDynamic({'name': en.key, ...((en.value is Map) ? Map<String, dynamic>.from(en.value) : {})})).toList();
        }
      } catch (_) {}
    } else if (eq is Map) {
      // handle object-shaped equipment lists: { key: true, key2: {...} }
      final m = Map<String, dynamic>.from(eq);
      parsedEquipment = m.entries.where((en) {
        final v = en.value;
        if (v is bool) return v;
        return v != null;
      }).map((en) {
        if (en.value is Map) {
          final nested = Map<String, dynamic>.from(en.value as Map);
          nested['name'] = nested['name'] ?? en.key;
          return EquipmentItem.fromDynamic(nested);
        }
        return EquipmentItem.fromDynamic(en.key);
      }).toList();
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
      routes: parsedRoutes,
      equipmentList: parsedEquipment,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'routes': routes.map((r) => r.toJson()).toList(),
        'equipmentList': equipmentList.map((e) => e.toJson()).toList(),
      };
}
