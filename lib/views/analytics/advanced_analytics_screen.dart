import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/utils/date_utils.dart' as app_date_utils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:period_tracker/utils/constants.dart';

class AdvancedAnalyticsScreen extends ConsumerWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(cycleStatsProvider);
    final cycleTrendAsync = ref.watch(cycleLengthTrendProvider);
    final periodTrendAsync = ref.watch(periodLengthTrendProvider);
    final symptomFreqAsync = ref.watch(symptomFrequencyProvider);
    final moodFreqAsync = ref.watch(moodFrequencyProvider);
    final healthScoreAsync = ref.watch(healthScoreProvider);
    final moodPhaseAsync = ref.watch(moodPhaseCorrelationProvider);
    final symptomsByPhaseAsync = ref.watch(symptomsByPhaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Advanced Analytics", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Score Card
            healthScoreAsync.when(
              data: (score) => _buildHealthScoreCard(score),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Phase Analysis (New Section)
            Text(
              "Phase Insights",
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            symptomsByPhaseAsync.when(
              data: (data) => moodPhaseAsync.when(
                data: (moodData) => _buildPhaseAnalysis(data, moodData),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Cycle Overview
            Text(
              "Cycle Overview",
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => _buildCycleOverview(stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Cycle Length Trend
            Text(
              "Cycle Length Trend",
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            cycleTrendAsync.when(
              data: (trend) => trend.isNotEmpty ? _buildCycleTrendChart(trend) : _buildNoDataCard("Not enough cycle data"),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Period Length Trend
            Text(
              "Period Length Trend",
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            periodTrendAsync.when(
              data: (trend) => trend.isNotEmpty ? _buildPeriodTrendChart(trend) : _buildNoDataCard("Not enough period data"),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Symptom Analysis
            Text(
              "Top Symptoms",
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            symptomFreqAsync.when(
              data: (symptoms) => symptoms.isNotEmpty ? _buildSymptomChart(symptoms) : _buildNoDataCard("No symptom data"),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Mood Analysis
            Text(
              "Mood Distribution",
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            moodFreqAsync.when(
              data: (moods) => moods.isNotEmpty ? _buildMoodPieChart(moods) : _buildNoDataCard("No mood data"),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(int score) {
    Color scoreColor;
    String scoreLabel;
    IconData scoreIcon;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreLabel = "Excellent";
      scoreIcon = Icons.sentiment_very_satisfied;
    } else if (score >= 60) {
      scoreColor = Colors.blue;
      scoreLabel = "Good";
      scoreIcon = Icons.sentiment_satisfied;
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreLabel = "Fair";
      scoreIcon = Icons.sentiment_neutral;
    } else {
      scoreColor = Colors.red;
      scoreLabel = "Needs Improvement";
      scoreIcon = Icons.sentiment_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withOpacity(0.8), scoreColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health Score",
                  style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  "$score",
                  style: GoogleFonts.outfit(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  scoreLabel,
                  style: GoogleFonts.outfit(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          Icon(scoreIcon, size: 80, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildPhaseAnalysis(Map<String, List<String>> symptoms, Map<String, Map<String, int>> moods) {
    final phases = [
      AppConstants.phaseMenstrual,
      AppConstants.phaseFollicular,
      AppConstants.phaseOvulation,
      AppConstants.phaseLuteal,
    ];

    final phaseColors = {
      AppConstants.phaseMenstrual: AppTheme.cyclePeriod,
      AppConstants.phaseFollicular: AppTheme.cycleFollicular,
      AppConstants.phaseOvulation: AppTheme.cycleOvulation,
      AppConstants.phaseLuteal: AppTheme.cycleLuteal,
    };

    return Column(
      children: phases.map((phase) {
        final phaseSymptoms = symptoms[phase] ?? [];
        final phaseMoods = (moods[phase]?.entries.toList() ?? [])
          ..sort((a, b) => b.value.compareTo(a.value));
        final topMoods = phaseMoods.take(3).map((e) => e.key).toList();

        if (phaseSymptoms.isEmpty && topMoods.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: phaseColors[phase]!.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: phaseColors[phase]!.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: phaseColors[phase],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    phase,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: phaseColors[phase],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (phaseSymptoms.isNotEmpty) ...[
                Text("Common Symptoms:", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: phaseSymptoms.map((s) => _buildChip(s, phaseColors[phase]!.withOpacity(0.1), phaseColors[phase]!)).toList(),
                ),
              ],
              if (topMoods.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text("Frequent Moods:", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: topMoods.map((m) => _buildChip(m, Colors.blue.withOpacity(0.1), Colors.blue)).toList(),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCycleOverview(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatItem("Total Cycles", "${stats['totalCycles']}", Icons.loop, AppTheme.primary)),
              Expanded(child: _buildStatItem("Avg Cycle", "${stats['averageCycleLength']}d", Icons.calendar_month, AppTheme.secondary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem("Avg Period", "${stats['averagePeriodLength']}d", Icons.water_drop, AppTheme.accent)),
              Expanded(child: _buildStatItem("Variation", "${stats['longestCycle'] - stats['shortestCycle']}d", Icons.show_chart, Colors.purple)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCycleTrendChart(List<Map<String, dynamic>> trend) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}d', style: GoogleFonts.outfit(fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < trend.length) {
                    return Text('C${value.toInt() + 1}', style: GoogleFonts.outfit(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: trend.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), (e.value['length'] as int).toDouble());
              }).toList(),
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTrendChart(List<Map<String, dynamic>> trend) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}d', style: GoogleFonts.outfit(fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < trend.length) {
                    return Text('P${value.toInt() + 1}', style: GoogleFonts.outfit(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: trend.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), (e.value['length'] as int).toDouble());
              }).toList(),
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.accent,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.accent.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomChart(Map<String, int> symptoms) {
    final topSymptoms = symptoms.entries.take(5).toList();
    final maxValue = topSymptoms.first.value.toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: topSymptoms.map((entry) {
          final percentage = (entry.value / maxValue * 100).toInt();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
                    Text('${entry.value}x', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: entry.value / maxValue,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX();
  }

  Widget _buildMoodPieChart(Map<String, int> moods) {
    final topMoods = moods.entries.take(6).toList();
    final total = topMoods.fold<int>(0, (sum, entry) => sum + entry.value);

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: topMoods.asMap().entries.map((entry) {
                  final percentage = (entry.value.value / total * 100).toInt();
                  return PieChartSectionData(
                    value: entry.value.value.toDouble(),
                    title: '$percentage%',
                    color: colors[entry.key % colors.length],
                    radius: 80,
                    titleStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topMoods.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[entry.key % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value.key,
                          style: GoogleFonts.outfit(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            "Keep tracking to see insights here",
            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
