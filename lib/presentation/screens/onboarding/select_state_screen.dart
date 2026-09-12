import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/state_language_map.dart';
import '../../providers/app_state_provider.dart';
import '../home/home_screen.dart';

/// Combined onboarding flow: pick a state, then pick from a fixed set of
/// 5 languages (Tamil, English, Malayalam, Telugu, Hindi), then land on
/// HomeScreen. Both steps live in one widget.
///
/// NOTE: each state has a single asset file (e.g. assets/question_bank/
/// tamilnadu.json) containing questions/answers for all languages, keyed
/// by language code inside that file. So the language code just selects
/// which content to read from the state's file â€” no per-language file
/// lookup or fallback needed.
class OnboardingSelectionScreen extends StatefulWidget {
  const OnboardingSelectionScreen({super.key});

  @override
  State<OnboardingSelectionScreen> createState() =>
      _OnboardingSelectionScreenState();
}

enum _Step { state, language }

class _LanguageOption {
  final String code;
  final String displayName;
  const _LanguageOption(this.code, this.displayName);
}

const List<_LanguageOption> _kLanguages = [
  _LanguageOption('ta', 'à®¤à®®à®¿à®´à¯ (Tamil)'),
  _LanguageOption('en', 'English'),
  _LanguageOption('ml', 'à´®à´²à´¯à´¾à´³à´‚ (Malayalam)'),
  _LanguageOption('te', 'à°¤à±†à°²à±à°—à± (Telugu)'),
  _LanguageOption('hi', 'à¤¹à¤¿à¤¨à¥à¤¦à¥€ (Hindi)'),
];

class _OnboardingSelectionScreenState extends State<OnboardingSelectionScreen> {
  _Step _step = _Step.state;

  String? _selectedStateCode;
  String? _selectedLanguageCode;
  String _query = '';

  void _goToLanguageStep() {
    setState(() {
      _step = _Step.language;
      _selectedLanguageCode = null;
    });
  }

  void _goBackToStateStep() {
    setState(() {
      _step = _Step.state;
    });
  }

  Future<void> _finishOnboarding() async {
    final appState = context.read<AppStateProvider>();

    appState.setState(_selectedStateCode!);
    await appState.setLanguage(_selectedLanguageCode!);
    await appState.completeOnboarding();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_step == _Step.state ? 'Select Your State' : 'Select Language'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        leading: _step == _Step.language
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToStateStep,
              )
            : null,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _step == _Step.state
              ? _buildStateStep(key: const ValueKey('state'))
              : _buildLanguageStep(key: const ValueKey('language')),
        ),
      ),
    );
  }

  // ---------------- STEP 1: STATE ----------------

  Widget _buildStateStep({required Key key}) {
    final states = StateLanguageMap.all
        .where((s) => s.displayName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      key: key,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search state',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: states.isEmpty
              ? Center(
                  child: Text(
                    'No states match "$_query"',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: states.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final state = states[index];
                    final selected = state.code == _selectedStateCode;
                    return _SelectableCard(
                      title: state.displayName,
                      selected: selected,
                      onTap: () => setState(() => _selectedStateCode = state.code),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _ContinueButton(
            label: 'Continue',
            enabled: _selectedStateCode != null,
            onPressed: _goToLanguageStep,
          ),
        ),
      ],
    );
  }

  // ---------------- STEP 2: LANGUAGE (fixed 5 options) ----------------

  Widget _buildLanguageStep({required Key key}) {
    final stateInfo = StateLanguageMap.byCode(_selectedStateCode ?? '');

    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stateInfo != null
                ? 'Choose your preferred language for ${stateInfo.displayName}'
                : 'Choose your preferred language',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.3),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _kLanguages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final lang = _kLanguages[i];
                final selected = lang.code == _selectedLanguageCode;
                return _SelectableCard(
                  title: lang.displayName,
                  selected: selected,
                  onTap: () => setState(() => _selectedLanguageCode = lang.code),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _ContinueButton(
            label: 'Get Started',
            enabled: _selectedLanguageCode != null,
            onPressed: _finishOnboarding,
          ),
        ],
      ),
    );
  }
}

// ---------------- SHARED WIDGETS ----------------

class _SelectableCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : Colors.black87,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? AppColors.primary : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
