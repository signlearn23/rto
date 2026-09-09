import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../onboarding/select_state_screen.dart';
import '../home/home_screen.dart';

/// Splash with a simple vehicle animation built from Flutter widgets
/// (no external asset dependency). Swap the AnimatedVehicle widget for a
/// Lottie animation (assets/animations/vehicle.json) if you want richer motion -
/// just add the `lottie` package and replace the child below.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _carPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..forward();
    _carPosition = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final appState = context.read<AppStateProvider>();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => appState.onboardingDone ? const HomeScreen() : const SelectStateScreen(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              height: 100,
              width: width * 0.7,
              child: AnimatedBuilder(
                animation: _carPosition,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: width * 0.7,
                          height: 3,
                          color: Colors.white24,
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: (width * 0.7 - 60) * _carPosition.value,
                        child: const Icon(Icons.directions_car_filled,
                            size: 56, color: Colors.white),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'RTO Exam',
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
