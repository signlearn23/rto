import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Manages how many exam attempts a user has left, and whether they have
/// purchased "Remove Ads" (which also grants unlimited exam attempts).
class ExamCreditManager {
  final SharedPreferences _prefs;

  ExamCreditManager(this._prefs);

  bool get isAdsRemoved => _prefs.getBool(AppConstants.keyAdsRemoved) ?? false;

  Future<void> setAdsRemoved(bool value) async {
    await _prefs.setBool(AppConstants.keyAdsRemoved, value);
  }

  int get availableCredits {
    if (!_prefs.containsKey(AppConstants.keyExamCredits)) {
      return AppConstants.freeAttemptsOnInstall;
    }
    return _prefs.getInt(AppConstants.keyExamCredits) ?? 0;
  }

  bool canStartExam() => isAdsRemoved || availableCredits > 0;

  /// Call right before starting an exam attempt.
  Future<void> consumeCredit() async {
    if (isAdsRemoved) return;
    final current = availableCredits;
    await _prefs.setInt(AppConstants.keyExamCredits, current > 0 ? current - 1 : 0);
  }

  /// Call after the user finishes watching a rewarded ad.
  Future<void> addCreditFromAd() async {
    await _prefs.setInt(AppConstants.keyExamCredits, availableCredits + 1);
  }
}
