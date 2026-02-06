import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/views/calendar/calendar_screen.dart';
import 'package:period_tracker/views/logs/logging_screen.dart';
import 'package:period_tracker/views/logs/period_logging_screen.dart';
import 'package:period_tracker/views/insights/insights_screen.dart';
import 'package:period_tracker/views/profile/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final currentPhaseAsync = ref.watch(currentPhaseProvider);
    final currentCycleDayAsync = ref.watch(currentCycleDayProvider);
    final daysUntilPeriodAsync = ref.watch(daysUntilPeriodProvider);
    final phaseInsightAsync = ref.watch(phaseInsightProvider);
    final homeStatusAsync = ref.watch(homeStatusProvider);

    final phase = currentPhaseAsync.value?.toLowerCase() ?? "";
    
    // Dynamic Color Palette based on Phase
    Color phaseColor = AppTheme.primary;
    if (phase.contains('fertile') || phase.contains('ovulation')) {
      phaseColor = AppTheme.cycleOvulation;
    } else if (phase.contains('menstrual') || phase.contains('period')) {
      phaseColor = AppTheme.cyclePeriod;
    } else if (phase.contains('follicular')) {
      phaseColor = AppTheme.cycleFollicular;
    } else if (phase.contains('luteal')) {
      phaseColor = AppTheme.cycleLuteal;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Dynamic Background Gradient
          AnimatedContainer(
            duration: 800.ms,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  phaseColor.withOpacity(0.15),
                  AppTheme.background,
                  phaseColor.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(settingsAsync)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  sliver: SliverToBoxAdapter(
                    child: _buildModernFlowCircle(homeStatusAsync, currentPhaseAsync, phaseColor),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildGlassStats(daysUntilPeriodAsync, currentCycleDayAsync, phaseColor),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildActionGrid(context, phaseColor),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildModernInsightCard(phaseInsightAsync, phaseColor),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(context),
    );
  }

  Widget _buildHeader(AsyncValue<UserSettings> settingsAsync) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              settingsAsync.when(
                data: (s) => Text("Welcome back,", style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14)),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              settingsAsync.when(
                data: (s) => Text(s.userName, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          _GlassButton(
            icon: Icons.notifications_none_rounded,
            onPressed: () {},
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1);
  }

  Widget _buildModernFlowCircle(AsyncValue<String> homeStatus, AsyncValue<String> phaseAsync, Color phaseColor) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple layers
          ...List.generate(3, (index) => 
            Container(
              width: 240 + (index * 40.0),
              height: 240 + (index * 40.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: phaseColor.withOpacity(0.05 * (3 - index)), width: 1.5),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: Offset(1 + (index * 0.02), 1 + (index * 0.02)), duration: (1500 + (index * 500)).ms)
          ),

          // Main Glowing Circle
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: phaseColor.withOpacity(0.4), blurRadius: 40, spreadRadius: -10, offset: const Offset(0, 15)),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [phaseColor, phaseColor.withBlue(220)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                homeStatus.when(
                  data: (status) => Text(
                    status,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
                  ),
                  loading: () => const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  error: (_, __) => const Icon(Icons.error_outline, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    phaseAsync.value ?? "...",
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildGlassStats(AsyncValue<int?> daysUntil, AsyncValue<int?> cycleDay, Color phaseColor) {
    return Row(
      children: [
        Expanded(child: _GlassStatTile(
          label: "Period In",
          value: daysUntil.when(data: (d) => d != null ? "$d Days" : "...", loading: () => "...", error: (_, __) => "--"),
          icon: Icons.water_drop_rounded,
          color: phaseColor,
        )),
        const SizedBox(width: 20),
        Expanded(child: _GlassStatTile(
          label: "Cycle Day",
          value: cycleDay.when(data: (d) => d != null ? "Day $d" : "--", loading: () => "...", error: (_, __) => "--"),
          icon: Icons.loop_rounded,
          color: AppTheme.secondary,
        )),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildActionGrid(BuildContext context, Color phaseColor) {
    return Row(
      children: [
        Expanded(
          child: _ModernActionButton(
            label: "LOG PERIOD",
            icon: Icons.add_circle_outline_rounded,
            color: phaseColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PeriodLoggingScreen())),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ModernActionButton(
            label: "SYMPTOMS",
            icon: Icons.auto_awesome_rounded,
            color: AppTheme.textPrimary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoggingScreen())),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildModernInsightCard(AsyncValue<String> insightAsync, Color phaseColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: phaseColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Decorative background element
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.spa_rounded,
                size: 120,
                color: phaseColor.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: phaseColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.auto_awesome_rounded, color: phaseColor, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "Daily Insight",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  insightAsync.when(
                    data: (text) => Text(
                      text,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: AppTheme.textSecondary.withOpacity(0.8),
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                    loading: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(6))),
                        const SizedBox(height: 8),
                        Container(width: 200, height: 12, decoration: BoxDecoration(color: Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(6))),
                      ],
                    ),
                    error: (_, __) => const Text("Take a moment for yourself today. You're doing great!"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildModernBottomNav(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      decoration: BoxDecoration(
        color: AppTheme.textPrimary,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: AppTheme.textPrimary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ModernNavItem(icon: Icons.home_filled, label: "Home", isActive: true),
          _ModernNavItem(icon: Icons.calendar_month_rounded, label: "Calendar", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()))),
          _ModernNavItem(icon: Icons.insights_rounded, label: "Stats", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen()))),
          _ModernNavItem(icon: Icons.person_rounded, label: "Profile", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 800.ms, curve: Curves.easeOut);
  }
}

class _GlassStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _GlassStatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color == AppTheme.textPrimary ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: color == AppTheme.textPrimary ? null : Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            if (color != AppTheme.textPrimary) 
              BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color == AppTheme.textPrimary ? Colors.white : color, size: 20),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color == AppTheme.textPrimary ? Colors.white : color)),
          ],
        ),
      ),
    );
  }
}

class _ModernNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _ModernNavItem({required this.icon, required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive ? BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.6), size: 26),
            if (isActive) ...[
              const SizedBox(height: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
            ]
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 24),
      ),
    );
  }
}
