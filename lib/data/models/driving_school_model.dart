class DrivingSchoolModel {
  final String id;
  final String name;
  final String type; // Car / Bike / Both
  final String location; // free text, no maps dependency
  final String timing;
  final String cost;
  final String contact;
  final DateTime submittedAt;

  DrivingSchoolModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.timing,
    required this.cost,
    required this.contact,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'location': location,
        'timing': timing,
        'cost': cost,
        'contact': contact,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory DrivingSchoolModel.fromJson(Map<String, dynamic> json) => DrivingSchoolModel(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        location: json['location'],
        timing: json['timing'],
        cost: json['cost'],
        contact: json['contact'],
        submittedAt: DateTime.parse(json['submittedAt']),
      );
}
