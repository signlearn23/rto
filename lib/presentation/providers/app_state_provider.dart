import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/exam_credit_manager.dart';

/// Holds app-wide state: selected RTO state, selected language, dark mode,
/// onboarding status, and exposes the ExamCreditManager.
class AppStateProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  late final ExamCreditManager creditManager;

  AppStateProvider(this.prefs) {
    creditManager = ExamCreditManager(prefs);
  }

  String? get selectedState => prefs.getString(AppConstants.keySelectedState);
  String? get selectedLanguage => prefs.getString(AppConstants.keySelectedLanguage);
  bool get isDarkMode => prefs.getBool(AppConstants.keyDarkMode) ?? false;
  bool get onboardingDone => prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

  Future<void> setState(String stateCode) async {
    await prefs.setString(AppConstants.keySelectedState, stateCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    await prefs.setString(AppConstants.keySelectedLanguage, languageCode);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await prefs.setBool(AppConstants.keyDarkMode, value);
    notifyListeners();
  }

  bool get isAdsRemoved => creditManager.isAdsRemoved;

  Future<void> markAdsRemoved() async {
    await creditManager.setAdsRemoved(true);
    notifyListeners();
  }

  int get examCredits => creditManager.availableCredits;

  Future<void> consumeExamCredit() async {
    await creditManager.consumeCredit();
    notifyListeners();
  }

  Future<void> addExamCreditFromAd() async {
    await creditManager.addCreditFromAd();
    notifyListeners();
  }

  /// Generic credit grant, not tied to watching a rewarded ad â€” e.g. a
  /// promo/bonus credit triggered from the home screen. Reuses the same
  /// underlying credit bump as addExamCreditFromAd(); if
  /// ExamCreditManager later grows a distinct "bonus" method with
  /// different bookkeeping, swap the call below to that instead.
  Future<void> addExamCredit() async {
    await creditManager.addCreditFromAd();
    notifyListeners();
  }
}
