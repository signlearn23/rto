class DrivingSchool {
  final String id;
  final String name;
  final List<String> phoneNumbers;
  final String address;
  final String area;
  final String pincode;
  final List<String> services;
  final String? email;
  final Map<String, String> hoursOfOperation; // e.g. {'All Days': '10:00 am - 06:00 pm'}
  final String? paymentModes;
  final double? latitude;
  final double? longitude;
  bool isBookmarked;

  DrivingSchool({
    required this.id,
    required this.name,
    required this.phoneNumbers,
    required this.address,
    required this.area,
    required this.pincode,
    required this.services,
    this.email,
    this.hoursOfOperation = const {},
    this.paymentModes,
    this.latitude,
    this.longitude,
    this.isBookmarked = false,
  });

  factory DrivingSchool.fromJson(Map<String, dynamic> json) => DrivingSchool(
        id: json['id'] as String,
        name: json['name'] as String,
        phoneNumbers: List<String>.from(json['phoneNumbers'] ?? []),
        address: json['address'] as String? ?? '',
        area: json['area'] as String? ?? '',
        pincode: json['pincode'] as String? ?? '',
        services: List<String>.from(json['services'] ?? []),
        email: json['email'] as String?,
        hoursOfOperation: Map<String, String>.from(json['hoursOfOperation'] ?? {}),
        paymentModes: json['paymentModes'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
