import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatServiceProvider = Provider.family<ChatService, List<String>>((ref, apiKeys) {
  return ChatService(apiKeys);
});

class ChatService {
  final List<String> _apiKeys;
  int _currentKeyIndex = 0;
  GenerativeModel? _model;
  ChatSession? _chatSession;

  static const String _modelName = 'gemini-2.5-flash';

  // System prompt for Sakhi
  static const String _systemPrompt =
      "You are Sakhi, a deeply empathetic, warm, and supportive AI companion for a women's health and period tracking app. "
      "Your primary goal is to make the user feel heard, understood, and cared for. Always start by validating their feelings and offering emotional support (e.g., 'I hear you, that sounds really tough', 'It's completely normal to feel that way'). "
      "You must also be their biggest cheerleader—frequently motivate them, remind them of their inner strength, and use empowering phrases (e.g., 'You are so strong for handling this', 'You've got this', 'Your body is doing amazing work'). "
      "After offering comfort and motivation, provide highly practical, actionable answers. Suggest home remedies, gentle exercises, dietary tips, or self-care routines they can do right now to feel better. "
      "Keep the tone gentle like a caring older sister or best friend. Give clear, visually structured answers using markdown bullet points and bold text for readability. "
      "DO NOT give definitive medical diagnoses, but gently urge them to consult a doctor if symptoms sound severe. "
      "Keep responses engaging, easily understandable, and completely judgment-free.";

  /// Accepts a list of API keys. Multiple keys allow automatic rotation
  /// when a rate limit (HTTP 429) is hit during testing.
  ChatService(List<String> apiKeys)
      : _apiKeys = apiKeys.where((k) => k.isNotEmpty).toList() {
    if (_apiKeys.isEmpty) throw ArgumentError('At least one API key is required.');
    _initModel(_apiKeys[_currentKeyIndex]);
  }

  void _initModel(String apiKey) {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
    );
    _chatSession = null; // reset session when key changes
  }

  /// Rotate to next available API key. Returns true if rotated, false if exhausted.
  bool _rotateKey() {
    if (_currentKeyIndex + 1 < _apiKeys.length) {
      _currentKeyIndex++;
      _initModel(_apiKeys[_currentKeyIndex]);
      return true;
    }
    _currentKeyIndex = 0; // cycle back to first
    _initModel(_apiKeys[_currentKeyIndex]);
    return false;
  }

  Future<void> startChat({List<Content>? history}) async {
    _chatSession = _model!.startChat(history: [
      Content.text(_systemPrompt),
      Content.model([TextPart("Understood. I am Sakhi, your health companion. How can I help you today?")]),
      ...?history,
    ]);
  }

  Future<String> sendMessage(String text) async {
    if (_chatSession == null) {
      await startChat();
    }
    try {
      final response = await _chatSession!.sendMessage(Content.text(text));
      return response.text ?? "I'm having trouble processing that right now.";
    } catch (e) {
      final errStr = e.toString();
      // Detect rate-limit / quota errors and try the next key
      if ((errStr.contains('429') || errStr.contains('quota') || errStr.contains('RESOURCE_EXHAUSTED')) &&
          _apiKeys.length > 1) {
        final rotated = _rotateKey();
        await startChat();
        // Retry once with the new key
        try {
          final retryResponse = await _chatSession!.sendMessage(Content.text(text));
          final keyNote = rotated
              ? ' *(switched to key ${_currentKeyIndex + 1}/${_apiKeys.length})*'
              : ' *(all keys exhausted, using key 1 again)*';
          return (retryResponse.text ?? "I'm having trouble processing that right now.") + keyNote;
        } catch (retryErr) {
          throw Exception('All API keys exhausted. Last error: $retryErr');
        }
      }
      throw Exception('Failed to send message: $e');
    }
  }

  /// How many API keys are currently configured
  int get keyCount => _apiKeys.length;
  
  /// Index of the currently active key (1-based for display)
  int get activeKeyIndex => _currentKeyIndex + 1;
}
