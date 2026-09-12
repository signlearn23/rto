import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import '../driving_school/driving_school_list_screen.dart';
import '../../../core/widgets/language_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RewardedAd? _rewardedAd;
  bool _loadingReward = false;

  @override
  void initState() {
    super.initState();
    _preloadRewardedAd();
  }

  void _preloadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // TODO: real rewarded ad unit id
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  Future<void> _watchAdForExamCredit(AppStateProvider appState) async {
    if (_loadingReward) return;

    if (_rewardedAd == null) {
      setState(() => _loadingReward = true);
      // Give one short retry if the ad wasn't ready yet.
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _loadingReward = false);
      if (_rewardedAd == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad not ready yet, try again in a moment')),
          );
        }
        _preloadRewardedAd();
        return;
      }
    }

    final ad = _rewardedAd!;
    _rewardedAd = null; // consumed; a fresh one loads in fullScreenContentCallback

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _preloadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        appState.addExamCredit();
      },
    );
  }

  // showLanguagePicker() is a function that shows its own bottom sheet and
  // returns the chosen language code (or null if dismissed) â€” it isn't a
  // widget, so it's called directly rather than wrapped in showDialog().
  Future<void> _openLanguagePicker(AppStateProvider appState) async {
    final code = await showLanguagePicker(
      context,
      currentLanguageCode: appState.selectedLanguage,
    );
    if (code != null) {
      await appState.setLanguage(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final stateInfo = StateLanguageMap.byCode(appState.selectedState ?? '');

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(stateInfo?.displayName ?? 'RTO Exam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: 'Change language',
            onPressed: () => _openLanguagePicker(appState),
          ),
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
                          subtitle: '10 Qs â€¢ 30s each â€¢ 7/10 to pass',
                          color: Colors.deepOrange,
                          badge: appState.isAdsRemoved
                              ? 'PRO'
                              : (appState.examCredits > 0 ? '${appState.examCredits} left' : 'Watch Ad'),
                          badgeIcon: (!appState.isAdsRemoved && appState.examCredits == 0)
                              ? Icons.play_circle_fill_rounded
                              : null,
                          onTap: () {
                            final canEnter = appState.isAdsRemoved || appState.examCredits > 0;
                            if (canEnter) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => const ExamScreen()));
                            } else {
                              _watchAdForExamCredit(appState);
                            }
                          },
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
                          icon: Icons.school_rounded,
                          title: 'Driving Schools',
                          subtitle: 'Find schools near you',
                          color: Colors.brown,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const DrivingSchoolListScreen())),
                        ),
                        if (!appState.isAdsRemoved)
                          FeatureCard(
                            icon: Icons.block_rounded,
                            title: 'Remove Ads',
                            subtitle: 'One-time â‚¹39 â€” no ads forever',
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
            if (!appState.isAdsRemoved) const AdBanner(),
          ],
        ),
      ),
    );
  }
}
