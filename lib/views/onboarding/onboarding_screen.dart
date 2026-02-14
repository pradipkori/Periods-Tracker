import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/utils/date_utils.dart' as app_date_utils;
import 'package:period_tracker/views/home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User data
  String _userName = '';
  DateTime _lastPeriodDate = DateTime.now();
  int _averageCycleLength = 28;
  int _averagePeriodLength = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Parallax Background
          _buildAnimatedBackground(),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildWelcomePage(),
                      _buildNamePage(),
                      _buildLastPeriodPage(),
                      _buildCycleSettingsPage(),
                      _buildCompletePage(),
                    ],
                  ),
                ),
                _buildBottomNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withOpacity(0.15),
                AppTheme.background,
                AppTheme.secondary.withOpacity(0.05),
              ],
            ),
          ),
        ),
        
        // Floating 3D Orbs with parallax
        Positioned(
          top: -100 + (_currentPage * -30),
          right: -50 + (_currentPage * 20),
          child: _buildOrb(300, AppTheme.primary.withOpacity(0.1)),
        ).animate().moveY(begin: -10, end: 10, duration: 4.seconds, curve: Curves.easeInOut).then().animate(onPlay: (c) => c.repeat(reverse: true)),
        
        Positioned(
          bottom: -50 + (_currentPage * 40),
          left: -80 + (_currentPage * -15),
          child: _buildOrb(250, AppTheme.secondary.withOpacity(0.08)),
        ).animate().moveY(begin: 15, end: -15, duration: 5.seconds, curve: Curves.easeInOut).then().animate(onPlay: (c) => c.repeat(reverse: true)),
        
        Positioned(
          top: 200 + (_currentPage * 50),
          left: -100 + (_currentPage * 30),
          child: _buildOrb(180, Colors.pink.withOpacity(0.05)),
        ).animate().moveX(begin: -20, end: 20, duration: 6.seconds, curve: Curves.easeInOut).then().animate(onPlay: (c) => c.repeat(reverse: true)),
      ],
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: padding ?? const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: const Icon(Icons.favorite, size: 80, color: AppTheme.primary),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut).shimmer(delay: 1.seconds),
          const SizedBox(height: 40),
          Text(
            'Discover Your\nRhythm',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          Text(
            'Track. Predict. Understand.\nYour body, simplified.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSecondary.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hello! What\'s\nyour name?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ).animate().fadeIn().slideY(begin: -0.2, end: 0),
          const SizedBox(height: 32),
          TextField(
            onChanged: (value) => setState(() => _userName = value),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: GoogleFonts.outfit(color: AppTheme.textSecondary.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primary),
            ),
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }

  Widget _buildLastPeriodPage() {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'When was your\nlast period?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _lastPeriodDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: AppTheme.primary),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _lastPeriodDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    app_date_utils.DateUtils.formatDate(_lastPeriodDate),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 16),
          Text(
            'We use this to start your predictions',
            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleSettingsPage() {
    return _buildGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Refine your\nCycle',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          _buildSliderSetting(
            'Cycle Length',
            _averageCycleLength,
            21,
            35,
            (value) => setState(() => _averageCycleLength = value.toInt()),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildSliderSetting(
            'Period Duration',
            _averagePeriodLength,
            2,
            10,
            (value) => setState(() => _averagePeriodLength = value.toInt()),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(String label, int value, int min, int max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$value Days',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primary,
            inactiveTrackColor: AppTheme.primary.withOpacity(0.1),
            thumbColor: Colors.white,
            overlayColor: AppTheme.primary.withOpacity(0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletePage() {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded, size: 80, color: Colors.green.shade600),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
          const SizedBox(height: 32),
          Text(
            'Everything is\nReady!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          Text(
            'Your personalized cycle guide is prepared and waiting for you.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button / Placeholder
          SizedBox(
            width: 80,
            child: _currentPage > 0 
              ? TextButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                )
              : null,
          ),
          
          // Indicators
          Row(
            children: List.generate(
              5,
              (index) => AnimatedContainer(
                duration: 300.ms,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppTheme.primary : AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          // Next Button
          ElevatedButton(
            onPressed: _currentPage == 4 ? _completeOnboarding : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppTheme.primary.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              _currentPage == 4 ? 'Let\'s Go' : 'Next',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
    );
  }

  Future<void> _completeOnboarding() async {
    final db = ref.read(dbServiceProvider);
    final settings = await db.getSettings();

    settings.userName = _userName.isNotEmpty ? _userName : 'User';
    settings.lastPeriodDate = _lastPeriodDate;
    settings.averageCycleLength = _averageCycleLength;
    settings.averagePeriodLength = _averagePeriodLength;
    settings.hasCompletedOnboarding = true;

    await db.saveSettings(settings);

    // Initial period log
    final cycle = CycleLog(
      startDate: _lastPeriodDate,
      endDate: _lastPeriodDate.add(Duration(days: _averagePeriodLength)),
    );
    await db.saveCycle(cycle);

    // Generate predictions
    final predictionService = ref.read(predictionServiceProvider);
    await predictionService.generatePredictions();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}
