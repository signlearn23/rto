import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/state_language_map.dart';
import '../../providers/app_state_provider.dart';
import '../onboarding/select_state_screen.dart';
import '../onboarding/select_language_screen.dart';
import '../remove_ads/remove_ads_screen.dart';
import 'simple_content_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final stateInfo = StateLanguageMap.byCode(appState.selectedState ?? '');
    final langName = stateInfo?.languages
        .firstWhere((l) => l.code == appState.selectedLanguage, orElse: () => stateInfo.languages.first)
        .displayName;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (!appState.isAdsRemoved)
            _RemoveAdsBanner(onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const RemoveAdsScreen()))),

          _SectionHeader('Preferences'),
          ListTile(
            leading: const Icon(Icons.map_rounded),
            title: const Text('Change State'),
            subtitle: Text(stateInfo?.displayName ?? 'Not set'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SelectStateScreen(),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('Change Language'),
            subtitle: Text(langName ?? 'Not set'),
            onTap: () {
              if (appState.selectedState == null) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SelectLanguageScreen(stateCode: appState.selectedState!),
              ));
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_rounded),
            title: const Text('Dark Mode'),
            value: appState.isDarkMode,
            onChanged: (v) => appState.setDarkMode(v),
          ),

          _SectionHeader('RTO Resources'),
          ListTile(
            leading: const Icon(Icons.description_rounded),
            title: const Text('Download RTO Forms'),
            subtitle: const Text('Form 1, 4, 5, 6, 8, 20, 21, 22 and more'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SimpleContentScreen(
                title: 'RTO Forms',
                body: 'List and download links for common RTO forms '
                    '(Form 1 - Medical Certificate, Form 4 - Application for LL, '
                    'Form 5 - Certificate by driving school, Form 6 - Application for DL, '
                    'Form 8 - Notice of transfer, Form 20 - Registration application, '
                    'Form 21 - Sale certificate, Form 22 - Roadworthiness certificate). '
                    'Hook this screen up to your hosted PDFs.',
              ),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.route_rounded),
            title: const Text('Driving License Process'),
            subtitle: const Text('Step-by-step LL & DL procedure'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SimpleContentScreen(
                title: 'Driving License Process',
                body: '1. Apply for Learner\'s License (LL) online via Sarathi/state portal.\n'
                    '2. Pass the LL computer-based test (this app helps you prepare!).\n'
                    '3. LL is valid for 6 months; practice driving during this period.\n'
                    '4. After 30 days from LL issue, apply for Permanent Driving License (DL).\n'
                    '5. Attend the RTO driving test slot.\n'
                    '6. On passing, DL is issued/dispatched to your address.',
              ),
            )),
          ),

          _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text('Contact Us'),
            onTap: () => launchUrl(Uri.parse('mailto:${AppConstants.contactEmail}')),
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: const Text('Share App'),
            onTap: () => SharePlus.instance.share(ShareParams(text: AppConstants.shareText)),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => launchUrl(Uri.parse(AppConstants.privacyPolicyUrl)),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_rounded),
            title: const Text('Terms & Conditions'),
            onTap: () => launchUrl(Uri.parse(AppConstants.termsUrl)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Disclaimer'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SimpleContentScreen(
                title: 'Disclaimer',
                body: 'This app is an independent study aid for RTO Learning License exam '
                    'preparation. It is not affiliated with, endorsed by, or connected to any '
                    'State Transport Department, RTO, or the Government of India. Questions are '
                    'for practice purposes only and actual exam content may vary. Always refer '
                    'to official RTO/Sarathi sources for final rules and procedures.',
              ),
            )),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title.toUpperCase(),
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1)),
    );
  }
}

class _RemoveAdsBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveAdsBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFA000), Color(0xFFFF6F00)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.block_rounded, color: Colors.white, size: 30),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Remove Ads Forever — just ₹39',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
