import '../local/hive_boxes.dart';
import '../models/driving_school_model.dart';

/// Stores user-contributed driving school entries.
/// Placeholder: persists locally via Hive only. Wire this up to your own
/// backend (Firestore / REST API) for moderation + shared visibility across
/// users before publishing the app.
class DrivingSchoolRepository {
  Future<void> submit(DrivingSchoolModel school) async {
    await HiveBoxes.schools.put(school.id, school.toJson());
  }

  List<DrivingSchoolModel> getAllSubmitted() {
    return HiveBoxes.schools.values
        .map((e) => DrivingSchoolModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
