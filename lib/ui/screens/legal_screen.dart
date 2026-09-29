import 'package:flutter/material.dart';
import '../../configuration/app_config.dart';
import '../../theme/ayu_theme.dart';

class _LegalShell extends StatelessWidget {
  const _LegalShell({required this.title, required this.body});
  final String title, body;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.all(AyuSpacing.m),
          children: [Text(body)],
        ),
      );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => _LegalShell(
      title: 'About AyuCare',
      body:
          'AyuCare is an educational health and Ayurveda reference. Browse conditions A–Z, '
          'search symptoms and herbs, read traditional and evidence information with sources, '
          'and save items for later — all offline.\n\nVersion ${AppConfig.version} · '
          'Content v${AppConfig.contentVersion}\n${DisclaimerConfig.friendlyLine}');
}

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});
  @override
  Widget build(BuildContext context) => const _LegalShell(
      title: 'Medical Disclaimer', body: DisclaimerConfig.globalDisclaimer);
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) => const _LegalShell(
      title: 'Privacy Policy',
      body:
          'AyuCare collects as little personal data as possible. Browsing, search, and '
          'bookmarks work without an account and stay on your device. No medical history, '
          'diagnoses, or precise location are collected in this version. External retailer '
          'links open outside the app and are governed by those sites’ policies. '
          'Contact: ${AppConfig.contactEmail}');
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});
  @override
  Widget build(BuildContext context) => const _LegalShell(
      title: 'Terms of Use',
      body:
          'AyuCare content is educational and reference-only. By using the app you agree '
          'not to treat it as medical advice, diagnosis, or prescription. Do not stop '
          'prescribed treatment based on app content. External links are provided for '
          'information; availability and pricing may vary by region.');
}

class AffiliatePage extends StatelessWidget {
  const AffiliatePage({super.key});
  @override
  Widget build(BuildContext context) => _LegalShell(
      title: 'Affiliate Disclosure',
      body: '${DisclaimerConfig.affiliateDisclosure}\n\nAffiliate commerce is '
          '${FeatureFlags.affiliateEnabled ? 'enabled' : 'currently disabled'} in this version. '
          'Product listings, where shown, are informational and never medical recommendations.');
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) => _LegalShell(
      title: 'Contact',
      body:
          'Questions, corrections, or source suggestions: ${AppConfig.contactEmail}\n\n'
          'Content feedback helps the editorial review cycle.');
}
