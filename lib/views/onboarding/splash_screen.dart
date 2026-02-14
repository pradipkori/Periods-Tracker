import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/views/home/home_screen.dart';
import 'package:period_tracker/views/onboarding/onboarding_screen.dart';
import 'package:period_tracker/views/auth/password_screen.dart';

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
    await Future.delayed(const Duration(seconds: 3));
    
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
              AppTheme.primary.withRed(255).withBlue(150), // More vibrant pink
              AppTheme.primaryLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative floating circles
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(begin: -20, end: 20, duration: 3.seconds, curve: Curves.easeInOut),
            
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(begin: 20, end: -20, duration: 4.seconds, curve: Curves.easeInOut),

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
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
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
                  .scale(begin: const Offset(0.3, 0.3), curve: Curves.elasticOut, duration: 1200.ms)
                  .shimmer(delay: 1500.ms, duration: 2.seconds)
                  .then()
                  .animate(onPlay: (controller) => controller.repeat())
                  .custom(
                    duration: 4.seconds,
                    builder: (context, value, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002) // perspective
                          ..rotateY(value * 6.28) // full rotation
                          ..rotateX(0.2),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Title with stagger animation
                  Text(
                    'Period Tracker',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  Text(
                    'Track. Predict. Understand.',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 800.ms)
                  .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  const SizedBox(
                    width: 40,
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
