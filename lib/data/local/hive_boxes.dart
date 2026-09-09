import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

/// Initializes Hive and opens the boxes used across the app.
/// Data is stored as plain Map<String, dynamic> (via model.toJson()),
/// so no generated TypeAdapters are required - keeps the scaffold simple.
class HiveBoxes {
  HiveBoxes._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.boxResults);
    await Hive.openBox(AppConstants.boxSchools);
    await Hive.openBox(AppConstants.boxBookmarks);
  }

  static Box get results => Hive.box(AppConstants.boxResults);
  static Box get schools => Hive.box(AppConstants.boxSchools);
  static Box get bookmarks => Hive.box(AppConstants.boxBookmarks);
}
