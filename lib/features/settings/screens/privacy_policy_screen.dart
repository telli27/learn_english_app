import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
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
              _buildSectionTitle("Privacy Policy", isDark),
              _buildSectionText(
                "Your privacy is important to us when using the Englitics application. This document explains the data we collect, use, and share.",
                isDark,
              ),
              _buildSectionTitle("Data We Collect", isDark),
              _buildSectionText(
                "Our application collects the following data to provide you with a better language learning experience:",
                isDark,
              ),
              _buildBulletPoint(
                  "Account information (email, username)", isDark),
              _buildBulletPoint("Learning statistics and progress", isDark),
              _buildBulletPoint("Usage data and interactions", isDark),
              _buildBulletPoint("Device information", isDark),
              _buildSectionTitle("Use of Data", isDark),
              _buildSectionText(
                "We use the data we collect for the following purposes:",
                isDark,
              ),
              _buildBulletPoint("Personalized learning experience", isDark),
              _buildBulletPoint("Improving application performance", isDark),
              _buildBulletPoint("Developing new features", isDark),
              _buildBulletPoint("User support", isDark),
              _buildSectionTitle("Cookies and Tracking Technologies", isDark),
              _buildSectionText(
                "Our application may use cookies and similar tracking technologies to enhance user experience.",
                isDark,
              ),
              _buildSectionTitle("Advertising and Analytics", isDark),
              _buildSectionText(
                "We display advertisements to provide you with a better experience and to finance our services. We use third-party advertising providers such as Google AdMob. These providers may use cookies to serve you ads based on your interests.",
                isDark,
              ),
              _buildSectionTitle("Data Security", isDark),
              _buildSectionText(
                "We take reasonable security measures to protect your personal data, but no electronic transmission or storage method is 100% secure.",
                isDark,
              ),
              _buildSectionTitle("Data Sharing", isDark),
              _buildSectionText(
                "We may share your data with third parties in the following circumstances:",
                isDark,
              ),
              _buildBulletPoint(
                  "With our service providers (servers, analytics, advertising)",
                  isDark),
              _buildBulletPoint("When legally required", isDark),
              _buildBulletPoint(
                  "In case of a business merger or acquisition", isDark),
              _buildSectionTitle("User Rights", isDark),
              _buildSectionText(
                "All users have rights regarding their personal data, including:",
                isDark,
              ),
              _buildBulletPoint("The right to access their data", isDark),
              _buildBulletPoint("The right to correct inaccurate data", isDark),
              _buildBulletPoint("The right to deletion of their data", isDark),
              _buildBulletPoint(
                  "The right to restrict or object to certain processing",
                  isDark),
              _buildSectionTitle("Policy Changes", isDark),
              _buildSectionText(
                "We may update this privacy policy from time to time. We will notify you when significant changes occur.",
                isDark,
              ),
              _buildSectionTitle("Contact", isDark),
              _buildSectionText(
                "If you have any questions about this privacy policy, please contact us at huseyintelli30@gmail.com",
                isDark,
              ),
              const SizedBox(height: 30),
              Text(
                "Last Updated: May 9, 2024",
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
