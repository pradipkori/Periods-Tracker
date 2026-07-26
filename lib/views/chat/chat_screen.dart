import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:period_tracker/providers/chat_provider.dart';
import 'package:period_tracker/theme/app_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFFBF7F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              elevation: 0,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/icon/sakhi_icon.png',
                      height: 18,
                      width: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Sakhi AI",
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: "Clear Chat",
                  icon: const Icon(Icons.cleaning_services_rounded, color: AppTheme.textSecondary, size: 22),
                  onPressed: () => ref.read(chatProvider.notifier).clearChat(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFBF7F9),
              Color(0xFFF2E6F5),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          // Always go straight to chat — keys are hardcoded
          child: _buildChatView(chatState),
        ),
      ),
    );
  }

  Widget _buildChatView(ChatState chatState) {
    // Auto-scroll whenever messages change
    if (chatState.messages.isNotEmpty) {
      _scrollToBottom();
    }
    return Column(
      children: [
        Expanded(
          child: chatState.messages.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF9E65BA)))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatState.messages[index];
                    return _buildMessageBubble(msg)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1);
                  },
                ),
        ),
        // Typing indicator
        if (chatState.isSending)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "Sakhi is typing...",
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ).animate().fadeIn().shimmer(duration: 1500.ms),
            ),
          ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFCD91DF) : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : null,
            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: message.isUser
                  ? const Color(0xFFCD91DF).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            if (!message.isUser)
              const BoxShadow(
                color: Colors.white,
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
          border: message.isUser ? null : Border.all(color: Colors.white, width: 1.5),
        ),
        child: message.isUser
            ? Text(
                message.text,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 16, height: 1.5),
                  strong: GoogleFonts.outfit(
                      color: const Color(0xFF8A46A6), fontWeight: FontWeight.bold),
                  listBullet: GoogleFonts.outfit(color: const Color(0xFF8A46A6)),
                ),
              ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEFA),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: "Ask Sakhi...",
                  hintStyle: GoogleFonts.outfit(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => _sendMessage(val),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCE94E0), Color(0xFFB580D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB580D1).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String val) {
    if (val.trim().isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(val.trim());
      _controller.clear();
    }
  }

  Widget _buildApiKeySetup() {
    final setupController = TextEditingController();
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB580D1).withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EEFA),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Image.asset(
                  'assets/icon/sakhi_icon.png',
                  height: 80,
                  width: 80,
                  color: AppTheme.primary,
                ).animate().scale(delay: 200.ms).fadeIn(),
              ),
              const SizedBox(height: 24),
              Text(
                "Meet Sakhi AI",
                style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your empathetic companion for cycle tracking and wellness. Enter your Google Gemini API key(s) below.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              // Multi-key tip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EEFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2C2ED)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFB580D1), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "For testing: paste multiple API keys separated by commas to auto-rotate when a rate limit is hit.",
                        style: GoogleFonts.outfit(
                            color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2C2ED)),
                ),
                child: TextField(
                  controller: setupController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Paste API key(s) here (comma-separated for multiple)",
                    hintStyle: GoogleFonts.outfit(
                        color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 14),
                    border: InputBorder.none,
                    icon: const Icon(Icons.vpn_key_rounded, color: Color(0xFFB580D1), size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final key = setupController.text.trim();
                    if (key.isNotEmpty) {
                      ref.read(apiKeyProvider.notifier).saveKey(key);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    "Activate Sakhi",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
