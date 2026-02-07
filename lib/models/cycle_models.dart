import 'package:isar/isar.dart';

part 'cycle_models.g.dart';

@collection
class CycleLog {
  Id id = Isar.autoIncrement;
  
  @Index()
  DateTime startDate;
  DateTime? endDate;
  
  int? flowIntensity; // 1-5 (1=spotting, 2=light, 3=medium, 4=heavy, 5=very heavy)
  String? flowType; // spotting, light, medium, heavy
  String? notes;
  
  // Additional tracking
  List<String> symptoms = [];
  List<String> moods = [];
  
  // For predictions
  bool isPredicted = false;
  
  CycleLog({
    required this.startDate,
    this.endDate,
    this.flowIntensity,
    this.flowType,
    this.notes,
    this.isPredicted = false,
  });
}

@collection
class HealthLog {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  DateTime date;
  
  // Health Metrics
  double? weight;
  double? temperature;
  int? waterIntake; // in ml
  int? sleepDuration; // in minutes
  int? exerciseDuration; // in minutes
  
  // Categorical logs
  List<String> symptoms = [];
  List<String> moods = [];
  List<String> medications = [];
  
  // Intimacy & Discharge
  bool? hadIntimacy;
  bool? protectedIntimacy;
  String? dischargeType; // dry, sticky, creamy, watery, egg-white
  String? cervicalMucus; // dry, sticky, creamy, watery, egg-white
  
  // Tests
  String? ovulationTestResult; // negative, positive
  String? pregnancyTestResult; // negative, positive
  
  String? dailyNote;

  HealthLog({
    required this.date,
    this.weight,
    this.temperature,
    this.waterIntake,
    this.sleepDuration,
    this.exerciseDuration,
    this.dailyNote,
  });
}

@collection
class UserSettings {
  Id id = Isar.autoIncrement;
  
  int averageCycleLength = 28;
  int averagePeriodLength = 5;
  int lutealPhaseLength = 14;
  
  // Last period tracking
  DateTime? lastPeriodDate;
  
  // Notifications
  bool notificationsEnabled = true;
  int notificationHour = 9; // 9 AM default
  int notificationMinute = 0;
  bool periodReminderEnabled = true;
  bool ovulationReminderEnabled = true;
  bool dailyLogReminderEnabled = false;
  
  // Privacy
  String? passcode;
  bool biometricEnabled = false;
  
  // Preferences
  @Index()
  String userName = "User";
  String theme = "light"; // light, dark
  String language = "en";
  
  // Pregnancy mode
  bool pregnancyMode = false;
  DateTime? conceptionDate;
  DateTime? dueDate;
  
  // Onboarding
  bool hasCompletedOnboarding = false;
  
  // Data
  bool dataBackupEnabled = false;
  DateTime? lastBackupDate;
}

@collection
class Reminder {
  Id id = Isar.autoIncrement;
  
  String title;
  String type; // period, ovulation, medication, custom
  
  @Index()
  DateTime reminderDate;
  int hourOfDay;
  int minute;
  
  bool isEnabled = true;
  bool isRepeating = false;
  
  String? notes;
  
  Reminder({
    required this.title,
    required this.type,
    required this.reminderDate,
    required this.hourOfDay,
    required this.minute,
    this.isEnabled = true,
    this.isRepeating = false,
    this.notes,
  });
}

@collection
class Article {
  Id id = Isar.autoIncrement;
  
  String title;
  String category; // cycle, fertility, health, pregnancy
  String content;
  
  @Index()
  DateTime createdAt;
  
  Article({
    required this.title,
    required this.category,
    required this.content,
    required this.createdAt,
  });
}

@collection
class PregnancyData {
  Id id = Isar.autoIncrement;
  
  @Index()
  DateTime date;
  
  // Pregnancy tracking
  double? weight;
  List<String> symptoms = [];
  List<String> moods = [];
  
  String? notes;
  
  // Appointments
  DateTime? nextAppointment;
  String? doctorNotes;
  
  PregnancyData({
    required this.date,
    this.weight,
    this.nextAppointment,
    this.doctorNotes,
    this.notes,
  });
}

@collection
class StoredNotification {
  Id id = Isar.autoIncrement;
  
  String title;
  String body;
  
  @Index()
  DateTime timestamp;
  
  String type; // remote, local, reminder
  bool isRead = false;
  
  String? dataJson; // For storing extra payload data (JSON)
  
  StoredNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.dataJson,
  });
}
