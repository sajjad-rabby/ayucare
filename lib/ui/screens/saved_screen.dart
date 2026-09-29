import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/saved_repository.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import 'condition_screen.dart';
import 'herb_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  Set<String> _conds = {};
  Set<String> _herbs = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    final s = SavedRepository(p);
    setState(() {
      _conds = s.conditions;
      _herbs = s.herbs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    final conds = repo.conditions.where((c) => _conds.contains(c.id)).toList();
    final herbs = repo.herbs.where((h) => _herbs.contains(h.id)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: conds.isEmpty && herbs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nothing saved yet. Open any condition or herb and tap the bookmark icon.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
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
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (_) => ConditionScreen(id: c.id)))
                              .then((_) => _refresh()),
                        ),
                      ),
                    const SizedBox(height: AyuSpacing.m),
                  ],
                  if (herbs.isNotEmpty) ...[
                    Text('Herbs',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AyuSpacing.s),
                    for (final h in herbs)
                      Card(
                        child: ListTile(
                          title: Text(h.name),
                          subtitle: Text(h.scientific),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (_) => HerbScreen(id: h.id)))
                              .then((_) => _refresh()),
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
