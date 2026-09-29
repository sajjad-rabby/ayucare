import 'package:flutter/material.dart';
import '../../configuration/app_config.dart';
import '../../theme/ayu_theme.dart';
import 'legal_screen.dart';
import 'reminders_screen.dart';
import 'todo_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.mode, required this.onMode});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onMode;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('More')),
        body: ListView(
          padding: const EdgeInsets.all(AyuSpacing.m),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AyuSpacing.m),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/brand/ayucare_logo.jpg',
                          width: 52,
                          height: 52,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.spa, size: 40)),
                    ),
                    const SizedBox(width: AyuSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppConfig.appName,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                              'Health & Ayurveda reference · v${AppConfig.version}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AyuSpacing.s),
            _row(context, 'Theme', Icons.dark_mode_outlined,
                trailing: DropdownButton<ThemeMode>(
                  value: mode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                        value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(
                        value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(
                        value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (v) {
                    if (v != null) onMode(v);
                  },
                )),
            _row(context, 'About AyuCare', Icons.info_outline,
                page: const AboutPage()),
            _row(context, 'Daily Reminders', Icons.notifications_outlined,
                page: const RemindersScreen()),
            _row(context, 'Todo Lists', Icons.checklist_outlined,
                page: const TodoListsScreen()),
            _row(
                context, 'Medical Disclaimer', Icons.health_and_safety_outlined,
                page: const DisclaimerPage()),
            _row(context, 'Privacy Policy', Icons.privacy_tip_outlined,
                page: const PrivacyPage()),
            _row(context, 'Terms of Use', Icons.description_outlined,
                page: const TermsPage()),
            _row(context, 'Affiliate Disclosure', Icons.storefront_outlined,
                page: const AffiliatePage()),
            _row(context, 'Contact', Icons.mail_outline,
                page: const ContactPage()),
          ],
        ),
      );

  Widget _row(BuildContext context, String title, IconData icon,
          {Widget? page, Widget? trailing}) =>
      Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: trailing ?? const Icon(Icons.chevron_right),
          onTap: page == null
              ? null
              : () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => page)),
        ),
      );
}
