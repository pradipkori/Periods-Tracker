import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:period_tracker/services/chat_service.dart';
import 'package:period_tracker/config/api_keys.dart';

// ---------------------------------------------------------------------------
// API Key storage – supports multiple keys (comma-separated).
// ---------------------------------------------------------------------------

final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String?>((ref) {
  return ApiKeyNotifier();
});

class ApiKeyNotifier extends StateNotifier<String?> {
  ApiKeyNotifier() : super(null) {
    _loadKey();
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('gemini_api_key');
  }

  Future<void> saveKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    state = key;
  }

  Future<void> removeKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gemini_api_key');
    state = null;
  }

  /// Parse a comma-separated string of keys into a clean list.
  static List<String> parseKeys(String raw) =>
      raw.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
}

// ---------------------------------------------------------------------------
// Chat message model
// ---------------------------------------------------------------------------

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

// ---------------------------------------------------------------------------
// Chat state – separate from AsyncValue to avoid wiping messages on loading.
// ---------------------------------------------------------------------------

class ChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Chat provider
// ---------------------------------------------------------------------------

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final apiKey = ref.watch(apiKeyProvider);
  return ChatNotifier(apiKey);
});

class ChatNotifier extends StateNotifier<ChatState> {
  final String? apiKey;
  ChatService? _chatService;

  ChatNotifier(this.apiKey) : super(const ChatState()) {
    if (apiKey != null && apiKey!.isNotEmpty) {
      // Always use hardcoded keys for rotation; user key is just the activation gate.
      _chatService = ChatService(ApiKeys.geminiKeys);
    }
    // Initial greeting message
    state = ChatState(messages: [
      ChatMessage(
        text: "Hi there! ✨ I'm Sakhi, your personal health and wellness companion. How are you feeling today? I can help with period tips, symptom management, or just be here to listen.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ]);
  }

  Future<void> sendMessage(String text) async {
    if (_chatService == null) return;

    final userMessage = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());

    // Show user message immediately + start typing indicator
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    );

    try {
      final responseText = await _chatService!.sendMessage(text);
      final botMessage = ChatMessage(text: responseText, isUser: false, timestamp: DateTime.now());
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isSending: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        text: "Oops! I ran into an issue. 🧠 If your API Key is incorrect or expired, please tap the small 'Key' icon in the top right to re-enter it!\n\n**Technical Details**: $e",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isSending: false,
      );
    }
  }

  void clearChat() {
    state = ChatState(messages: [
      ChatMessage(
        text: "Chat cleared. What's on your mind? ✨",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ]);
    if (apiKey != null && apiKey!.isNotEmpty) {
      _chatService = ChatService(ApiKeys.geminiKeys); // Reinstantiate to clear session
    }
  }
}
