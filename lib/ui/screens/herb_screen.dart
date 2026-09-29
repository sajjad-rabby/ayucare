import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../configuration/app_config.dart';
import '../../data/saved_repository.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import '../widgets/ayu_widgets.dart';
import 'condition_screen.dart';

class HerbScreen extends StatefulWidget {
  const HerbScreen({super.key, required this.id});
  final String id;
  @override
  State<HerbScreen> createState() => _HerbScreenState();
}

class _HerbScreenState extends State<HerbScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        _saved = SavedRepository(p).herbs.contains(widget.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    final h = repo.herbById(widget.id);
    if (h == null) {
      return Scaffold(
          appBar: AppBar(), body: const Center(child: Text('Not available.')));
    }
    final related =
        repo.conditions.where((c) => c.herbIds.contains(h.id)).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(h.name),
        actions: [
          IconButton(
            icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_outline),
            tooltip: _saved ? 'Remove bookmark' : 'Save',
            onPressed: () async {
              final p = await SharedPreferences.getInstance();
              await SavedRepository(p).toggleHerb(h.id);
              if (!mounted) return;
              setState(() => _saved = !_saved);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AyuSpacing.m),
        children: [
          Text(h.scientific,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: AyuSpacing.xs),
          Text('Also known as: ${h.alt}'),
          const SizedBox(height: AyuSpacing.s),
          const SafetyNotice(
            title: 'Herbal Safety Notice',
            body: DisclaimerConfig.herbNotice,
            level: NoticeLevel.safety,
          ),
          SectionCard(title: 'Overview', child: Text(h.desc)),
          SectionCard(title: 'Traditional context', child: Text(h.traditional)),
          SectionCard(
            title: 'Research summary',
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
                  child: Text('Evidence status: ${h.evidence}'),
                ),
                const SizedBox(height: AyuSpacing.s),
                Text(h.research),
              ],
            ),
          ),
          SectionCard(
            title: 'Safety',
            icon: Icons.shield_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.safety),
                const SizedBox(height: AyuSpacing.s),
                Text('Avoid when: ${h.contra.join('; ')}'),
                const SizedBox(height: AyuSpacing.s),
                Text('Interactions: ${h.interactions}'),
                const SizedBox(height: AyuSpacing.s),
                Text('Pregnancy: ${h.pregnancy}'),
                const SizedBox(height: AyuSpacing.s),
                Text('Children: ${h.children}'),
                const SizedBox(height: AyuSpacing.s),
                Text('Common forms: ${h.forms}'),
              ],
            ),
          ),
          if (related.isNotEmpty)
            SectionCard(
              title: 'Related conditions',
              child: Column(
                children: [
                  for (final c in related)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ConditionScreen(id: c.id))),
                    ),
                ],
              ),
            ),
          Text('Last reviewed: ${h.reviewed}',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
