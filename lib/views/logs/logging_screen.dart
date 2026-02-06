import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoggingScreen extends ConsumerStatefulWidget {
  const LoggingScreen({super.key});

  @override
  ConsumerState<LoggingScreen> createState() => _LoggingScreenState();
}

class _LoggingScreenState extends ConsumerState<LoggingScreen> {
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedMoods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Log Daily Health", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("How are you feeling?", Icons.mood),
            const SizedBox(height: 16),
            _buildMoodGrid(),
            const SizedBox(height: 32),
            _buildSectionHeader("Any symptoms?", Icons.medical_services_outlined),
            const SizedBox(height: 16),
            _buildSymptomChips(),
            const SizedBox(height: 32),
            _buildSectionHeader("Vital metrics", Icons.monitor_heart_outlined),
            const SizedBox(height: 16),
            _buildMetricsInput(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildMoodGrid() {
    final moods = [
      {'label': 'Happy', 'icon': '😊'},
      {'label': 'Calm', 'icon': '😌'},
      {'label': 'Irritable', 'icon': '😠'},
      {'label': 'Sad', 'icon': '😢'},
      {'label': 'Anxious', 'icon': '😰'},
      {'label': 'Energetic', 'icon': '⚡'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isSelected = _selectedMoods.contains(mood['label']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMoods.remove(mood['label']);
              } else {
                _selectedMoods.add(mood['label']!);
              }
            });
          },
          child: AnimatedContainer(
            duration: 200.ms,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected ? [
                BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
              ] : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mood['icon']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  mood['label']!,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1));
      },
    );
  }

  Widget _buildSymptomChips() {
    final symptoms = ['Cramps', 'Headache', 'Bloating', 'Acne', 'Back Pain', 'Tender Breasts', 'Nausea'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: symptoms.map((s) {
        final isSelected = _selectedSymptoms.contains(s);
        return FilterChip(
          label: Text(s),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedSymptoms.add(s);
              } else {
                _selectedSymptoms.remove(s);
              }
            });
          },
          selectedColor: AppTheme.secondary.withOpacity(0.2),
          checkmarkColor: AppTheme.secondary,
          labelStyle: GoogleFonts.outfit(
            color: isSelected ? AppTheme.secondary : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildMetricsInput() {
    return Column(
      children: [
        _metricTile("Weight", "kg", Icons.monitor_weight_outlined),
        const SizedBox(height: 12),
        _metricTile("Temperature", "°C", Icons.thermostat_outlined),
        const SizedBox(height: 12),
        _metricTile("Water", "ml", Icons.water_drop_outlined),
      ],
    );
  }

  Widget _metricTile(String label, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(color: AppTheme.textPrimary)),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "0.0",
                suffixText: " $unit",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement actual save logic with ref.read(dbServiceProvider)
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          shadowColor: AppTheme.primary.withOpacity(0.4),
        ),
        child: Text("SAVE LOG", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0);
  }
}
