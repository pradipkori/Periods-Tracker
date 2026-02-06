import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withOpacity(0.1),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
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
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 100, color: AppTheme.primary),
          const SizedBox(height: 40),
          Text(
            'Welcome to\nPeriod Tracker',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Track your cycle, predict your period, and understand your body better.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80, color: AppTheme.primary),
          const SizedBox(height: 40),
          Text(
            'What should we call you?',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            onChanged: (value) => setState(() => _userName = value),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primary),
            ),
            style: GoogleFonts.outfit(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPeriodPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 80, color: AppTheme.primary),
          const SizedBox(height: 40),
          Text(
            'When did your last period start?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
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
              );
              if (picked != null) {
                setState(() => _lastPeriodDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    '${_lastPeriodDate.day}/${_lastPeriodDate.month}/${_lastPeriodDate.year}',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 80, color: AppTheme.primary),
          const SizedBox(height: 40),
          Text(
            'Customize your cycle',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _buildSliderSetting(
            'Average Cycle Length',
            _averageCycleLength,
            21,
            35,
            (value) => setState(() => _averageCycleLength = value.toInt()),
          ),
          const SizedBox(height: 24),
          _buildSliderSetting(
            'Average Period Length',
            _averagePeriodLength,
            2,
            10,
            (value) => setState(() => _averagePeriodLength = value.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(String label, int value, int min, int max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                activeColor: AppTheme.primary,
                label: '$value days',
                onChanged: onChanged,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 40),
          Text(
            'All Set!',
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re ready to start tracking your cycle and understanding your body better.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: Text(
                'Back',
                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary),
              ),
            )
          else
            const SizedBox(width: 80),
          Row(
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _currentPage == 4 ? _completeOnboarding : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              _currentPage == 4 ? 'Get Started' : 'Next',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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

  // STEP 1: Delete ALL periods (predicted AND actual) for this month
  final allCycles = await db.getAllCycles();
  final loggedMonth = _lastPeriodDate.month;
  final loggedYear = _lastPeriodDate.year;
  
  for (final cycle in allCycles) {
    // Delete if same month/year (both predicted and actual)
    if (cycle.startDate.month == loggedMonth && 
        cycle.startDate.year == loggedYear) {
      await db.deleteCycle(cycle.id);
      print('🗑️ Deleted ${cycle.isPredicted ? "predicted" : "actual"} period for ${cycle.startDate}');
    }
  }

  // STEP 2: Create initial period log with user's actual dates
  final cycle = CycleLog(
    startDate: _lastPeriodDate,
    endDate: _lastPeriodDate.add(Duration(days: _averagePeriodLength)),
  );
  await db.saveCycle(cycle);

  // STEP 3: Generate predictions for future months
  final predictionService = ref.read(predictionServiceProvider);
  await predictionService.generatePredictions();

  if (mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
}
