class Validators {
  // Validate date range
  static bool isValidDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return end.isAfter(start) || end.isAtSameMomentAs(start);
  }

  // Validate cycle length
  static bool isValidCycleLength(int? length) {
    if (length == null) return false;
    return length >= 21 && length <= 35;
  }

  // Validate period length
  static bool isValidPeriodLength(int? length) {
    if (length == null) return false;
    return length >= 2 && length <= 10;
  }

  // Validate weight (in kg)
  static bool isValidWeight(double? weight) {
    if (weight == null) return false;
    return weight >= 30 && weight <= 200;
  }

  // Validate temperature (in Celsius)
  static bool isValidTemperature(double? temp) {
    if (temp == null) return false;
    return temp >= 35.0 && temp <= 42.0;
  }

  // Validate water intake (in ml)
  static bool isValidWaterIntake(int? intake) {
    if (intake == null) return false;
    return intake >= 0 && intake <= 10000;
  }

  // Validate sleep duration (in minutes)
  static bool isValidSleepDuration(int? duration) {
    if (duration == null) return false;
    return duration >= 0 && duration <= 1440; // 24 hours max
  }

  // Validate exercise duration (in minutes)
  static bool isValidExerciseDuration(int? duration) {
    if (duration == null) return false;
    return duration >= 0 && duration <= 480; // 8 hours max
  }

  // Validate password strength
  static bool isStrongPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    
    // At least 4 characters for PIN
    if (password.length < 4) return false;
    
    return true;
  }

  // Validate PIN (4-6 digits)
  static bool isValidPin(String? pin) {
    if (pin == null || pin.isEmpty) return false;
    
    final pinRegex = RegExp(r'^\d{4,6}$');
    return pinRegex.hasMatch(pin);
  }

  // Validate email
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Validate age
  static bool isValidAge(int? age) {
    if (age == null) return false;
    return age >= 10 && age <= 60;
  }

  // Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) return 'Password required';
    if (password.length < 4) return 'Too short (min 4 characters)';
    if (password.length >= 4 && password.length < 6) return 'Weak';
    if (password.length >= 6 && password.length < 8) return 'Medium';
    return 'Strong';
  }

  // Validate numeric input
  static bool isNumeric(String? str) {
    if (str == null || str.isEmpty) return false;
    return double.tryParse(str) != null;
  }

  // Validate positive number
  static bool isPositiveNumber(String? str) {
    if (!isNumeric(str)) return false;
    final num = double.parse(str!);
    return num > 0;
  }
}
