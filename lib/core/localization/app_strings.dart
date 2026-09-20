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

  // ---- Settings screen ----
  String get settingsTitle => _t('settings_title');
  String get preferences => _t('preferences');
  String get changeState => _t('change_state');
  String get notSet => _t('not_set');
  String get changeLanguageTitle => _t('change_language_title');
  String get darkMode => _t('dark_mode');
  String get rtoResources => _t('rto_resources');
  String get downloadForms => _t('download_forms');
  String get downloadFormsSub => _t('download_forms_sub');
  String get formsTitle => _t('forms_title');
  String get formsBody => _t('forms_body');
  String get licenseProcess => _t('license_process');
  String get licenseProcessSub => _t('license_process_sub');
  String get licenseProcessBody => _t('license_process_body');
  String get about => _t('about');
  String get contactUs => _t('contact_us');
  String get shareApp => _t('share_app');
  String get privacyPolicy => _t('privacy_policy');
  String get termsAndConditions => _t('terms_and_conditions');
  String get disclaimer => _t('disclaimer');
  String get removeAdsBanner => _t('remove_ads_banner');

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
      'settings_title': 'Settings',
      'preferences': 'Preferences',
      'change_state': 'Change State',
      'not_set': 'Not set',
      'change_language_title': 'Change Language',
      'dark_mode': 'Dark Mode',
      'rto_resources': 'RTO Resources',
      'download_forms': 'Download RTO Forms',
      'download_forms_sub': 'Form 1, 4, 5, 6, 8, 20, 21, 22 and more',
      'forms_title': 'RTO Forms',
      'forms_body': 'List and download links for common RTO forms (Form 1 - Medical Certificate, Form 4 - Application for LL, Form 5 - Certificate by driving school, Form 6 - Application for DL, Form 8 - Notice of transfer, Form 20 - Registration application, Form 21 - Sale certificate, Form 22 - Roadworthiness certificate). Hook this screen up to your hosted PDFs.',
      'license_process': 'Driving License Process',
      'license_process_sub': 'Step-by-step LL & DL procedure',
      'license_process_body': '1. Apply for Learner\'s License (LL) online via Sarathi/state portal.\n2. Pass the LL computer-based test (this app helps you prepare!).\n3. LL is valid for 6 months; practice driving during this period.\n4. After 30 days from LL issue, apply for Permanent Driving License (DL).\n5. Attend the RTO driving test slot.\n6. On passing, DL is issued/dispatched to your address.',
      'about': 'About',
      'contact_us': 'Contact Us',
      'share_app': 'Share App',
      'privacy_policy': 'Privacy Policy',
      'terms_and_conditions': 'Terms & Conditions',
      'disclaimer': 'Disclaimer',
      'remove_ads_banner': 'Remove Ads Forever — just ₹39',
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
      'settings_title': 'அமைப்புகள்',
      'preferences': 'விருப்பங்கள்',
      'change_state': 'மாநிலத்தை மாற்று',
      'not_set': 'அமைக்கப்படவில்லை',
      'change_language_title': 'மொழியை மாற்று',
      'dark_mode': 'இருண்ட பயன்முறை',
      'rto_resources': 'RTO வளங்கள்',
      'download_forms': 'RTO படிவங்களைப் பதிவிறக்குக',
      'download_forms_sub': 'படிவம் 1, 4, 5, 6, 8, 20, 21, 22 மற்றும் பல',
      'forms_title': 'RTO படிவங்கள்',
      'forms_body': 'பொதுவான RTO படிவங்களின் பட்டியலும் பதிவிறக்க இணைப்புகளும் (படிவம் 1 - மருத்துவச் சான்றிதழ், படிவம் 4 - LL விண்ணப்பம், படிவம் 5 - ஓட்டுநர் பள்ளிச் சான்றிதழ், படிவம் 6 - DL விண்ணப்பம், படிவம் 8 - உரிமை மாற்ற அறிவிப்பு, படிவம் 20 - பதிவு விண்ணப்பம், படிவம் 21 - விற்பனைச் சான்றிதழ், படிவம் 22 - சாலைத் தகுதிச் சான்றிதழ்).',
      'license_process': 'ஓட்டுநர் உரிமச் செயல்முறை',
      'license_process_sub': 'LL மற்றும் DL நடைமுறை, படிப்படியாக',
      'license_process_body': '1. Sarathi/மாநில இணையதளம் வழியாக கற்றல் உரிமத்திற்கு (LL) ஆன்லைனில் விண்ணப்பிக்கவும்.\n2. LL கணினி வழித் தேர்வில் தேர்ச்சி பெறவும் (இந்த ஆப் உங்களைத் தயார்படுத்த உதவும்!).\n3. LL 6 மாதங்களுக்குச் செல்லுபடியாகும்; இந்தக் காலத்தில் வாகனம் ஓட்டப் பயிற்சி செய்யவும்.\n4. LL வழங்கப்பட்ட 30 நாட்களுக்குப் பிறகு நிரந்தர ஓட்டுநர் உரிமத்திற்கு (DL) விண்ணப்பிக்கவும்.\n5. RTO ஓட்டுநர் தேர்வுக்கான நேரத்தில் கலந்துகொள்ளவும்.\n6. தேர்ச்சி பெற்றதும் DL உங்கள் முகவரிக்கு வழங்கப்படும்/அனுப்பப்படும்.',
      'about': 'பற்றி',
      'contact_us': 'எங்களைத் தொடர்பு கொள்ள',
      'share_app': 'ஆப்பைப் பகிர்க',
      'privacy_policy': 'தனியுரிமைக் கொள்கை',
      'terms_and_conditions': 'விதிமுறைகள் & நிபந்தனைகள்',
      'disclaimer': 'மறுப்பு அறிவிப்பு',
      'remove_ads_banner': 'என்றென்றும் விளம்பரங்கள் இல்லை — வெறும் ₹39',
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
      'settings_title': 'సెట్టింగ్స్',
      'preferences': 'ప్రాధాన్యతలు',
      'change_state': 'రాష్ట్రాన్ని మార్చండి',
      'not_set': 'సెట్ చేయలేదు',
      'change_language_title': 'భాష మార్చండి',
      'dark_mode': 'డార్క్ మోడ్',
      'rto_resources': 'RTO వనరులు',
      'download_forms': 'RTO ఫారాలను డౌన్‌లోడ్ చేయండి',
      'download_forms_sub': 'ఫారం 1, 4, 5, 6, 8, 20, 21, 22 మరియు మరిన్ని',
      'forms_title': 'RTO ఫారాలు',
      'forms_body': 'సాధారణ RTO ఫారాల జాబితా మరియు డౌన్‌లోడ్ లింకులు (ఫారం 1 - మెడికల్ సర్టిఫికెట్, ఫారం 4 - LL దరఖాస్తు, ఫారం 5 - డ్రైవింగ్ స్కూల్ సర్టిఫికెట్, ఫారం 6 - DL దరఖాస్తు, ఫారం 8 - బదిలీ నోటీసు, ఫారం 20 - రిజిస్ట్రేషన్ దరఖాస్తు, ఫారం 21 - అమ్మకపు సర్టిఫికెట్, ఫారం 22 - రోడ్డు యోగ్యత సర్టిఫికెట్).',
      'license_process': 'డ్రైవింగ్ లైసెన్స్ ప్రక్రియ',
      'license_process_sub': 'LL & DL విధానం, దశలవారీగా',
      'license_process_body': '1. Sarathi/రాష్ట్ర పోర్టల్ ద్వారా లెర్నర్స్ లైసెన్స్ (LL) కోసం ఆన్‌లైన్‌లో దరఖాస్తు చేయండి.\n2. LL కంప్యూటర్ ఆధారిత పరీక్షలో ఉత్తీర్ణులవ్వండి (ఈ యాప్ మీ సన్నద్ధతకు సహాయపడుతుంది!).\n3. LL 6 నెలల పాటు చెల్లుబాటు అవుతుంది; ఈ కాలంలో డ్రైవింగ్ ప్రాక్టీస్ చేయండి.\n4. LL జారీ అయిన 30 రోజుల తర్వాత శాశ్వత డ్రైవింగ్ లైసెన్స్ (DL) కోసం దరఖాస్తు చేయండి.\n5. RTO డ్రైవింగ్ టెస్ట్ స్లాట్‌కు హాజరవ్వండి.\n6. ఉత్తీర్ణులైతే DL మీ చిరునామాకు జారీ/పంపబడుతుంది.',
      'about': 'గురించి',
      'contact_us': 'మమ్మల్ని సంప్రదించండి',
      'share_app': 'యాప్‌ను షేర్ చేయండి',
      'privacy_policy': 'గోప్యతా విధానం',
      'terms_and_conditions': 'నిబంధనలు & షరతులు',
      'disclaimer': 'డిస్‌క్లెయిమర్',
      'remove_ads_banner': 'ఇక ఎప్పటికీ ప్రకటనలు వద్దు — కేవలం ₹39',
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
      'settings_title': 'ക്രമീകരണങ്ങൾ',
      'preferences': 'മുൻഗണനകൾ',
      'change_state': 'സംസ്ഥാനം മാറ്റുക',
      'not_set': 'സജ്ജമാക്കിയിട്ടില്ല',
      'change_language_title': 'ഭാഷ മാറ്റുക',
      'dark_mode': 'ഡാർക്ക് മോഡ്',
      'rto_resources': 'RTO വിഭവങ്ങൾ',
      'download_forms': 'RTO ഫോമുകൾ ഡൗൺലോഡ് ചെയ്യുക',
      'download_forms_sub': 'ഫോം 1, 4, 5, 6, 8, 20, 21, 22 എന്നിവയും മറ്റും',
      'forms_title': 'RTO ഫോമുകൾ',
      'forms_body': 'സാധാരണ RTO ഫോമുകളുടെ പട്ടികയും ഡൗൺലോഡ് ലിങ്കുകളും (ഫോം 1 - മെഡിക്കൽ സർട്ടിഫിക്കറ്റ്, ഫോം 4 - LL അപേക്ഷ, ഫോം 5 - ഡ്രൈവിംഗ് സ്കൂൾ സർട്ടിഫിക്കറ്റ്, ഫോം 6 - DL അപേക്ഷ, ഫോം 8 - ഉടമസ്ഥാവകാശ കൈമാറ്റ അറിയിപ്പ്, ഫോം 20 - രജിസ്ട്രേഷൻ അപേക്ഷ, ഫോം 21 - വിൽപ്പന സർട്ടിഫിക്കറ്റ്, ഫോം 22 - റോഡ് യോഗ്യതാ സർട്ടിഫിക്കറ്റ്).',
      'license_process': 'ഡ്രൈവിംഗ് ലൈസൻസ് നടപടിക്രമം',
      'license_process_sub': 'LL, DL നടപടിക്രമം ഘട്ടം ഘട്ടമായി',
      'license_process_body': '1. Sarathi/സംസ്ഥാന പോർട്ടൽ വഴി ലേണേഴ്സ് ലൈസൻസിന് (LL) ഓൺലൈനായി അപേക്ഷിക്കുക.\n2. LL കമ്പ്യൂട്ടർ അടിസ്ഥാനത്തിലുള്ള ടെസ്റ്റ് പാസാകുക (ഈ ആപ്പ് നിങ്ങളെ തയ്യാറെടുക്കാൻ സഹായിക്കുന്നു!).\n3. LL 6 മാസത്തേക്ക് സാധുവാണ്; ഈ കാലയളവിൽ ഡ്രൈവിംഗ് പരിശീലിക്കുക.\n4. LL ലഭിച്ച് 30 ദിവസത്തിന് ശേഷം സ്ഥിരം ഡ്രൈവിംഗ് ലൈസൻസിന് (DL) അപേക്ഷിക്കുക.\n5. RTO ഡ്രൈവിംഗ് ടെസ്റ്റ് സ്ലോട്ടിൽ പങ്കെടുക്കുക.\n6. വിജയിച്ചാൽ DL നിങ്ങളുടെ വിലാസത്തിൽ നൽകും/അയയ്ക്കും.',
      'about': 'കുറിച്ച്',
      'contact_us': 'ഞങ്ങളെ ബന്ധപ്പെടുക',
      'share_app': 'ആപ്പ് പങ്കിടുക',
      'privacy_policy': 'സ്വകാര്യതാ നയം',
      'terms_and_conditions': 'നിബന്ധനകളും വ്യവസ്ഥകളും',
      'disclaimer': 'നിരാകരണം',
      'remove_ads_banner': 'എന്നെന്നേക്കുമായി പരസ്യങ്ങൾ ഒഴിവാക്കൂ — വെറും ₹39',
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
      'settings_title': 'सेटिंग्स',
      'preferences': 'प्राथमिकताएं',
      'change_state': 'राज्य बदलें',
      'not_set': 'सेट नहीं है',
      'change_language_title': 'भाषा बदलें',
      'dark_mode': 'डार्क मोड',
      'rto_resources': 'RTO संसाधन',
      'download_forms': 'RTO फॉर्म डाउनलोड करें',
      'download_forms_sub': 'फॉर्म 1, 4, 5, 6, 8, 20, 21, 22 और अन्य',
      'forms_title': 'RTO फॉर्म',
      'forms_body': 'आम RTO फॉर्म की सूची और डाउनलोड लिंक (फॉर्म 1 - मेडिकल सर्टिफिकेट, फॉर्म 4 - LL के लिए आवेदन, फॉर्म 5 - ड्राइविंग स्कूल का प्रमाणपत्र, फॉर्म 6 - DL के लिए आवेदन, फॉर्म 8 - स्थानांतरण की सूचना, फॉर्म 20 - पंजीकरण आवेदन, फॉर्म 21 - बिक्री प्रमाणपत्र, फॉर्म 22 - सड़क योग्यता प्रमाणपत्र)।',
      'license_process': 'ड्राइविंग लाइसेंस प्रक्रिया',
      'license_process_sub': 'LL और DL की चरण-दर-चरण प्रक्रिया',
      'license_process_body': '1. Sarathi/राज्य पोर्टल के माध्यम से ऑनलाइन लर्नर लाइसेंस (LL) के लिए आवेदन करें।\n2. LL का कंप्यूटर-आधारित टेस्ट पास करें (यह ऐप आपकी तैयारी में मदद करता है!)।\n3. LL 6 महीने के लिए वैध होता है; इस अवधि में गाड़ी चलाने का अभ्यास करें।\n4. LL जारी होने के 30 दिन बाद स्थायी ड्राइविंग लाइसेंस (DL) के लिए आवेदन करें।\n5. RTO में ड्राइविंग टेस्ट के स्लॉट में शामिल हों।\n6. पास होने पर DL आपके पते पर जारी/भेज दिया जाता है।',
      'about': 'ऐप के बारे में',
      'contact_us': 'हमसे संपर्क करें',
      'share_app': 'ऐप शेयर करें',
      'privacy_policy': 'गोपनीयता नीति',
      'terms_and_conditions': 'नियम और शर्तें',
      'disclaimer': 'अस्वीकरण',
      'remove_ads_banner': 'हमेशा के लिए विज्ञापन हटाएं — सिर्फ़ ₹39',
    },
  };
}
