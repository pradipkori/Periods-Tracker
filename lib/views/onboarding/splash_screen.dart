import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/views/home/home_screen.dart';
import 'package:period_tracker/views/onboarding/onboarding_screen.dart';
import 'package:period_tracker/views/auth/password_screen.dart';
import 'package:period_tracker/views/auth/auth_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:period_tracker/services/push_notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.forward();

    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Run splash animation for at least 3s while init runs in parallel
    final animationDelay = Future.delayed(const Duration(seconds: 3));

    // Safe fallback destination
    Widget destination = const OnboardingScreen();

    try {
      // Step 1: Firebase & AlarmManager (mobile only)
      if (!kIsWeb) {
        await Firebase.initializeApp();
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
        await AndroidAlarmManager.initialize();
      }

      // Step 2: Timezone
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (e) {
        debugPrint('Timezone init error: $e');
      }

      // Step 3: Database — init() is safe to call multiple times now
      final dbService = ref.read(dbServiceProvider);
      await dbService.init();

      // Step 4: Cleanup duplicates
      try {
        await dbService.clearAllDuplicates();
      } catch (e) {
        debugPrint('Cleanup error: $e');
      }

      // Step 5: Local notifications
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.init();
      await notificationService.requestPermissions();

      // Step 6: Push notifications (mobile only)
      if (!kIsWeb) {
        await ref.read(pushNotificationServiceProvider).init();
      }

      // Step 7: Read settings — safe because DB is guaranteed initialized
      final settings = await dbService.getSettings();

      final currentSession = Supabase.instance.client.auth.currentSession;
      
      if (currentSession == null) {
        destination = const AuthScreen();
      } else if (!settings.hasCompletedOnboarding) {
        destination = const OnboardingScreen();
      } else if (settings.passcode != null &&
          settings.passcode!.isNotEmpty) {
        destination = const PasswordLockScreen(child: HomeScreen());
      } else {
        destination = const HomeScreen();
      }
    } catch (e) {
      debugPrint('App initialization error: $e');
      // Falls back to OnboardingScreen
    }

    // Always wait for animation before navigating
    await animationDelay;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
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
              AppTheme.primary.withRed(255).withBlue(150),
              AppTheme.primaryLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative floating circle — top right
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: -20,
                  end: 20,
                  duration: 3.seconds,
                  curve: Curves.easeInOut,
                ),

            // Decorative floating circle — bottom left
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: 20,
                  end: -20,
                  duration: 4.seconds,
                  curve: Curves.easeInOut,
                ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D Animated Logo
                  Container(
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 90,
                      color: AppTheme.primary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        curve: Curves.elasticOut,
                        duration: 1200.ms,
                      )
                      .shimmer(delay: 1500.ms, duration: 2.seconds)
                      .then()
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .custom(
                        duration: 4.seconds,
                        builder: (context, value, child) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateY(value * 6.28)
                              ..rotateX(0.2),
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                      ),

                  const SizedBox(height: 48),

                  // App title
                  Text(
                    'Period Tracker',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 800.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Track. Predict. Understand.',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 800.ms)
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 60),

                  // Loading bar
                  const SizedBox(
                    width: 40,
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white24,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1500.ms)
                      .scaleX(begin: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}