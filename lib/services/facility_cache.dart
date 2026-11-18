import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/facility.dart';

class FacilityCache {
  FacilityCache({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'nearby_facilities_v1';

  final SharedPreferencesAsync _preferences;

  Future<List<Facility>?> load() async {
    final storedJson = await _preferences.getString(_storageKey);
    if (storedJson == null) return null;

    try {
      final decoded = jsonDecode(storedJson);
      if (decoded is! List) return null;
      return decoded
          .map(
            (item) => Facility.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(List<Facility> facilities) async {
    final encoded = jsonEncode(
      facilities.map((facility) => facility.toJson()).toList(growable: false),
    );
    await _preferences.setString(_storageKey, encoded);
  }
}
