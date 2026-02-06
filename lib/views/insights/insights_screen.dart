import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(cycleStatsProvider);
    final insightsAsync = ref.watch(insightsProvider);
    final healthScoreAsync = ref.watch(healthScoreProvider);
    final cycleTrendAsync = ref.watch(cycleLengthTrendProvider);
    final symptomFreqAsync = ref.watch(symptomFrequencyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Insights & Analytics", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Score
            healthScoreAsync.when(
              data: (score) => _buildHealthScoreCard(score),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Statistics
            statsAsync.when(
              data: (stats) => _buildStatsCard(stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Symptom Distribution
            symptomFreqAsync.when(
              data: (freq) => freq.isNotEmpty ? _buildSymptomDistributionChart(freq) : const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Cycle Trend Chart
            cycleTrendAsync.when(
              data: (trend) => trend.isNotEmpty ? _buildCycleTrendChart(trend) : const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Insights
            insightsAsync.when(
              data: (insights) => _buildInsightsList(insights),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomDistributionChart(Map<String, int> freq) {
    if (freq.isEmpty) return const SizedBox.shrink();

    // Top 5 symptoms for chart
    final topEntries = freq.entries.toList().take(5).toList();
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.cyclePeriod,
      AppTheme.cycleOvulation,
      AppTheme.cycleLuteal,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Symptoms Distribution",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: topEntries.asMap().entries.map((e) {
                      final index = e.key;
                      final entry = e.value;
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: entry.value.toDouble(),
                        title: '',
                        radius: 50,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topEntries.asMap().entries.map((e) {
                    final index = e.key;
                    final entry = e.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${entry.value}",
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(int score) {
    Color scoreColor;
    String scoreLabel;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreLabel = "Excellent";
    } else if (score >= 60) {
      scoreColor = Colors.blue;
      scoreLabel = "Good";
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreLabel = "Fair";
    } else {
      scoreColor = Colors.red;
      scoreLabel = "Needs Improvement";
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
      child: Column(
        children: [
          Text(
            "Health Score",
            style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(
            "$score",
            style: GoogleFonts.outfit(fontSize: 64, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            scoreLabel,
            style: GoogleFonts.outfit(fontSize: 20, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cycle Statistics",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _statRow("Total Cycles", "${stats['totalCycles']}"),
          _statRow("Average Cycle", "${stats['averageCycleLength']} days"),
          _statRow("Average Period", "${stats['averagePeriodLength']} days"),
          if (stats['shortestCycle'] > 0)
            _statRow("Shortest Cycle", "${stats['shortestCycle']} days"),
          if (stats['longestCycle'] > 0)
            _statRow("Longest Cycle", "${stats['longestCycle']} days"),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCycleTrendChart(List<Map<String, dynamic>> trend) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cycle Length Trend",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trend.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), (e.value['length'] as int).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsList(List<String> insights) {
    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          "Start tracking to get personalized insights!",
          style: GoogleFonts.outfit(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Personalized Insights",
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: Text(
            insight,
            style: GoogleFonts.outfit(fontSize: 14),
          ),
        )),
      ],
    );
  }
}
