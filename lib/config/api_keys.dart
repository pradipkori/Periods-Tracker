/// Hardcoded Gemini API keys for testing.
/// Multiple keys are rotated automatically when a rate limit (429) is hit.
/// Add / remove keys here as needed.
class ApiKeys {
  ApiKeys._();

  static const List<String> geminiKeys = [
    'AIzaSyCkMy1aPljpBpCmqyyzC1gctdwCRCReTBY', // Key 1 — add your keys here
    'AIzaSyAMKKtvYiJo-5VuDp2HTwHzjJ3DIxJIYMQ', // Key 2
    'AIzaSyBO5tc1i293CYM7sl9eVd5zPi_lcfKv--M', // Key 3
  ];
}
