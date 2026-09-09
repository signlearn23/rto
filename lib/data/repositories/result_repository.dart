import '../local/hive_boxes.dart';
import '../models/exam_attempt_model.dart';

class ResultRepository {
  Future<void> saveAttempt(ExamAttempt attempt) async {
    await HiveBoxes.results.put(attempt.id, attempt.toJson());
  }

  List<ExamAttempt> getAllAttempts() {
    final box = HiveBoxes.results;
    final attempts = box.values
        .map((e) => ExamAttempt.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    attempts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return attempts;
  }

  Future<void> deleteAttempt(String id) async {
    await HiveBoxes.results.delete(id);
  }

  Future<void> clearAll() async {
    await HiveBoxes.results.clear();
  }
}
