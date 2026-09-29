import 'package:flutter/material.dart';
import '../../theme/ayu_theme.dart';

/// Three-level safety hierarchy: info / safety / urgent.
enum NoticeLevel { info, safety, urgent }

class SafetyNotice extends StatelessWidget {
  const SafetyNotice({
    super.key,
    required this.title,
    required this.body,
    this.level = NoticeLevel.safety,
  });

  final String title, body;
  final NoticeLevel level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color accent;
    final IconData icon;
    switch (level) {
      case NoticeLevel.info:
        accent = scheme.secondary;
        icon = Icons.info_outline;
        break;
      case NoticeLevel.safety:
        accent = AyuColors.primaryGreen;
        icon = Icons.health_and_safety_outlined;
        break;
      case NoticeLevel.urgent:
        accent = scheme.error;
        icon = Icons.warning_amber_rounded;
        break;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: AyuSpacing.s),
      color: Theme.of(context).brightness == Brightness.dark
          ? null
          : accent.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AyuRadius.m),
        side: BorderSide(color: accent.withValues(alpha: 0.55), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AyuSpacing.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, semanticLabel: title),
            const SizedBox(width: AyuSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: accent)),
                  const SizedBox(height: AyuSpacing.xs),
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AyuSpacing.s),
    child: Padding(
          padding: const EdgeInsets.all(AyuSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: AyuSpacing.s),
                  ],
                  Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleMedium,
                        semanticsLabel: title),
                  ),
                ],
              ),
              const SizedBox(height: AyuSpacing.s),
              child,
            ],
          ),
        ),
      );
}

/// Constrains reading width on tablets/landscape; full-bleed on phones.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => c.maxWidth <= 760
        ? child
        : Center(child: SizedBox(width: 720, child: child)),
  );
}

class BulletList extends StatelessWidget {
  const BulletList({super.key, required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AyuSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(
                      child: Text(it,
                          style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      );
}
