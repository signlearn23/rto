class AppConstants {
  AppConstants._();

  // Exam rules
  static const int questionsPerExam = 10;
  static const int passMarkOutOf10 = 7;
  static const int secondsPerQuestion = 30;
  static const int freeAttemptsOnInstall = 1;

  // In-app purchase
  static const String removeAdsProductId = 'remove_ads_39';
  static const String removeAdsPriceLabel = '₹39';

  // AdMob - TEST IDs (Google public test units). Replace before release.
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String rewardedAdUnitId = 'ca-app-pub-3699335518824613/8171531808';

  // Hive box names
  static const String boxSettings = 'settings_box';
  static const String boxResults = 'results_box';
  static const String boxSchools = 'schools_box';
  static const String boxBookmarks = 'bookmarks_box';

  // Preference keys
  static const String keySelectedState = 'selected_state';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyDarkMode = 'dark_mode';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyAdsRemoved = 'ads_removed';
  static const String keyExamCredits = 'exam_credits';

  static const String contactEmail = 'support@example.com';
  static const String privacyPolicyUrl = 'https://example.com/privacy-policy';
  static const String termsUrl = 'https://example.com/terms';
  static const String shareText =
      'Prepare for your RTO Learning License exam with this free app! Download now: https://play.google.com/store/apps/details?id=com.example.rtoexam';
}
