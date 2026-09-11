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
  bool _answered = false;
  bool _timedOut = false;

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

  /// Called the moment the user taps an option. Just reveals right/wrong —
  /// does NOT submit or advance yet.
  void _onSelectOption(int index, int correctIndex) {
    if (_answered) return;
    setState(() {
      _selected = index;
      _answered = true;
      if (index == correctIndex) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });
  }

  /// Called when the timer runs out with nothing selected.
  void _onTimeout(int correctIndex) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _timedOut = true;
      _wrongCount++;
    });
  }

  /// Called when the user taps "Next".
  Future<void> _goToNext() async {
    await _examProvider.submitAnswer(_selected, timedOut: _timedOut);
    if (_examProvider.status == ExamStatus.finished) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ExamResultScreen(attempt: _examProvider.lastAttempt!),
      ));
      return;
    }
    setState(() {
      _selected = null;
      _answered = false;
      _timedOut = false;
    });
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
                actions: [
                  _ScoreChip(icon: Icons.check_circle, color: Colors.green, count: _correctCount),
                  const SizedBox(width: 8),
                  _ScoreChip(icon: Icons.cancel, color: Colors.red, count: _wrongCount),
                  const SizedBox(width: 12),
                ],
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: exam.currentQuestionNumber / exam.totalQuestions,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (!_answered)
                          QuestionTimer(
                            key: ValueKey(exam.currentQuestionNumber),
                            resetKey: ValueKey(exam.currentQuestionNumber),
                            seconds: AppConstants.secondsPerQuestion,
                            onTimeout: () => _onTimeout(q.correctIndex),
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _OptionTile(
                              text: q.options[i],
                              state: _optionState(i, q.correctIndex),
                              onTap: _answered ? null : () => _onSelectOption(i, q.correctIndex),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_timedOut)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          "Time's up! The correct answer is highlighted above.",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _answered ? _goToNext : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          exam.currentQuestionNumber == exam.totalQuestions ? 'Finish' : 'Next',
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

  _OptionVisualState _optionState(int index, int correctIndex) {
    if (!_answered) {
      return _selected == index ? _OptionVisualState.selected : _OptionVisualState.idle;
    }
    if (index == correctIndex) return _OptionVisualState.correct;
    if (index == _selected) return _OptionVisualState.wrong;
    return _OptionVisualState.dimmed;
  }
}

enum _OptionVisualState { idle, selected, correct, wrong, dimmed }

class _OptionTile extends StatelessWidget {
  final String text;
  final _OptionVisualState state;
  final VoidCallback? onTap;

  const _OptionTile({required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Color borderColor = Colors.grey.shade300;
    Color? fillColor;
    Color textColor = Colors.black87;
    Widget? trailingIcon;

    switch (state) {
      case _OptionVisualState.idle:
        break;
      case _OptionVisualState.selected:
        borderColor = primary;
        fillColor = primary.withOpacity(0.12);
        break;
      case _OptionVisualState.correct:
        borderColor = Colors.green;
        fillColor = Colors.green.withOpacity(0.12);
        textColor = Colors.green.shade800;
        trailingIcon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
        break;
      case _OptionVisualState.wrong:
        borderColor = Colors.red;
        fillColor = Colors.red.withOpacity(0.10);
        textColor = Colors.red.shade800;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 20);
        break;
      case _OptionVisualState.dimmed:
        textColor = Colors.grey.shade500;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: state == _OptionVisualState.idle ? 1 : 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: TextStyle(color: textColor))),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;

  const _ScoreChip({required this.icon, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
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
