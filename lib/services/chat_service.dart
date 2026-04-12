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

  static const String _modelName = 'gemini-2.5-flash-preview-04-17';

  // System prompt for Sakhi
  static const String _systemPrompt =
      "You are Sakhi, an empathetic, supportive, and highly knowledgeable AI companion specifically designed for a menstrual cycle and women's health tracking app. "
      "You answer questions about the menstrual cycle, ovulation, period symptoms, mental health, and general wellness. "
      "Always be kind, respectful, and comforting. Give clear, visually structured answers (use markdown bullet points, bold text). "
      "DO NOT give definitive medical diagnoses. Always include a disclaimer for severe symptoms that they should consult a doctor. "
      "Keep responses engaging, modern, and concise.";

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
