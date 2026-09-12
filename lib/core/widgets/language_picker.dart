import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LanguageOption {
  final String code;
  final String displayName;
  const LanguageOption(this.code, this.displayName);
}

/// The 5 languages supported app-wide. Each state's question_bank JSON
/// contains content for all of these, keyed by language code, so this
/// list does not depend on which state is selected.
const List<LanguageOption> kAppLanguages = [
  LanguageOption('ta', 'தமிழ் (Tamil)'),
  LanguageOption('en', 'English'),
  LanguageOption('ml', 'മലയാళം (Malayalam)'),
  LanguageOption('te', 'తెలుగు (Telugu)'),
  LanguageOption('hi', 'हिन्दी (Hindi)'),
];

/// Shows a bottom-sheet popup card with the 5 supported languages.
/// Tapping a language immediately closes the sheet and returns its code.
/// Returns null if the user dismisses without choosing.
Future<String?> showLanguagePicker(
  BuildContext context, {
  String? currentLanguageCode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text(
                'Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ...kAppLanguages.map((lang) {
                final selected = lang.code == currentLanguageCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).pop(lang.code),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? AppColors.primary : Colors.grey.shade200,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                lang.displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  color: selected ? AppColors.primary : Colors.black87,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
