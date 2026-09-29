import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../configuration/app_config.dart';
import '../../data/saved_repository.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import '../widgets/ayu_widgets.dart';
import 'herb_screen.dart';

/// Condition page order: identity+about → symptoms → warnings → care →
/// risk → herbal → diet → evidence → safety → products (+disclaimers).
class ConditionScreen extends StatefulWidget {
  const ConditionScreen({super.key, required this.id});
  final String id;
  @override
  State<ConditionScreen> createState() => _ConditionScreenState();
}

class _ConditionScreenState extends State<ConditionScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        _saved = SavedRepository(p).conditions.contains(widget.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    final c = repo.byId(widget.id);
    if (c == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Content not available.')),
      );
    }
    final herbs = c.herbIds.map(repo.herbById).whereType<dynamic>().toList();
    final products = repo.productsFor(c.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy summary',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(
                  text: '${c.name} — ${c.short}\nLearn about it in AyuCare.'));
              messenger.showSnackBar(
                  const SnackBar(content: Text('Summary copied.')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => SharePlus.instance.share(ShareParams(
                text: '${c.name} — ${c.short}\nLearn about it in AyuCare.',
                subject: c.name)),
          ),
          IconButton(
            icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_outline),
            tooltip: _saved ? 'Remove bookmark' : 'Save',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final p = await SharedPreferences.getInstance();
              await SavedRepository(p).toggleCondition(c.id);
              if (!mounted) return;
              setState(() => _saved = !_saved);
              messenger.showSnackBar(SnackBar(
                  content: Text(_saved ? 'Saved.' : 'Removed from saved.')));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AyuSpacing.m),
        children: [
          // Identity + about merged
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AyuSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TagChip(label: 'Selected Condition', primary: true),
                      const SizedBox(width: AyuSpacing.s),
                      _TagChip(label: c.categoryTag, primary: false),
                    ],
                  ),
                  const SizedBox(height: AyuSpacing.s),
                  Text(c.name, style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: AyuSpacing.xs),
                  Text(c.short),
                  const SizedBox(height: AyuSpacing.s),
                  Text(c.overview),
                  const SizedBox(height: AyuSpacing.xs),
                  Text('Last reviewed: ${c.reviewed} · v${c.version}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: AyuSpacing.s),
          const SafetyNotice(
            title: 'Important Health Notice',
            body: DisclaimerConfig.conditionNotice,
            level: NoticeLevel.safety,
          ),
          SectionCard(
              title: 'Common symptoms',
              icon: Icons.list_outlined,
              child: BulletList(items: c.symptoms)),
          if (c.lessCommon.isNotEmpty)
            SectionCard(
                title: 'Less common', child: BulletList(items: c.lessCommon)),
          SectionCard(
              title: 'Possible associated factors',
              child: BulletList(items: c.causes)),
          SafetyNotice(
            title: 'Urgent warning signs',
            body: c.redFlags.map((e) => '• $e').join('\n'),
            level: NoticeLevel.urgent,
          ),
          SectionCard(
              title: 'When to seek professional care',
              icon: Icons.medical_services_outlined,
              child: Text(c.care)),
          SectionCard(title: 'Risk factors', child: BulletList(items: c.risks)),
          // Herbal block directly under risk factors
          SectionCard(
            title: 'Traditional herbal & Ayurvedic information',
            icon: Icons.spa_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.ayurveda),
                const SizedBox(height: AyuSpacing.s),
                for (final h in herbs)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.eco_outlined),
                    title: Text(h.name as String),
                    subtitle: Text(
                        'Traditional use · evidence: ${h.evidence as String}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => HerbScreen(id: h.id as String))),
                  ),
              ],
            ),
          ),
          const SafetyNotice(
            title: 'Before Trying a Home Remedy',
            body: DisclaimerConfig.herbalNotice,
            level: NoticeLevel.safety,
          ),
          SectionCard(
            title: 'What to eat',
            icon: Icons.restaurant_outlined,
            child: BulletList(items: c.dietYes),
          ),
          SectionCard(
            title: 'What to avoid',
            icon: Icons.no_food_outlined,
            child: BulletList(items: c.dietNo),
          ),
          SectionCard(
            title: 'Evidence & research',
            icon: Icons.science_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AyuSpacing.s, vertical: 4),
                  decoration: BoxDecoration(
                    color: AyuColors.antiqueGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AyuRadius.pill),
                  ),
                  child: Text('Evidence status: ${c.evidence}',
                      style: Theme.of(context).textTheme.labelLarge),
                ),
                const SizedBox(height: AyuSpacing.s),
                Text(c.evidenceNote),
              ],
            ),
          ),
          SectionCard(
            title: 'Safety & cautions',
            icon: Icons.shield_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.safety),
                const SizedBox(height: AyuSpacing.s),
                Text('Avoid when: ${c.contra.join('; ')}'),
                const SizedBox(height: AyuSpacing.s),
                Text('Interactions: ${c.interactions}'),
                const SizedBox(height: AyuSpacing.s),
                Text('Pregnancy: ${c.pregnancy}'),
                const SizedBox(height: AyuSpacing.s),
                Text('Children: ${c.children}'),
                const SizedBox(height: AyuSpacing.s),
                Text('Older adults: ${c.elderly}'),
              ],
            ),
          ),
          if (products.isNotEmpty) ...[
            SectionCard(
              title: 'Related products',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: [
                  for (final p in products)
                    Card(
                      margin: const EdgeInsets.only(bottom: AyuSpacing.s),
                      child: ListTile(
                        title: Text(p.name),
                        subtitle: Text('${p.brand} · ${p.merchant}\n${p.desc}',
                            maxLines: 3, overflow: TextOverflow.ellipsis),
                        isThreeLine: true,
                        trailing: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new, size: 20),
                            Text('External', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        onTap: () => _openExternal(context, p.url, p.name),
                      ),
                    ),
                ],
              ),
            ),
            const SafetyNotice(
              title: 'Before You Purchase',
              body: DisclaimerConfig.productNotice,
              level: NoticeLevel.info,
            ),
            if (FeatureFlags.affiliateEnabled)
              const SafetyNotice(
                title: 'Affiliate Disclosure',
                body: DisclaimerConfig.affiliateDisclosure,
                level: NoticeLevel.info,
              ),
          ],
          // Proactive testing guidance — always after products, never before safety.
          SectionCard(
            title: 'Basic medical tests',
            icon: Icons.biotech_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Before seeing a doctor, these commonly used basic tests can '
                    'make your visit more productive. A clinician decides what you '
                    'actually need — this list is orientation, not an order.'),
                const SizedBox(height: AyuSpacing.s),
                BulletList(items: c.medicalTests),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternal(
      BuildContext context, String url, String label) async {
    var ok = false;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Opening external link: $label'
            : 'External link unavailable right now.')));
  }
}

/// Category tag chip. Colors distinguish the editorial category at a glance:
/// Treatable (green), Post-care (gold), Preventative (teal), Avoidable (grey).
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.primary});
  final String label;
  final bool primary;
  @override
  Widget build(BuildContext context) {
    final Color bg, fg;
    if (primary) {
      bg = Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
      fg = Theme.of(context).colorScheme.primary;
    } else {
      switch (label) {
        case 'Post-care':
          bg = AyuColors.antiqueGold.withValues(alpha: 0.20);
          fg = AyuColors.antiqueGold;
        case 'Preventative':
          bg = AyuColors.tealSage.withValues(alpha: 0.20);
          fg = AyuColors.tealSage;
        case 'Avoidable':
          bg = Colors.grey.withValues(alpha: 0.20);
          fg = Colors.grey.shade700;
        default:
          bg = AyuColors.primaryGreen.withValues(alpha: 0.12);
          fg = AyuColors.primaryGreen;
      }
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AyuSpacing.s, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AyuRadius.pill),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
          semanticsLabel: 'Category: $label'),
    );
  }
}
