/// Maps each Indian state to its list of supported languages for this app.
/// Every state always includes English ('en') plus its regional language.
/// Language codes match files under assets/question_bank/<state_code>_<lang_code>.json
class StateLanguageMap {
  StateLanguageMap._();

  static const Map<String, StateInfo> states = {
    'tamilnadu': StateInfo(
      code: 'tamilnadu',
      displayName: 'Tamil Nadu',
      languages: [
        LanguageInfo(code: 'ta', displayName: 'தமிழ்'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    'kerala': StateInfo(
      code: 'kerala',
      displayName: 'Kerala',
      languages: [
        LanguageInfo(code: 'ml', displayName: 'മലയാളം'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    'karnataka': StateInfo(
      code: 'karnataka',
      displayName: 'Karnataka',
      languages: [
        LanguageInfo(code: 'kn', displayName: 'ಕನ್ನಡ'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    'andhrapradesh': StateInfo(
      code: 'andhrapradesh',
      displayName: 'Andhra Pradesh',
      languages: [
        LanguageInfo(code: 'te', displayName: 'తెలుగు'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    'maharashtra': StateInfo(
      code: 'maharashtra',
      displayName: 'Maharashtra',
      languages: [
        LanguageInfo(code: 'mr', displayName: 'मराठी'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    'uttarpradesh': StateInfo(
      code: 'uttarpradesh',
      displayName: 'Uttar Pradesh',
      languages: [
        LanguageInfo(code: 'hi', displayName: 'हिन्दी'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    'westbengal': StateInfo(
      code: 'westbengal',
      displayName: 'West Bengal',
      languages: [
        LanguageInfo(code: 'bn', displayName: 'বাংলা'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    'gujarat': StateInfo(
      code: 'gujarat',
      displayName: 'Gujarat',
      languages: [
        LanguageInfo(code: 'gu', displayName: 'ગુજરાતી'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    'punjab': StateInfo(
      code: 'punjab',
      displayName: 'Punjab',
      languages: [
        LanguageInfo(code: 'pa', displayName: 'ਪੰਜਾਬੀ'),
        LanguageInfo(code: 'en', displayName: 'English'),
      ],
    ),
    // Add remaining states/UTs following the same pattern.
    // Every entry must keep 'en' as a fallback language.
  };

  static List<StateInfo> get all => states.values.toList();

  static StateInfo? byCode(String code) => states[code];
}

class StateInfo {
  final String code;
  final String displayName;
  final List<LanguageInfo> languages;

  const StateInfo({
    required this.code,
    required this.displayName,
    required this.languages,
  });
}

class LanguageInfo {
  final String code;
  final String displayName;

  const LanguageInfo({required this.code, required this.displayName});
}
