import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'data/local/hive_boxes.dart';
import 'presentation/providers/app_state_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveBoxes.init();
  final prefs = await SharedPreferences.getInstance();

  // Safe to call even if ads aren't shown yet (e.g. user already removed ads).
  // unawaited(MobileAds.instance.initialize());
  await MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppStateProvider(prefs),
      child: const RtoExamApp(),
    ),
  );
}
