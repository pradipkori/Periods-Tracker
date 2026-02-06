import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordSetupScreen extends ConsumerStatefulWidget {
  const PasswordSetupScreen({super.key});

  @override
  ConsumerState<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends ConsumerState<PasswordSetupScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Set Password", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock, size: 80, color: AppTheme.primary),
            const SizedBox(height: 24),
            Text(
              "Protect Your Data",
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Set a password to keep your personal health data secure.",
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Enter password (min 4 characters)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primary),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                hintText: "Re-enter password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primary),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _setPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("SET PASSWORD", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      _showError("Please enter a password");
      return;
    }

    if (password.length < 4) {
      _showError("Password must be at least 4 characters");
      return;
    }

    if (password != confirm) {
      _showError("Passwords do not match");
      return;
    }

    // Hash password
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);

    final db = ref.read(dbServiceProvider);
    final settings = await db.getSettings();
    settings.passcode = hash.toString();
    await db.saveSettings(settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password set successfully!")),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

class PasswordLockScreen extends ConsumerStatefulWidget {
  final Widget child;
  const PasswordLockScreen({super.key, required this.child});

  @override
  ConsumerState<PasswordLockScreen> createState() => _PasswordLockScreenState();
}

class _PasswordLockScreenState extends ConsumerState<PasswordLockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isUnlocked = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) {
      return widget.child;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withOpacity(0.1),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 100, color: AppTheme.primary),
                  const SizedBox(height: 40),
                  Text(
                    "Enter Password",
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Unlock to access your data",
                    style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofocus: true,
                    onSubmitted: (_) => _unlock(),
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _unlock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("UNLOCK", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    final password = _passwordController.text;
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);

    final db = ref.read(dbServiceProvider);
    final settings = await db.getSettings();

    if (settings.passcode == hash.toString()) {
      setState(() => _isUnlocked = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect password"), backgroundColor: Colors.red),
      );
      _passwordController.clear();
    }
  }
}
