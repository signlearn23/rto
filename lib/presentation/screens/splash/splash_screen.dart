import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../onboarding/onboarding_selection_screen.dart';
import '../home/home_screen.dart';

/// Splash screen with a Lottie vehicle animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final appState = context.read<AppStateProvider>();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => appState.onboardingDone ? const HomeScreen() : const OnboardingSelectionScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 180,
              width: width * 0.8,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 0.35,
                  child: Lottie.asset(
                    'assets/animations/vehicle.json',
                    fit: BoxFit.fitWidth,
                    repeat: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'RTO Expert',
              style: TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            const Text(
              'Learn. Practice. Pass.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
