import 'package:period_tracker/utils/constants.dart';

class InsightsData {
  static const Map<String, List<String>> _phaseInsights = {
    AppConstants.phaseMenstrual: [
      "Hydration is key! Drinking water can help reduce bloating and discomfort during your period.",
      "Take it easy today. Gentle stretching or a short walk can help boost your mood without overexertion.",
      "Cramps bothering you? A warm heating pad or a warm bath can provide natural relief.",
      "Iron-rich foods like spinach and lentils are great during your period to help maintain energy levels.",
      "Rest is productive! Your body is working hard, so don't feel guilty about taking an extra nap.",
      "Dark chocolate (70% cocoa or more) can help satisfy cravings and even boost your mood!",
      "Magnesium-rich foods like almonds and bananas can help ease muscle tension and cramps.",
    ],
    AppConstants.phaseFollicular: [
      "Energy levels are rising! This is a great time to start a new project or try a more intense workout.",
      "Your skin often looks its best during this phase. Enjoy that natural glow!",
      "Focus on creativity today. Your brain is primed for brainstorming and problem-solving.",
      "Social energy is high! It's a perfect day to catch up with friends or network.",
      "Try incorporating fermented foods like yogurt or kimchi to support your gut health during this phase.",
      "Your body is efficient at building muscle right now. Consider adding some strength training.",
      "Plan your month ahead! Your cognitive clarity is typically highest during the follicular phase.",
    ],
    AppConstants.phaseOvulation: [
      "You're in your most fertile window. Confidence and communication skills often peak today!",
      "Focus on connection. You might feel more social and outgoing than usual.",
      "This is a high-energy phase! It's an excellent time for high-intensity interval training (HIIT).",
      "Listen to your body. Some people experience 'mittelschmerz' (mild ovulation pain) - it's normal!",
      "Your libido might be higher than usual today. It's a natural part of the ovulation process.",
      "Antioxidant-rich berries are great for supporting your body's processes during ovulation.",
      "Enjoy the boost in energy and positivity that often accompanies this phase!",
    ],
    AppConstants.phaseLuteal: [
      "Progesterone is rising, which might make you feel more introverted. It's okay to stay in and cozy up.",
      "B6-rich foods like chickpeas and salmon can help manage premenstrual symptoms.",
      "Focus on calming activities like yoga, meditation, or reading a good book.",
      "You might notice cravings for comfort foods. Try to balance them with complex carbs for steady energy.",
      "Be kind to yourself. If you're feeling more sensitive than usual, acknowledge it as a hormonal shift.",
      "Reduce caffeine and salt intake if you're experiencing bloating or breast tenderness.",
      "Prioritize sleep. You might need a bit more rest as you approach the end of your cycle.",
    ],
  };

  static String getInsight(String phase, int cycleDay) {
    final insights = _phaseInsights[phase];
    if (insights == null || insights.isEmpty) {
      return "Track your cycle regularly for personalized insights!";
    }

    // Use cycleDay to select an insight (rotate through if cycle is long)
    final index = (cycleDay - 1) % insights.length;
    return insights[index];
  }
}
