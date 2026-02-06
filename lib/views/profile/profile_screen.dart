import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/views/profile/reminders_screen.dart';
import 'package:period_tracker/views/auth/password_screen.dart';
import 'package:period_tracker/views/pregnancy/pregnancy_mode_screen.dart';
import 'package:period_tracker/views/onboarding/onboarding_screen.dart';
import 'package:period_tracker/views/analytics/advanced_analytics_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final phaseAsync = ref.watch(currentPhaseProvider);

    final phaseColor = phaseAsync.when(
      data: (phase) {
        switch (phase) {
          case 'Period': return AppTheme.cyclePeriod;
          case 'Fertile': return AppTheme.cycleOvulation;
          case 'Ovulation': return AppTheme.cycleFollicular;
          default: return AppTheme.primary;
        }
      },
      loading: () => AppTheme.primary,
      error: (_, __) => AppTheme.primary,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Profile & Settings", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Dynamic Background
          AnimatedContainer(
            duration: 600.ms,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  phaseColor.withOpacity(0.12),
                  AppTheme.background,
                  phaseColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: settingsAsync.when(
              data: (settings) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Profile Header
                    _buildModernHeader(settings, phaseColor),
                    const SizedBox(height: 24),

                    // Cycle Settings
                    _buildModernSection(
                      "Cycle Settings",
                      Icons.loop_rounded,
                      [
                        _buildModernSettingItem("Average Cycle Length", "${settings.averageCycleLength} days"),
                        _buildModernSettingItem("Average Period Length", "${settings.averagePeriodLength} days"),
                        _buildModernSettingItem("Luteal Phase Length", "${settings.lutealPhaseLength} days"),
                      ],
                      0,
                    ),
                    const SizedBox(height: 16),

                    // Notifications
                    _buildModernSection(
                      "Notifications",
                      Icons.notifications_active_rounded,
                      [
                        _buildModernSettingItem("Status", settings.notificationsEnabled ? "Enabled" : "Disabled"),
                        _buildModernSettingItem("Period Alerts", settings.periodReminderEnabled ? "On" : "Off"),
                        _buildModernSettingItem("Ovulation Alerts", settings.ovulationReminderEnabled ? "On" : "Off"),
                      ],
                      1,
                    ),
                    const SizedBox(height: 16),

                    // Features
                    _buildModernSection(
                      "Features",
                      Icons.auto_awesome_rounded,
                      [
                        _buildModernActionItem(context, "Advanced Analytics", Icons.analytics_rounded, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedAnalyticsScreen()));
                        }),
                        _buildModernActionItem(context, "Reminders", Icons.alarm_rounded, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()));
                        }),
                        _buildModernActionItem(context, "Pregnancy Mode", Icons.pregnant_woman_rounded, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PregnancyModeScreen()));
                        }),
                        _buildModernActionItem(context, "Set Password", Icons.lock_person_rounded, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordSetupScreen()));
                        }),
                      ],
                      2,
                    ),
                    const SizedBox(height: 16),

                    // Data Management
                    _buildModernSection(
                      "Data",
                      Icons.storage_rounded,
                      [
                        _buildModernActionItem(context, "Export to PDF", Icons.picture_as_pdf_rounded, () {
                          _exportData(context, ref, 'pdf');
                        }),
                        _buildModernActionItem(context, "Backup Data", Icons.cloud_upload_rounded, () {
                          _exportData(context, ref, 'json');
                        }),
                      ],
                      3,
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    _buildModernLogoutButton(context, ref),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text("Error loading settings")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(settings, Color phaseColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [phaseColor, phaseColor.withOpacity(0.7)]),
                  boxShadow: [
                    BoxShadow(color: phaseColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
              ),
              Text(
                settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : "U",
                style: GoogleFonts.outfit(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            settings.userName,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          Text(
            "Account Settings",
            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildModernSection(String title, IconData icon, List<Widget> items, int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white),
          ...items,
        ],
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(begin: 0.1);
  }

  Widget _buildModernSettingItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionItem(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return AnimatedButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLogoutButton(BuildContext context, WidgetRef ref) {
    return AnimatedButton(
      onTap: () => _logout(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_settings_new_rounded, color: Colors.red, size: 22),
            const SizedBox(width: 12),
            Text(
              "SIGN OUT",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref, String type) async {
    final exportService = ref.read(exportServiceProvider);

    try {
      if (type == 'pdf') {
        await exportService.sharePdfReport();
      } else {
        await exportService.shareJsonBackup();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.toUpperCase()} exported successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Logout", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to logout? This will clear your session.", style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text("Logout", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }
}

// Keep the existing AnimatedButton logic
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
