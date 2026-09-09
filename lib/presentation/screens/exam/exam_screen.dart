import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      builder: (_) => _RewardedAdGateSheet(
        onCreditEarned: () {
          Navigator.of(context).pop();
          _checkCreditsAndStart();
        },
        onCancel: () {
          Navigator.of(context).pop(); // close sheet
          Navigator.of(context).pop(); // leave exam screen
        },
      ),
    );
  }

  void _onAnswer(int? index, {bool timedOut = false}) async {
    setState(() => _selected = index);
    await Future.delayed(const Duration(milliseconds: 250));
    await _examProvider.submitAnswer(index, timedOut: timedOut);
    if (_examProvider.status == ExamStatus.finished) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ExamResultScreen(attempt: _examProvider.lastAttempt!),
      ));
      return;
    }
    setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
              appBar: AppBar(
                title: Text('Question ${exam.currentQuestionNumber}/${exam.totalQuestions}'),
                automaticallyImplyLeading: false,
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: exam.currentQuestionNumber / exam.totalQuestions,
                          ),
                        ),
                        const SizedBox(width: 16),
                        QuestionTimer(
                          key: ValueKey(exam.currentQuestionNumber),
                          resetKey: ValueKey(exam.currentQuestionNumber),
                          seconds: AppConstants.secondsPerQuestion,
                          onTimeout: () {
                            if (_selected == null) _onAnswer(null, timedOut: true);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: q.options.length,
                        itemBuilder: (context, i) {
                          final isSelected = _selected == i;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: _selected == null ? () => _onAnswer(i) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                                      : null,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(q.options[i]),
                              ),
                            ),
                          );
                        },
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

/// Shown when the user has no exam attempts left. They watch a rewarded ad
/// to earn +1 credit, or buy Remove Ads for unlimited attempts.
class _RewardedAdGateSheet extends StatelessWidget {
  final VoidCallback onCreditEarned;
  final VoidCallback onCancel;

  const _RewardedAdGateSheet({required this.onCreditEarned, required this.onCancel});

  /// TODO: replace with a real RewardedAd.load(...).show(...) call using
  /// google_mobile_ads and AppConstants.rewardedAdUnitId. This stub simulates
  /// the reward being earned after a short delay so the flow is testable.
  Future<void> _watchAd(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Loading rewarded ad...')),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;
    Navigator.of(context).pop(); // close loading dialog
    await context.read<AppStateProvider>().addExamCreditFromAd();
    onCreditEarned();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_off_rounded, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('No Exam Attempts Left',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "You've used your free exam attempt. Watch a short ad to get 1 more attempt.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _watchAd(context),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch Ad for +1 Attempt'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RemoveAdsScreen()));
                },
                child: const Text('Remove Ads Forever — ₹39 (Unlimited Exams)'),
              ),
            ),
            TextButton(onPressed: onCancel, child: const Text('Not Now')),
          ],
        ),
      ),
    );
  }
}
