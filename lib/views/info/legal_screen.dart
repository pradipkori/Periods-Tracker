import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:period_tracker/theme/app_theme.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          content,
          style: GoogleFonts.outfit(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// Sample contents
const String privacyPolicyContent = '''
1. Introduction
Welcome to Period Tracker. We are committed to protecting your personal information and your right to privacy.

2. Information We Collect
We collect personal information that you voluntarily provide to us when you register on the app, express an interest in obtaining information about us or our products, or otherwise contact us.

3. How We Use Your Information
We use personal information collected via our app for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations.

4. Will Your Information Be Shared With Anyone?
We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.

5. Is Your Information Transferred Internationally?
We may transfer, store, and process your information in countries other than your own.
''';

const String termsOfServiceContent = '''
1. Agreement to Terms
By using our application, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, then you may not access the service.

2. Intellectual Property Rights
Other than the content you own, under these Terms, Period Tracker and/or its licensors own all the intellectual property rights and materials contained in this app.

3. Restrictions
You are specifically restricted from all of the following:
- publishing any app material in any other media;
- selling, sublicensing and/or otherwise commercializing any app material;
- publicly performing and/or showing any app material;
- using this app in any way that is or may be damaging to this app.

4. Your Privacy
Please read our Privacy Policy.

5. No Warranties
This app is provided "as is," with all faults, and Period Tracker express no representations or warranties, of any kind related to this app or the materials contained on this app.
''';

const String helpCenterContent = '''
Frequently Asked Questions

Q: How do I log my period?
A: You can log your period by navigating to the home screen and tapping the "Log Period" button.

Q: Is my data secure?
A: Yes, your data is securely stored and requires authentication to access. We use industry-standard encryption.

Q: Can I use the app offline?
A: Certain features require an internet connection, such as cloud backup, but you can view your predictions offline.

Contact Support:
For further assistance, please reach out to our support team at support@periodtracker.app.
''';
