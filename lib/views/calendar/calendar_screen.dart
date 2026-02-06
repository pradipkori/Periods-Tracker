import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/views/logs/period_logging_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, String> _dayPhases = {}; // Store phase for each day
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final predictionService = ref.read(predictionServiceProvider);
    final dbService = ref.read(dbServiceProvider);
    final settings = await dbService.getSettings();
    
    final cycleLength = await predictionService.getEffectiveCycleLength();
    final cycles = await dbService.getAllCycles();
    final Map<String, String> phases = {};
    
    for (final cycle in cycles) {
      final prefix = cycle.isPredicted ? 'predicted_' : 'actual_';
      
      // 1. Mark period days
      DateTime current = cycle.startDate;
      final end = cycle.endDate ?? cycle.startDate.add(const Duration(days: 4));
      
      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        final key = '${current.year}-${current.month}-${current.day}';
        phases[key] = '${prefix}period';
        current = current.add(const Duration(days: 1));
      }

      // 2. Calculate fertile window for THIS cycle using consolidated logic
      final ovulationDate = cycle.startDate.add(Duration(days: cycleLength - settings.lutealPhaseLength));
      
      // Fertile Window (5 days before + day of ovulation)
      for (int i = -5; i <= 0; i++) {
        final fertileDay = ovulationDate.add(Duration(days: i));
        final fKey = '${fertileDay.year}-${fertileDay.month}-${fertileDay.day}';
        if (!phases.containsKey(fKey)) {
          phases[fKey] = '${prefix}fertile';
        }
      }
      
      // Ovulation Peak
      final oKey = '${ovulationDate.year}-${ovulationDate.month}-${ovulationDate.day}';
      phases[oKey] = '${prefix}ovulation';
    }
    
    if (mounted) {
      setState(() {
        _dayPhases = phases;
        _isLoading = false;
      });
    }
  }

  String? _getPhaseForDay(DateTime day) {
    final key = '${day.year}-${day.month}-${day.day}';
    return _dayPhases[key];
  }

  Color _getColorForPhase(String? phase) {
    if (phase == null) return AppTheme.primary;
    
    if (phase.contains('period')) return AppTheme.cyclePeriod;
    if (phase.contains('fertile')) return AppTheme.cycleOvulation;
    if (phase.contains('ovulation')) return AppTheme.cycleFollicular;
    
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final selectedPhase = _getPhaseForDay(_selectedDay ?? _focusedDay);
    final phaseColor = _getColorForPhase(selectedPhase);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Calendar", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildModernCalendar(phaseColor),
                  const SizedBox(height: 12),
                  _buildModernLegend(),
                  const SizedBox(height: 24),
                  _buildDayDetailsSection(phaseColor),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCalendar(Color phaseColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          _loadCycleData();
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary),
          rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textPrimary),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.outfit(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
          weekendStyle: GoogleFonts.outfit(color: AppTheme.primary.withOpacity(0.6), fontWeight: FontWeight.w600, fontSize: 13),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) => _buildDayWidget(day, false),
          todayBuilder: (context, day, focusedDay) => _buildDayWidget(day, true, isToday: true),
          selectedBuilder: (context, day, focusedDay) => _buildDayWidget(day, true, isSelected: true),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildDayWidget(DateTime day, bool isSpecial, {bool isSelected = false, bool isToday = false}) {
    final phase = _getPhaseForDay(day);
    final baseColor = _getColorForPhase(phase);
    final hasPhase = phase != null;
    final isPredicted = phase?.startsWith('predicted_') ?? false;

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected 
            ? AppTheme.textPrimary 
            : (hasPhase ? baseColor.withOpacity(isPredicted ? 0.08 : 0.2) : Colors.transparent),
        border: isToday && !isSelected 
            ? Border.all(color: AppTheme.primary, width: 1.5) 
            : (isSelected ? null : (hasPhase ? Border.all(color: baseColor.withOpacity(isPredicted ? 0.05 : 0.15), width: 1) : null)),
        boxShadow: isSelected ? [
          BoxShadow(color: AppTheme.textPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ] : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : (hasPhase ? baseColor.withOpacity(isPredicted ? 0.6 : 1.0) : AppTheme.textPrimary),
                fontWeight: (hasPhase || isSelected || isToday) ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
            if (hasPhase && !isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(isPredicted ? 0.4 : 1.0), 
                  shape: BoxShape.circle
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _modernLegendItem("Period", AppTheme.cyclePeriod),
          _modernLegendItem("Fertile", AppTheme.cycleOvulation),
          _modernLegendItem("Peak", AppTheme.cycleFollicular),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _modernLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildDayDetailsSection(Color phaseColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(),
          const SizedBox(height: 16),
          _buildDetailCards(phaseColor),
        ],
      ),
    );
  }

  Widget _buildDayHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Day Details",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            Text(
              "${_selectedDay?.day} ${_getMonthName(_selectedDay?.month)}",
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _openLoggingScreen(),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text("Log Period", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  void _openLoggingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PeriodLoggingScreen(initialDate: _selectedDay),
      ),
    );
  }

  Widget _buildDetailCards(Color phaseColor) {
    // Listen for changes to cycles and refresh data
    ref.listen(cyclesProvider, (previous, next) {
      _loadCycleData();
    });

    final curPhase = _getPhaseForDay(_selectedDay ?? _focusedDay);
    
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(dbServiceProvider).getCycleStatistics(),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        return Column(
          children: [
            _modernDetailTile(
              "Current Phase", 
              _formatPhaseName(curPhase ?? "No Phase"), 
              Icons.auto_awesome_rounded, 
              phaseColor,
              index: 0
            ),
            const SizedBox(height: 12),
            _modernDetailTile(
              "Cycle Status", 
              stats != null ? "Avg ${stats['averageCycleLength']} Days" : "Calculating...", 
              Icons.loop_rounded, 
              AppTheme.secondary,
              index: 1
            ),
            const SizedBox(height: 12),
            _modernDetailTile(
              "Chance of Pregnancy", 
              (curPhase?.contains('fertile') ?? false) || (curPhase?.contains('ovulation') ?? false) ? "High" : "Low", 
              Icons.favorite_rounded, 
              AppTheme.cyclePeriod,
              index: 2
            ),
          ],
        );
      }
    );
  }

  Widget _modernDetailTile(String title, String value, IconData icon, Color color, {required int index}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (600 + (index * 100)).ms).slideX(begin: 0.1);
  }

  String _formatPhaseName(String phase) {
    if (phase.contains('ovulation')) return "Peak Ovulation";
    if (phase.contains('fertile')) return "Fertile Window";
    if (phase.contains('period')) return "Menstrual Phase";
    return "Follicular / Luteal";
  }

  String _getMonthName(int? month) {
    if (month == null) return "";
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}
