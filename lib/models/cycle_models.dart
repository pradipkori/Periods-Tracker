class CycleLog {
  String? id;
  DateTime startDate;
  DateTime? endDate;
  int? flowIntensity; // 1-5 (1=spotting, 2=light, 3=medium, 4=heavy, 5=very heavy)
  String? flowType; // spotting, light, medium, heavy
  String? notes;
  List<String> symptoms;
  List<String> moods;
  bool isPredicted;

  CycleLog({
    this.id,
    required this.startDate,
    this.endDate,
    this.flowIntensity,
    this.flowType,
    this.notes,
    this.symptoms = const [],
    this.moods = const [],
    this.isPredicted = false,
  });

  factory CycleLog.fromJson(Map<String, dynamic> json) {
    return CycleLog(
      id: json['id'] as String?,
      startDate: DateTime.parse(json['start_date'] as String).toLocal(),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String).toLocal() : null,
      flowIntensity: json['flow_intensity'] as int?,
      flowType: json['flow_type'] as String?,
      notes: json['notes'] as String?,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      moods: List<String>.from(json['moods'] ?? []),
      isPredicted: json['is_predicted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      'flow_intensity': flowIntensity,
      'flow_type': flowType,
      'notes': notes,
      'symptoms': symptoms,
      'moods': moods,
      'is_predicted': isPredicted,
    };
  }
}

class HealthLog {
  String? id;
  DateTime date;
  double? weight;
  double? temperature;
  int? waterIntake;
  int? sleepDuration;
  int? exerciseDuration;
  List<String> symptoms;
  List<String> moods;
  List<String> medications;
  bool? hadIntimacy;
  bool? protectedIntimacy;
  String? dischargeType;
  String? cervicalMucus;
  String? ovulationTestResult;
  String? pregnancyTestResult;
  String? dailyNote;

  HealthLog({
    this.id,
    required this.date,
    this.weight,
    this.temperature,
    this.waterIntake,
    this.sleepDuration,
    this.exerciseDuration,
    this.symptoms = const [],
    this.moods = const [],
    this.medications = const [],
    this.hadIntimacy,
    this.protectedIntimacy,
    this.dischargeType,
    this.cervicalMucus,
    this.ovulationTestResult,
    this.pregnancyTestResult,
    this.dailyNote,
  });

  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String).toLocal(),
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      waterIntake: json['water_intake'] as int?,
      sleepDuration: json['sleep_duration'] as int?,
      exerciseDuration: json['exercise_duration'] as int?,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      moods: List<String>.from(json['moods'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      hadIntimacy: json['had_intimacy'] as bool?,
      protectedIntimacy: json['protected_intimacy'] as bool?,
      dischargeType: json['discharge_type'] as String?,
      cervicalMucus: json['cervical_mucus'] as String?,
      ovulationTestResult: json['ovulation_test_result'] as String?,
      pregnancyTestResult: json['pregnancy_test_result'] as String?,
      dailyNote: json['daily_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toUtc().toIso8601String(),
      'weight': weight,
      'temperature': temperature,
      'water_intake': waterIntake,
      'sleep_duration': sleepDuration,
      'exercise_duration': exerciseDuration,
      'symptoms': symptoms,
      'moods': moods,
      'medications': medications,
      'had_intimacy': hadIntimacy,
      'protected_intimacy': protectedIntimacy,
      'discharge_type': dischargeType,
      'cervical_mucus': cervicalMucus,
      'ovulation_test_result': ovulationTestResult,
      'pregnancy_test_result': pregnancyTestResult,
      'daily_note': dailyNote,
    };
  }
}

class UserSettings {
  String? id;
  int averageCycleLength;
  int averagePeriodLength;
  int lutealPhaseLength;
  DateTime? lastPeriodDate;
  bool notificationsEnabled;
  int notificationHour;
  int notificationMinute;
  bool periodReminderEnabled;
  bool ovulationReminderEnabled;
  bool dailyLogReminderEnabled;
  String? passcode;
  bool biometricEnabled;
  String userName;
  String theme;
  String language;
  bool pregnancyMode;
  DateTime? conceptionDate;
  DateTime? dueDate;
  bool hasCompletedOnboarding;
  bool dataBackupEnabled;
  DateTime? lastBackupDate;
  int healthLogStreak;
  DateTime? lastHealthLogDate;

  UserSettings({
    this.id,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.lutealPhaseLength = 14,
    this.lastPeriodDate,
    this.notificationsEnabled = true,
    this.notificationHour = 9,
    this.notificationMinute = 0,
    this.periodReminderEnabled = true,
    this.ovulationReminderEnabled = true,
    this.dailyLogReminderEnabled = false,
    this.passcode,
    this.biometricEnabled = false,
    this.userName = "User",
    this.theme = "light",
    this.language = "en",
    this.pregnancyMode = false,
    this.conceptionDate,
    this.dueDate,
    this.hasCompletedOnboarding = false,
    this.dataBackupEnabled = false,
    this.lastBackupDate,
    this.healthLogStreak = 0,
    this.lastHealthLogDate,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as String?,
      averageCycleLength: json['average_cycle_length'] as int? ?? 28,
      averagePeriodLength: json['average_period_length'] as int? ?? 5,
      lutealPhaseLength: json['luteal_phase_length'] as int? ?? 14,
      lastPeriodDate: json['last_period_date'] != null ? DateTime.parse(json['last_period_date'] as String).toLocal() : null,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      notificationHour: json['notification_hour'] as int? ?? 9,
      notificationMinute: json['notification_minute'] as int? ?? 0,
      periodReminderEnabled: json['period_reminder_enabled'] as bool? ?? true,
      ovulationReminderEnabled: json['ovulation_reminder_enabled'] as bool? ?? true,
      dailyLogReminderEnabled: json['daily_log_reminder_enabled'] as bool? ?? false,
      passcode: json['passcode'] as String?,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      userName: json['user_name'] as String? ?? "User",
      theme: json['theme'] as String? ?? "light",
      language: json['language'] as String? ?? "en",
      pregnancyMode: json['pregnancy_mode'] as bool? ?? false,
      conceptionDate: json['conception_date'] != null ? DateTime.parse(json['conception_date'] as String).toLocal() : null,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String).toLocal() : null,
      hasCompletedOnboarding: json['has_completed_onboarding'] as bool? ?? false,
      dataBackupEnabled: json['data_backup_enabled'] as bool? ?? false,
      lastBackupDate: json['last_backup_date'] != null ? DateTime.parse(json['last_backup_date'] as String).toLocal() : null,
      healthLogStreak: json['health_log_streak'] as int? ?? 0,
      lastHealthLogDate: json['last_health_log_date'] != null ? DateTime.parse(json['last_health_log_date'] as String).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'average_cycle_length': averageCycleLength,
      'average_period_length': averagePeriodLength,
      'luteal_phase_length': lutealPhaseLength,
      'last_period_date': lastPeriodDate?.toUtc().toIso8601String(),
      'notifications_enabled': notificationsEnabled,
      'notification_hour': notificationHour,
      'notification_minute': notificationMinute,
      'period_reminder_enabled': periodReminderEnabled,
      'ovulation_reminder_enabled': ovulationReminderEnabled,
      'daily_log_reminder_enabled': dailyLogReminderEnabled,
      'passcode': passcode,
      'biometric_enabled': biometricEnabled,
      'user_name': userName,
      'theme': theme,
      'language': language,
      'pregnancy_mode': pregnancyMode,
      'conception_date': conceptionDate?.toUtc().toIso8601String(),
      'due_date': dueDate?.toUtc().toIso8601String(),
      'has_completed_onboarding': hasCompletedOnboarding,
      'data_backup_enabled': dataBackupEnabled,
      'last_backup_date': lastBackupDate?.toUtc().toIso8601String(),
      'health_log_streak': healthLogStreak,
      'last_health_log_date': lastHealthLogDate?.toUtc().toIso8601String(),
    };
  }
}

class Reminder {
  String? id;
  String title;
  String type;
  DateTime reminderDate;
  int hourOfDay;
  int minute;
  bool isEnabled;
  bool isRepeating;
  String? notes;

  Reminder({
    this.id,
    required this.title,
    required this.type,
    required this.reminderDate,
    required this.hourOfDay,
    required this.minute,
    this.isEnabled = true,
    this.isRepeating = false,
    this.notes,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String?,
      title: json['title'] as String,
      type: json['type'] as String,
      reminderDate: DateTime.parse(json['reminder_date'] as String).toLocal(),
      hourOfDay: json['hour_of_day'] as int,
      minute: json['minute'] as int,
      isEnabled: json['is_enabled'] as bool? ?? true,
      isRepeating: json['is_repeating'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'type': type,
      'reminder_date': reminderDate.toUtc().toIso8601String(),
      'hour_of_day': hourOfDay,
      'minute': minute,
      'is_enabled': isEnabled,
      'is_repeating': isRepeating,
      'notes': notes,
    };
  }
}

class Article {
  String? id;
  String title;
  String category;
  String content;
  DateTime createdAt;

  Article({
    this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String?,
      title: json['title'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

class PregnancyData {
  String? id;
  DateTime date;
  double? weight;
  List<String> symptoms;
  List<String> moods;
  String? notes;
  DateTime? nextAppointment;
  String? doctorNotes;

  PregnancyData({
    this.id,
    required this.date,
    this.weight,
    this.symptoms = const [],
    this.moods = const [],
    this.notes,
    this.nextAppointment,
    this.doctorNotes,
  });

  factory PregnancyData.fromJson(Map<String, dynamic> json) {
    return PregnancyData(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String).toLocal(),
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      moods: List<String>.from(json['moods'] ?? []),
      notes: json['notes'] as String?,
      nextAppointment: json['next_appointment'] != null ? DateTime.parse(json['next_appointment'] as String).toLocal() : null,
      doctorNotes: json['doctor_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toUtc().toIso8601String(),
      'weight': weight,
      'symptoms': symptoms,
      'moods': moods,
      'notes': notes,
      'next_appointment': nextAppointment?.toUtc().toIso8601String(),
      'doctor_notes': doctorNotes,
    };
  }
}

class StoredNotification {
  String? id;
  String title;
  String body;
  DateTime timestamp;
  String type;
  bool isRead;
  String? dataJson;

  StoredNotification({
    this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.dataJson,
  });

  factory StoredNotification.fromJson(Map<String, dynamic> json) {
    return StoredNotification(
      id: json['id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      dataJson: json['data_json'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'type': type,
      'is_read': isRead,
      'data_json': dataJson,
    };
  }
}
