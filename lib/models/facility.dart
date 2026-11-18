class Facility {
  const Facility({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String address;
  final String type;
  final double latitude;
  final double longitude;
  final String openingHours;
  final double? distanceKm;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'type': type,
    'latitude': latitude,
    'longitude': longitude,
    'openingHours': openingHours,
    'distanceKm': distanceKm,
  };

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      type: json['type'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      openingHours: json['openingHours'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }
}
