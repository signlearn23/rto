import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/language_picker.dart';
import '../onboarding/onboarding_selection_screen.dart';
import '../remove_ads/remove_ads_screen.dart';
import 'simple_content_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    final langName = kAppLanguages
        .firstWhere(
          (l) => l.code == appState.selectedLanguage,
          orElse: () => kAppLanguages.first,
        )
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
            subtitle: Text(appState.selectedState ?? 'Not set'),
            onTap: () async {
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => StatePickerScreen(currentStateCode: appState.selectedState),
                ),
              );
              if (result != null) {
                appState.setState(result);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('Change Language'),
            subtitle: Text(langName),
            onTap: () async {
              final result = await showLanguagePicker(
                context,
                currentLanguageCode: appState.selectedLanguage,
              );
              if (result != null) {
                appState.setLanguage(result);
              }
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
            onTap: () => Share.share(AppConstants.shareText),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SimpleContentScreen(
                title: 'Privacy Policy',
                body: kPrivacyPolicyBody,
              ),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_rounded),
            title: const Text('Terms & Conditions'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SimpleContentScreen(
                title: 'Terms & Conditions',
                body: kTermsAndConditionsBody,
              ),
            )),
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

/// NOTE: Placeholder legal text — not drafted or reviewed by a lawyer.
/// Replace with content reviewed for your actual data practices
/// (e.g. ad SDKs, analytics, purchase data) before publishing.
const String kPrivacyPolicyBody = '''
Last updated: [add date]

This app ("RTO Exam") respects your privacy. This policy explains what
information the app may collect and how it is used.

1. Information We Collect
This app is designed to work primarily offline. It does not require you
to create an account or provide personal details such as your name,
email, or phone number to use the core question-practice features.

If the app uses third-party services (for example, advertising or
analytics SDKs, or a payment provider for the "Remove Ads" purchase),
those services may collect limited technical data such as device
identifiers, app usage statistics, or purchase confirmation details, in
accordance with their own privacy policies.

2. How Information Is Used
Any data collected (directly or via third-party SDKs) is used only to:
- Operate and improve the app's features
- Process the optional "Remove Ads" purchase
- Show relevant ads, if applicable

3. Data Sharing
We do not sell your personal information. Third-party services
integrated into this app (such as ad networks or app store billing)
may process data under their own privacy policies.

4. Children's Privacy
This app is intended for general audiences preparing for a driving
license exam and is not directed at children under 13.

5. Your Choices
You can disable ads by purchasing the "Remove Ads" option, where
available on your platform.

6. Contact
Questions about this policy can be sent to: [add support email]

[Replace this placeholder text with your own reviewed privacy policy
before publishing the app, especially the data-collection section for
whichever ad/analytics/billing SDKs you actually use.]
''';

const String kTermsAndConditionsBody = '''
Last updated: [add date]

By using this app ("RTO Exam"), you agree to the following terms.

1. Purpose of the App
This app provides practice questions and study material to help users
prepare for the RTO (Regional Transport Office) Learning License exam
in India. It is an independent study tool.

2. Not an Official Government Product
This app is not affiliated with, endorsed by, or connected to any
State Transport Department, RTO, Sarathi portal, or the Government of
India. Practice questions may not reflect the exact content, format,
or difficulty of the official exam.

3. No Guarantee of Exam Results
While we aim to keep content accurate and up to date, we do not
guarantee that using this app will result in passing the official RTO
exam. Always verify current rules via official government sources.

4. In-App Purchases
The "Remove Ads" purchase, where offered, is a one-time payment
processed through your device's app store. Refunds are subject to the
relevant app store's policies.

5. Limitation of Liability
The app is provided "as is" without warranties of any kind. We are not
liable for any loss or damage arising from reliance on the app's
content, including exam outcomes.

6. Changes to These Terms
We may update these terms from time to time. Continued use of the app
after changes constitutes acceptance of the updated terms.

7. Contact
Questions about these terms can be sent to: [add support email]

[Replace this placeholder text with terms reviewed for your
jurisdiction and actual business/purchase setup before publishing.]
''';

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
