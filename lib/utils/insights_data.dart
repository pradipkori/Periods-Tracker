import 'package:period_tracker/utils/constants.dart';

class InsightsData {
  static const Map<String, List<String>> _phaseInsights = {
    AppConstants.phaseMenstrual: [
      "🩸 Nutrition: Focus on iron-rich foods like spinach, lentils, or lean red meat to replenish iron lost during your period.",
      "💧 Hydration: Drink plenty of water to help prevent fluid retention and reduce bloating.",
      "🏃‍♀️ Exercise: Listen to your body. Focus on light activities like walking, gentle yoga, or stretching.",
      "🧠 Wellness: Estrogen and progesterone are at their lowest. Prioritize rest and active recovery.",
      "🍳 Nutrition: Pair iron-rich foods with Vitamin C (like berries or citrus) to enhance absorption.",
      "🥑 Nutrition: Increase Omega-3 intake (salmon, flaxseeds) to help reduce inflammation and menstrual cramps.",
      "🧘‍♀️ Wellness: Use this time for reflection and detail-oriented tasks like data analysis or planning.",
    ],
    AppConstants.phaseFollicular: [
      "⚡ Energy: As estrogen rises, you'll feel more energetic. This is a great time to increase workout intensity.",
      "🥦 Nutrition: Support your rising energy with cruciferous vegetables like broccoli and kale to help balance estrogen.",
      "🏋️‍♀️ Exercise: Your body is efficient at building muscle now. Incorporate strength training or interval workouts.",
      "🌟 Wellness: Your cognitive clarity is typically highest now. Plan your month and set new goals.",
      "🥯 Nutrition: Focus on complex carbohydrates like whole grains and fruits to sustain your increasing activity levels.",
      "🥣 Nutrition: Support your gut health with fermented foods like yogurt or kimchi during this phase.",
      "🗣️ Wellness: Social energy is rising. It's a perfect time for networking, brainstorming, and new projects.",
    ],
    AppConstants.phaseOvulation: [
      "🔥 Energy: Estrogen peaks today, and energy is at its maximum! It's a great day for HIIT or competitive sports.",
      "🍎 Nutrition: Focus on nutrient-dense foods and antioxidants to support your body's high-performance phase.",
      "💅 Wellness: Confidence and communication skills often peak during ovulation. Important meetings? Do them now!",
      "🤕 Wellness: Mild pelvic twinges (mittelschmerz) can happen during ovulation—this is a normal sign of your body at work.",
      "🧬 Wellness: You are in your most fertile window. Your libido and social drive are likely at their monthly peak.",
      "💧 Hydration: High-intensity workouts mean more sweating—ensure you're drinking extra electrolytes today.",
      "🥗 Nutrition: Appetite may naturally decrease slightly; focus on smaller, high-quality, nutrient-rich meals.",
    ],
    AppConstants.phaseLuteal: [
      "🛌 Wellness: Progesterone is surging, which can make you feel more introverted. It's okay to prioritize 'me-time'.",
      "🍌 Nutrition: Magnesium-rich foods like bananas or dark chocolate can help ease PMS symptoms and muscle tension.",
      "🌊 Wellness: You may experience fluid retention. Limit salt and stay hydrated to help reduce feeling bloated.",
      "🏊‍♀️ Exercise: As energy dips, switch to low-impact activities like Pilates, swimming, or steady-state cardio.",
      "🥙 Nutrition: Your body uses 5-10% more calories now. Honor your hunger with protein and fiber-rich slow-burning carbs.",
      "😴 Wellness: PMS can affect sleep. Limit blue light and caffeine in the evening to improve rest quality.",
      "🥥 Nutrition: Focus on anti-inflammatory foods like avocado, nuts, and brightly colored veggies to support your mood.",
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
