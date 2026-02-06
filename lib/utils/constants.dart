// App-wide constants for Period Tracker

class AppConstants {
  // Symptom categories
  static const List<String> symptoms = [
    'Cramps',
    'Headache',
    'Migraine',
    'Bloating',
    'Acne',
    'Back Pain',
    'Tender Breasts',
    'Nausea',
    'Fatigue',
    'Diarrhea',
    'Constipation',
    'Food Cravings',
    'Insomnia',
    'Hot Flashes',
    'Cold Flashes',
    'Dizziness',
    'Joint Pain',
    'Muscle Aches',
    'Increased Appetite',
    'Decreased Appetite',
    'Vaginal Dryness',
    'Increased Discharge',
    'Spotting',
    'Heavy Flow',
    'Breast Swelling',
    'Abdominal Pain',
    'Lower Back Pain',
    'Leg Pain',
    'Mood Swings',
    'Other',
  ];

  // Mood categories
  static const List<String> moods = [
    'Happy',
    'Calm',
    'Energetic',
    'Confident',
    'Focused',
    'Irritable',
    'Sad',
    'Anxious',
    'Stressed',
    'Angry',
    'Depressed',
    'Emotional',
    'Tired',
    'Restless',
  ];

  // Discharge types
  static const List<String> dischargeTypes = [
    'Dry',
    'Sticky',
    'Creamy',
    'Watery',
    'Egg White',
  ];

  // Flow types
  static const List<String> flowTypes = [
    'Spotting',
    'Light',
    'Medium',
    'Heavy',
    'Very Heavy',
  ];

  // Cycle phases
  static const String phaseMenstrual = 'Menstrual';
  static const String phaseFollicular = 'Follicular';
  static const String phaseOvulation = 'Ovulation';
  static const String phaseLuteal = 'Luteal';

  // Default values
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int defaultLutealPhaseLength = 14;
  static const int defaultOvulationDay = 14; // Days before next period

  // Notification types
  static const String notificationTypePeriod = 'period';
  static const String notificationTypeOvulation = 'ovulation';
  static const String notificationTypeMedication = 'medication';
  static const String notificationTypeCustom = 'custom';

  // Educational content categories
  static const String categoryEducationCycle = 'cycle';
  static const String categoryEducationFertility = 'fertility';
  static const String categoryEducationHealth = 'health';
  static const String categoryEducationPregnancy = 'pregnancy';

  // Pregnancy tracking
  static const int pregnancyWeeks = 40;
  static const int pregnancyDays = 280;

  // Test results
  static const String testResultNegative = 'negative';
  static const String testResultPositive = 'positive';

  // Themes
  static const String themeLight = 'light';
  static const String themeDark = 'dark';

  // Languages
  static const String languageEnglish = 'en';

  // Fertility probability
  static const Map<String, String> fertilityLevels = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'very_high': 'Very High',
  };

  // Cycle regularity
  static const int regularCycleVariation = 3; // +/- 3 days is considered regular
}
