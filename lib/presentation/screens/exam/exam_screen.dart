import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/question_timer_widget.dart';
import '../../../data/repositories/question_repository.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/exam_provider.dart';
import '../remove_ads/remove_ads_screen.dart';
import 'exam_result_screen.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final ExamProvider _examProvider;
  bool _checking = true;

  int? _selected;
  bool _advancing = false;

  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _examProvider = ExamProvider(QuestionRepository());
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCreditsAndStart());
  }

  Future<void> _checkCreditsAndStart() async {
    final appState = context.read<AppStateProvider>();
    if (appState.creditManager.canStartExam()) {
      await appState.consumeExamCredit();
      await _examProvider.startExam(
        stateCode: appState.selectedState ?? 'tamilnadu',
        languageCode: appState.selectedLanguage ?? 'en',
      );
      if (!mounted) return;
      setState(() => _checking = false);
    } else {
      _showAdGate();
    }
  }

  void _showAdGate() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      // PopScope blocks the Android/gesture back button from tearing the
      // sheet down mid-flow (isDismissible:false alone does NOT do this —
      // it only blocks tap-outside-to-close). Without this, back-press
      // during the ad flow was popping the wrong route later on and
      // leaving a stray loading screen behind.
      builder: (_) => PopScope(
        canPop: false,
        child: _RewardedAdGateSheet(
          onCreditEarned: () {
            if (!context.mounted) return;
            Navigator.of(context).pop();
            _checkCreditsAndStart();
          },
          onCancel: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _onSelectOption(int index) {
    if (_advancing) return;
    setState(() => _selected = index);
  }

  void _onTimeout() {
    if (_advancing) return;
    _advancing = true;
    _wrongCount++;
    _goToNext(timedOut: true);
  }

  void _onNext(int correctIndex) {
    if (_advancing || _selected == null) return;
    _advancing = true;
    if (_selected == correctIndex) {
      _correctCount++;
    } else {
      _wrongCount++;
    }
    _goToNext(timedOut: false);
  }

  Future<void> _goToNext({required bool timedOut}) async {
    await _examProvider.submitAnswer(_selected, timedOut: timedOut);
    if (_examProvider.status == ExamStatus.finished) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ExamResultScreen(attempt: _examProvider.lastAttempt!),
      ));
      return;
    }
    if (!mounted) return;
    setState(() {
      _selected = null;
      _advancing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: _examProvider,
      child: Consumer<ExamProvider>(
        builder: (context, exam, _) {
          final q = exam.currentQuestion;
          if (q == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final leave = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Exit Exam?'),
                  content: const Text('Your progress in this attempt will be lost.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Exit')),
                  ],
                ),
              );
              if (leave == true && context.mounted) Navigator.of(context).pop();
            },
            child: Scaffold(
              backgroundColor: colorScheme.surface,
              appBar: AppBar(
                title: const Text('Exam'),
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Row(
                        children: [
                          Text(
                            '${exam.currentQuestionNumber}/${exam.totalQuestions}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                          QuestionTimer(
                            key: ValueKey(exam.currentQuestionNumber),
                            resetKey: ValueKey(exam.currentQuestionNumber),
                            seconds: AppConstants.secondsPerQuestion,
                            onTimeout: _onTimeout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        'Q. ${q.question}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      color: colorScheme.outlineVariant,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(16),
                                        ),
                                      ),
                                      child: Column(
                                        children: List.generate(q.options.length, (i) {
                                          final isLast = i == q.options.length - 1;
                                          return _OptionRow(
                                            number: i + 1,
                                            text: q.options[i],
                                            selected: _selected == i,
                                            showDivider: !isLast,
                                            onTap: () => _onSelectOption(i),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            _ScorePill(icon: Icons.check, color: AppColors.success, count: _correctCount),
                            const SizedBox(width: 8),
                            _ScorePill(icon: Icons.close, color: AppColors.danger, count: _wrongCount),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: _selected != null && !_advancing
                                  ? () => _onNext(q.correctIndex)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: Text(
                                exam.currentQuestionNumber == exam.totalQuestions
                                    ? 'Finish'
                                    : 'Next Question',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final int number;
  final String text;
  final bool selected;
  final bool showDivider;
  final VoidCallback onTap;

  const _OptionRow({
    required this.number,
    required this.text,
    required this.selected,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            color: selected ? colorScheme.primary.withOpacity(0.16) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? colorScheme.primary : colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: colorScheme.outlineVariant),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;

  const _ScorePill({required this.icon, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Ad-gate bottom sheet.
///
/// Two things changed from the old version:
/// 1. Real AdMob rewarded-ad flow (RewardedAd.load / show) instead of a
///    fake 2-second delay. Reward is only granted from onUserEarnedReward.
/// 2. Every intermediate dialog is wrapped in PopScope(canPop: false) so a
///    back-press mid-flow can't leave the sheet or ExamScreen in a stuck
///    "still loading" state.
/// ---------------------------------------------------------------------
class _RewardedAdGateSheet extends StatefulWidget {
  final VoidCallback onCreditEarned;
  final VoidCallback onCancel;

  const _RewardedAdGateSheet({required this.onCreditEarned, required this.onCancel});

  @override
  State<_RewardedAdGateSheet> createState() => _RewardedAdGateSheetState();
}

class _RewardedAdGateSheetState extends State<_RewardedAdGateSheet> {
  bool _loadingAd = false;

  Future<void> _watchAd() async {
    if (_loadingAd) return;
    setState(() => _loadingAd = true);

    bool loadingDialogOpen = true;

    // Non-cancellable loading dialog: back button can't rip it out from
    // under the async ad-load call.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Loading rewarded ad...')),
            ],
          ),
        ),
      ),
    );

    void closeLoadingDialog() {
      if (loadingDialogOpen && mounted) {
        loadingDialogOpen = false;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    RewardedAd.load(
      // Replace with your real AdMob rewarded ad unit ID (put it in
      // AppConstants rather than hardcoding it here).
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          closeLoadingDialog();
          bool rewardEarned = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!mounted) return;
              setState(() => _loadingAd = false);
              if (rewardEarned) {
                widget.onCreditEarned();
              }
              // User backed out of the ad early without earning the
              // reward — the gate sheet just stays open, nothing to fix.
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (!mounted) return;
              setState(() => _loadingAd = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ad failed to show. Please try again.')),
              );
            },
          );

          ad.show(
            onUserEarnedReward: (ad, reward) async {
              rewardEarned = true;
              if (!mounted) return;
              await context.read<AppStateProvider>().addExamCreditFromAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          closeLoadingDialog();
          if (!mounted) return;
          setState(() => _loadingAd = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No ad available right now: ${error.message}')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag-handle bar, purely cosmetic (sheet itself doesn't drag).
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Icon with badge, matching the reference image.
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.success.withOpacity(0.15),
                          Colors.orange.withOpacity(0.12),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.assignment_rounded, size: 44, color: Colors.black87),
                  ),
                  Positioned(
                    right: -2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "You're out of free attempts!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Continue your learning journey.\nChoose your path:',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Primary: unlimited, with "Best Value" badge.
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loadingAd
                        ? null
                        : () async {
                            // Don't pop the sheet before pushing the purchase
                            // screen. Push it on top instead — if the user
                            // just backs out, the sheet is still underneath
                            // and reappears automatically instead of
                            // exposing ExamScreen's loading spinner.
                            // RemoveAdsScreen must call
                            // Navigator.pop(context, true) on a successful
                            // purchase; a plain back-press returns null.
                            final purchased = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => const RemoveAdsScreen()),
                            );
                            if (purchased == true && mounted) {
                              // Closes the sheet and re-checks credits, which
                              // will now see ads/unlimited unlocked.
                              widget.onCreditEarned();
                            }
                            // purchased != true: user backed out without
                            // buying — sheet is already visible again, do
                            // nothing further.
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Go Unlimited Forever — ₹39',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(width: 8),
                        Icon(Icons.lock_open_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Best Value',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Secondary: watch ad.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loadingAd ? null : _watchAd,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loadingAd
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.play_circle_outline, size: 20),
                              SizedBox(width: 8),
                              Text('Watch Ad for +1 Attempt',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '(Ad is less than 30 seconds)',
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _loadingAd ? null : widget.onCancel,
              child: const Text('Not Now'),
            ),
          ],
        ),
      ),
    );
  }
}
