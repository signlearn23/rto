import 'package:shared_preferences/shared_preferences.dart';

/// Persists bookmarked question IDs locally.
/// Requires the `shared_preferences` package — add it to pubspec.yaml if
/// your project doesn't already depend on it.
class BookmarkStore {
  BookmarkStore._();
  static final BookmarkStore instance = BookmarkStore._();

  static const _prefsKey = 'bookmarked_question_ids';

  SharedPreferences? _prefs;
  final Set<String> _ids = {};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(_prefs?.getStringList(_prefsKey) ?? const []);
    _initialized = true;
  }

  bool isBookmarked(String questionId) => _ids.contains(questionId);

  Future<void> toggle(String questionId) async {
    if (_ids.contains(questionId)) {
      _ids.remove(questionId);
    } else {
      _ids.add(questionId);
    }
    await _prefs?.setStringList(_prefsKey, _ids.toList());
  }
}
