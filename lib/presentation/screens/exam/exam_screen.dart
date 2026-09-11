import 'package:flutter/material.dart';
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
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
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
              // Use theme surface, not a hardcoded/mismatched tone —
              // this is what fixes the muddy gray in dark mode.
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
                    // Centered content instead of top-pinned with dead
                    // space below — fills the available area cleanly
                    // and still scrolls if the question is long.
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
                                    // ---- Question card ----
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
                                    // ---- Options card ----
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
                    // ---- Bottom bar: score chips + Next ----
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

class _RewardedAdGateSheet extends StatelessWidget {
  final VoidCallback onCreditEarned;
  final VoidCallback onCancel;

  const _RewardedAdGateSheet({required this.onCreditEarned, required this.onCancel});

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
    Navigator.of(context).pop();
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
            Text(
              "You've used your free exam attempt. Watch a short ad to get 1 more attempt.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
