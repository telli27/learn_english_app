import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

class TermsOfUseScreen extends ConsumerWidget {
  const TermsOfUseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Use"),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Terms of Use", isDark),
              _buildSectionText(
                "By accepting these terms, you agree to comply with the following conditions when using the Englitics application.",
                isDark,
              ),
              _buildSectionTitle("Service Usage", isDark),
              _buildSectionText(
                "By using the Englitics application, you:",
                isDark,
              ),
              _buildBulletPoint(
                  "Confirm that you are responsible for the security of your personal account",
                  isDark),
              _buildBulletPoint("Commit not to misuse the application", isDark),
              _buildBulletPoint(
                  "Agree to act in accordance with applicable laws", isDark),
              _buildSectionTitle("Account Registration", isDark),
              _buildSectionText(
                "You may need to create an account to use some features of our services. When registering:",
                isDark,
              ),
              _buildBulletPoint(
                  "You must provide accurate, complete, and current information",
                  isDark),
              _buildBulletPoint(
                  "You are responsible for keeping your password secure",
                  isDark),
              _buildBulletPoint(
                  "You are responsible for all activities on your account",
                  isDark),
              _buildSectionTitle("Content and Copyright", isDark),
              _buildSectionText(
                "All texts, graphics, user interfaces, visual interfaces, trademarks, logos, and computer codes ('Content') within the application belong to Englitics or its licensors and are protected by copyright laws.",
                isDark,
              ),
              _buildSectionText(
                "As a user, you:",
                isDark,
              ),
              _buildBulletPoint(
                  "May not modify or create derivative works of the Content",
                  isDark),
              _buildBulletPoint(
                  "May not use the Content for commercial purposes", isDark),
              _buildBulletPoint(
                  "May not remove any copyright notices or other proprietary notices",
                  isDark),
              _buildSectionTitle("Prohibited Uses", isDark),
              _buildSectionText(
                "The following uses are strictly prohibited:",
                isDark,
              ),
              _buildBulletPoint(
                  "Posting illegal, harmful, threatening, harassing, or defamatory content",
                  isDark),
              _buildBulletPoint("Spreading viruses or malicious code", isDark),
              _buildBulletPoint("Violating application security", isDark),
              _buildBulletPoint("Unauthorized use of accounts", isDark),
              _buildBulletPoint(
                  "Using our services with automated methods", isDark),
              _buildSectionTitle("Payments and Subscriptions", isDark),
              _buildSectionText(
                "You may need to make payments to access premium features. All payment terms:",
                isDark,
              ),
              _buildBulletPoint("Prices are shown including taxes", isDark),
              _buildBulletPoint(
                  "Subscriptions renew automatically and can be canceled in your subscription settings",
                  isDark),
              _buildBulletPoint(
                  "Refund policies are subject to Apple App Store or Google Play Store rules",
                  isDark),
              _buildSectionTitle("Disclaimer", isDark),
              _buildSectionText(
                "Our application is provided 'as is'. Englitics does not guarantee that the application will work uninterrupted or error-free.",
                isDark,
              ),
              _buildSectionTitle("Limited Liability", isDark),
              _buildSectionText(
                "Englitics cannot be held liable for any indirect, incidental, special, or exemplary damages.",
                isDark,
              ),
              _buildSectionTitle("Changes", isDark),
              _buildSectionText(
                "We reserve the right to change these terms of use at any time. We will notify users when changes occur.",
                isDark,
              ),
              _buildSectionTitle("Contact", isDark),
              _buildSectionText(
                "If you have any questions about these terms of use, please contact us at huseyintelli30@gmail.com",
                isDark,
              ),
              const SizedBox(height: 30),
              Text(
                "Last Updated: June 25, 2024",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.blue : Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
