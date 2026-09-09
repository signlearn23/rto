import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/state_language_map.dart';
import '../../providers/app_state_provider.dart';
import '../home/home_screen.dart';

/// Shows only the languages relevant to the previously selected state
/// (regional language + English), per the state->language mapping.
class SelectLanguageScreen extends StatefulWidget {
  final String stateCode;
  const SelectLanguageScreen({super.key, required this.stateCode});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final stateInfo = StateLanguageMap.byCode(widget.stateCode);
    final languages = stateInfo?.languages ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Language')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your preferred language for ${stateInfo?.displayName ?? ''}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ...languages.map((lang) {
              final selected = lang.code == _selected;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _selected = lang.code),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.primary : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                      color: selected ? AppColors.primary.withOpacity(0.08) : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(lang.displayName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                        if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () async {
                        final appState = context.read<AppStateProvider>();
                        await appState.setLanguage(_selected!);
                        await appState.completeOnboarding();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
