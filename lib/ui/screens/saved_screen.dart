import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/saved_repository.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import 'condition_screen.dart';
import 'herb_screen.dart';

/// Reloads on every build, so bookmarks toggle instantly everywhere
/// (parent tab switches rebuild this page).
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  Future<(Set<String>, Set<String>)> _load() async {
    final p = await SharedPreferences.getInstance();
    final s = SavedRepository(p);
    return (s.conditions, s.herbs);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: FutureBuilder<(Set<String>, Set<String>)>(
        future: _load(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    semanticsLabel: 'Loading saved items'));
          }
          final conds = repo.conditions
              .where((c) => snap.data!.$1.contains(c.id))
              .toList();
          final herbs =
              repo.herbs.where((h) => snap.data!.$2.contains(h.id)).toList();
          if (conds.isEmpty && herbs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nothing saved yet. Open any condition or herb and tap the bookmark icon — it saves instantly.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(AyuSpacing.m),
              children: [
                if (conds.isNotEmpty) ...[
                  Text('Conditions',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AyuSpacing.s),
                  for (final c in conds)
                    Card(
                      child: ListTile(
                        title: Text(c.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              tooltip: 'Remove bookmark',
                              onPressed: () async {
                                final p = await SharedPreferences.getInstance();
                                await SavedRepository(p).toggleCondition(c.id);
                                if (mounted) setState(() {});
                              },
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => ConditionScreen(id: c.id))),
                      ),
                    ),
                  const SizedBox(height: AyuSpacing.m),
                ],
                if (herbs.isNotEmpty) ...[
                  Text('Herbs', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AyuSpacing.s),
                  for (final h in herbs)
                    Card(
                      child: ListTile(
                        title: Text(h.name),
                        subtitle: Text(h.scientific),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              tooltip: 'Remove bookmark',
                              onPressed: () async {
                                final p = await SharedPreferences.getInstance();
                                await SavedRepository(p).toggleHerb(h.id);
                                if (mounted) setState(() {});
                              },
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => HerbScreen(id: h.id))),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
