class Cinema {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final int totalTheaters;
  final double? distanceKm;

  const Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.totalTheaters,
    this.distanceKm,
  });

  Cinema copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    int? totalTheaters,
    double? distanceKm,
  }) {
    return Cinema(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      totalTheaters: totalTheaters ?? this.totalTheaters,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      totalTheaters: json['totalTheaters'] as int,
      distanceKm: json['distanceKm'] != null
          ? (json['distanceKm'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'totalTheaters': totalTheaters,
      if (distanceKm != null) 'distanceKm': distanceKm,
    };
  }
}
