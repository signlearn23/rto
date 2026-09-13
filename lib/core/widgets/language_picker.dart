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
  LanguageOption('ta', 'தமிழ்'),
  LanguageOption('en', 'English'),
  LanguageOption('ml', 'മലയാളം'),
  LanguageOption('te', 'తెలుగు'),
  LanguageOption('hi', 'हिन्दी'),
];

/// Shows a bottom-sheet popup card with the 5 supported languages.
/// Tapping a language immediately closes the sheet and returns its code.
/// Returns null if the user dismisses without choosing.
Future<String?> showLanguagePicker(
  BuildContext context, {
  String? currentLanguageCode,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      // Re-read inside the builder rather than reusing the outer
      // colorScheme — same theme either way here, but this is the
      // context that's actually part of the bottom sheet's subtree.
      final colorScheme = Theme.of(context).colorScheme;
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
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              ...kAppLanguages.map((lang) {
                final selected = lang.code == currentLanguageCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: selected ? AppColors.primary.withOpacity(0.12) : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).pop(lang.code),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? AppColors.primary : colorScheme.outlineVariant,
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
                                  color: selected ? AppColors.primary : colorScheme.onSurface,
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
