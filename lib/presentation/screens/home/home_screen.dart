import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/state_language_map.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/ad_banner.dart';
import '../../providers/app_state_provider.dart';
import '../question_bank/question_bank_screen.dart';
import '../practice/practice_question_screen.dart';
import '../exam/exam_screen.dart';
import '../result_history/result_history_screen.dart';
import '../settings/settings_screen.dart';
import '../remove_ads/remove_ads_screen.dart';
import '../contribute_school/driving_school_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final stateInfo = StateLanguageMap.byCode(appState.selectedState ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(stateInfo?.displayName ?? 'RTO Exam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!appState.isAdsRemoved) const AdBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prepare for your Learning License Test',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.95,
                      children: [
                        FeatureCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Question Bank',
                          subtitle: 'Browse all topics & signs',
                          color: Colors.indigo,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const QuestionBankScreen())),
                        ),
                        FeatureCard(
                          icon: Icons.fitness_center_rounded,
                          title: 'Practice Mode',
                          subtitle: 'No time limit, learn at ease',
                          color: Colors.teal,
                           onTap: () => Navigator.of(context).push(
                           MaterialPageRoute(builder: (_) => const PracticeQuestionScreen(topic: null)),
                           ),
                        ),
                        FeatureCard(
                          icon: Icons.timer_rounded,
                          title: 'Exam Mode',
                          subtitle: '10 Qs • 30s each • 7/10 to pass',
                          color: Colors.deepOrange,
                          badge: appState.isAdsRemoved ? 'PRO' : '${appState.examCredits} left',
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const ExamScreen())),
                        ),
                        FeatureCard(
                          icon: Icons.bar_chart_rounded,
                          title: 'Result History',
                          subtitle: 'Track your past attempts',
                          color: Colors.purple,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const ResultHistoryScreen())),
                        ),
                        FeatureCard(
                          icon: Icons.add_business_rounded,
                          title: 'Add Driving School',
                          subtitle: 'Contribute school details',
                          color: Colors.brown,
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DrivingSchoolFormScreen())),
                        ),
                        if (!appState.isAdsRemoved)
                          FeatureCard(
                            icon: Icons.block_rounded,
                            title: 'Remove Ads',
                            subtitle: 'One-time ₹39 — no ads forever',
                            color: AppColors.accent,
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const RemoveAdsScreen())),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
