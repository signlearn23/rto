import '../models/driving_school_model.dart';

/// TODO: point this at your real data source (Firestore, REST API, or a
/// bundled JSON asset). Below is a stand-in so the UI compiles and runs.
class DrivingSchoolRepository {
  Future<List<DrivingSchool>> search({
    required String stateCode,
    String? query,
    String? serviceFilter,
    double? nearLat,
    double? nearLng,
  }) async {
    // Replace with actual fetch.
    var results = _sample;

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results
          .where((s) => s.name.toLowerCase().contains(q) || s.area.toLowerCase().contains(q))
          .toList();
    }
    if (serviceFilter != null && serviceFilter != 'All') {
      results = results.where((s) => s.services.contains(serviceFilter)).toList();
    }
    if (nearLat != null && nearLng != null) {
      results = [...results]..sort((a, b) {
          final da = _distanceSq(nearLat, nearLng, a.latitude, a.longitude);
          final db = _distanceSq(nearLat, nearLng, b.latitude, b.longitude);
          return da.compareTo(db);
        });
    }
    return results;
  }

  double _distanceSq(double lat, double lng, double? lat2, double? lng2) {
    if (lat2 == null || lng2 == null) return double.infinity;
    final dLat = lat - lat2, dLng = lng - lng2;
    return dLat * dLat + dLng * dLng;
  }

  static final _sample = <DrivingSchool>[
    DrivingSchool(
      id: '1',
      name: 'Meera Driving School',
      phoneNumbers: ['9842355207', '262262'],
      address: 'SPN Complex, Ground Floor, Vazhudareddy',
      area: 'Villupuram',
      pincode: '605401',
      services: const [
        'Motor Training Schools',
        'Driving License Consultants',
        'Motor Training Schools For Two Wheeler',
        'Motor Training Schools For Auto Rickshaw',
        'Motor Training Schools For Heavy Vehicle',
      ],
      email: 'shanmugam.meera@gmail.com',
      hoursOfOperation: const {'All Days': '10:00 am - 06:00 pm'},
    ),
  ];
}
