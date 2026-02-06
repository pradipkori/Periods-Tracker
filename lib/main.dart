import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/views/home/home_screen.dart';
import 'package:period_tracker/views/onboarding/onboarding_screen.dart';
import 'package:period_tracker/views/auth/password_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AlarmManager
  await AndroidAlarmManager.initialize();
  
  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set to Indian timezone
  
  final container = ProviderContainer();
  final dbService = container.read(dbServiceProvider);
  await dbService.init();

  // CLEANUP: Remove any existing duplicate or overlapping cycles
  print('🧹 Performing startup data cleanup...');
  await dbService.clearAllDuplicates();

  // Initialize notification service
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PeriodTrackerApp(),
    ),
  );
}

class PeriodTrackerApp extends ConsumerWidget {
  const PeriodTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Period Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final settings = await ref.read(dbServiceProvider).getSettings();

    Widget destination;

    // Check if onboarding is completed
    if (!settings.hasCompletedOnboarding) {
      destination = const OnboardingScreen();
    } 
    // Check if password is set
    else if (settings.passcode != null && settings.passcode!.isNotEmpty) {
      destination = const PasswordLockScreen(child: HomeScreen());
    } 
    // Go to home
    else {
      destination = const HomeScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primaryLight,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 80,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Period Tracker',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track. Predict. Understand.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
