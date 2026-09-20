/// UI strings for the app's own screens (not question content).
/// Supported languages: en, ta, te, ml, hi. Falls back to English.
///
/// Usage:
///   final s = AppStrings(appState.selectedLanguage ?? 'en');
///   Text(s.questionBank)
///
/// To add a string: add a key to every language map below, then add a getter.
class AppStrings {
  final String lang;
  const AppStrings(this.lang);

  String _t(String key) => _values[lang]?[key] ?? _values['en']![key] ?? key;

  // ---- Home screen ----
  String get appTitleFallback => _t('app_title_fallback');
  String get changeLanguage => _t('change_language');
  String get homeHeading => _t('home_heading');

  String get questionBank => _t('question_bank');
  String get questionBankSub => _t('question_bank_sub');

  String get practiceMode => _t('practice_mode');
  String get practiceModeSub => _t('practice_mode_sub');

  String get examMode => _t('exam_mode');
  String examModeSub(int questions, int seconds, int passMark) => _t('exam_mode_sub')
      .replaceAll('{q}', '$questions')
      .replaceAll('{s}', '$seconds')
      .replaceAll('{p}', '$passMark');

  String get badgePro => _t('badge_pro');
  String get badgeWatchAd => _t('badge_watch_ad');
  String creditsLeft(int n) => _t('credits_left').replaceAll('{n}', '$n');

  String get resultHistory => _t('result_history');
  String get resultHistorySub => _t('result_history_sub');

  String get drivingSchools => _t('driving_schools');
  String get drivingSchoolsSub => _t('driving_schools_sub');

  String get removeAds => _t('remove_ads');
  String get removeAdsSub => _t('remove_ads_sub');

  String get adNotReady => _t('ad_not_ready');

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'app_title_fallback': 'RTO Exam',
      'change_language': 'Change language',
      'home_heading': 'Prepare for your Learning License Test',
      'question_bank': 'Question Bank',
      'question_bank_sub': 'Browse all topics & signs',
      'practice_mode': 'Practice Mode',
      'practice_mode_sub': 'No time limit, learn at ease',
      'exam_mode': 'Exam Mode',
      'exam_mode_sub': '{q} Qs - {s}s each {p}/{q} to pass',
      'badge_pro': 'PRO',
      'badge_watch_ad': 'Watch Ad',
      'credits_left': '{n} left',
      'result_history': 'Result History',
      'result_history_sub': 'Track your past attempts',
      'driving_schools': 'Driving Schools',
      'driving_schools_sub': 'Find schools near you',
      'remove_ads': 'Remove Ads',
      'remove_ads_sub': 'One-time ₹39 no ads forever',
      'ad_not_ready': 'Ad not ready yet, try again in a moment',
    },
    'ta': {
      'app_title_fallback': 'RTO தேர்வு',
      'change_language': 'மொழியை மாற்று',
      'home_heading': 'உங்கள் கற்றல் உரிமத் தேர்வுக்குத் தயாராகுங்கள்',
      'question_bank': 'கேள்வி வங்கி',
      'question_bank_sub': 'அனைத்து தலைப்புகள் மற்றும் அடையாளங்களைப் பாருங்கள்',
      'practice_mode': 'பயிற்சி முறை',
      'practice_mode_sub': 'நேர வரம்பு இல்லை, நிதானமாகக் கற்றுக்கொள்ளுங்கள்',
      'exam_mode': 'தேர்வு முறை',
      'exam_mode_sub': '{q} கேள்விகள் - ஒவ்வொன்றுக்கும் {s} வினாடி, தேர்ச்சிக்கு {p}/{q}',
      'badge_pro': 'PRO',
      'badge_watch_ad': 'விளம்பரம் பார்க்க',
      'credits_left': '{n} மீதம்',
      'result_history': 'முடிவு வரலாறு',
      'result_history_sub': 'உங்கள் முந்தைய முயற்சிகளைப் பாருங்கள்',
      'driving_schools': 'ஓட்டுநர் பள்ளிகள்',
      'driving_schools_sub': 'உங்கள் அருகிலுள்ள பள்ளிகளைக் கண்டறியுங்கள்',
      'remove_ads': 'விளம்பரங்களை நீக்கு',
      'remove_ads_sub': 'ஒரு முறை ₹39, என்றென்றும் விளம்பரம் இல்லை',
      'ad_not_ready': 'விளம்பரம் இன்னும் தயாராகவில்லை, சிறிது நேரம் கழித்து முயற்சிக்கவும்',
    },
    'te': {
      'app_title_fallback': 'RTO పరీక్ష',
      'change_language': 'భాష మార్చండి',
      'home_heading': 'మీ లెర్నింగ్ లైసెన్స్ టెస్ట్‌కు సిద్ధమవ్వండి',
      'question_bank': 'ప్రశ్నల బ్యాంక్',
      'question_bank_sub': 'అన్ని అంశాలు & గుర్తులు చూడండి',
      'practice_mode': 'ప్రాక్టీస్ మోడ్',
      'practice_mode_sub': 'సమయ పరిమితి లేదు, హాయిగా నేర్చుకోండి',
      'exam_mode': 'పరీక్ష మోడ్',
      'exam_mode_sub': '{q} ప్రశ్నలు - ఒక్కోదానికి {s} సెకన్లు, పాస్ కావాలంటే {p}/{q}',
      'badge_pro': 'PRO',
      'badge_watch_ad': 'ప్రకటన చూడండి',
      'credits_left': '{n} మిగిలాయి',
      'result_history': 'ఫలితాల చరిత్ర',
      'result_history_sub': 'మీ గత ప్రయత్నాలను చూడండి',
      'driving_schools': 'డ్రైవింగ్ స్కూళ్లు',
      'driving_schools_sub': 'మీ దగ్గరలోని స్కూళ్లను కనుగొనండి',
      'remove_ads': 'ప్రకటనలు తొలగించండి',
      'remove_ads_sub': 'ఒక్కసారి ₹39, ఇక ఎప్పటికీ ప్రకటనలు ఉండవు',
      'ad_not_ready': 'ప్రకటన ఇంకా సిద్ధంగా లేదు, కాసేపటి తర్వాత మళ్లీ ప్రయత్నించండి',
    },
    'ml': {
      'app_title_fallback': 'RTO പരീക്ഷ',
      'change_language': 'ഭാഷ മാറ്റുക',
      'home_heading': 'നിങ്ങളുടെ ലേണേഴ്സ് ലൈസൻസ് ടെസ്റ്റിന് തയ്യാറെടുക്കൂ',
      'question_bank': 'ചോദ്യ ബാങ്ക്',
      'question_bank_sub': 'എല്ലാ വിഷയങ്ങളും അടയാളങ്ങളും കാണുക',
      'practice_mode': 'പ്രാക്ടീസ് മോഡ്',
      'practice_mode_sub': 'സമയപരിധിയില്ല, സാവധാനം പഠിക്കാം',
      'exam_mode': 'പരീക്ഷാ മോഡ്',
      'exam_mode_sub': '{q} ചോദ്യങ്ങൾ - ഓരോന്നിനും {s} സെക്കൻഡ്, വിജയിക്കാൻ {p}/{q}',
      'badge_pro': 'PRO',
      'badge_watch_ad': 'പരസ്യം കാണുക',
      'credits_left': '{n} ബാക്കി',
      'result_history': 'ഫല ചരിത്രം',
      'result_history_sub': 'നിങ്ങളുടെ മുൻ ശ്രമങ്ങൾ കാണുക',
      'driving_schools': 'ഡ്രൈവിംഗ് സ്കൂളുകൾ',
      'driving_schools_sub': 'നിങ്ങളുടെ അടുത്തുള്ള സ്കൂളുകൾ കണ്ടെത്തുക',
      'remove_ads': 'പരസ്യങ്ങൾ ഒഴിവാക്കുക',
      'remove_ads_sub': 'ഒറ്റത്തവണ ₹39, എന്നെന്നേക്കുമായി പരസ്യങ്ങളില്ല',
      'ad_not_ready': 'പരസ്യം ഇതുവരെ തയ്യാറായിട്ടില്ല, അൽപ്പസമയം കഴിഞ്ഞ് വീണ്ടും ശ്രമിക്കുക',
    },
    'hi': {
      'app_title_fallback': 'RTO परीक्षा',
      'change_language': 'भाषा बदलें',
      'home_heading': 'अपने लर्निंग लाइसेंस टेस्ट की तैयारी करें',
      'question_bank': 'प्रश्न बैंक',
      'question_bank_sub': 'सभी विषय और चिन्ह देखें',
      'practice_mode': 'अभ्यास मोड',
      'practice_mode_sub': 'समय सीमा नहीं, आराम से सीखें',
      'exam_mode': 'परीक्षा मोड',
      'exam_mode_sub': '{q} प्रश्न - प्रत्येक {s} सेकंड, पास होने के लिए {p}/{q}',
      'badge_pro': 'PRO',
      'badge_watch_ad': 'विज्ञापन देखें',
      'credits_left': '{n} बाकी',
      'result_history': 'परिणाम इतिहास',
      'result_history_sub': 'अपने पिछले प्रयास देखें',
      'driving_schools': 'ड्राइविंग स्कूल',
      'driving_schools_sub': 'अपने पास के स्कूल खोजें',
      'remove_ads': 'विज्ञापन हटाएं',
      'remove_ads_sub': 'एक बार ₹39, हमेशा विज्ञापन-मुक्त',
      'ad_not_ready': 'विज्ञापन अभी तैयार नहीं है, कृपया थोड़ी देर में पुनः प्रयास करें',
    },
  };
}
