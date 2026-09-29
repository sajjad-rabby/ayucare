import 'package:flutter/material.dart';
import '../../configuration/app_config.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import '../widgets/ayu_widgets.dart';
import 'condition_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.open = false});
  final bool open;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(AyuSpacing.m),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              autofocus: widget.open,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search conditions, symptoms or herbs…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(999))),
              ),
            ),
            const SizedBox(height: AyuSpacing.s),
            const SafetyNotice(
              title: 'Symptom Search Is Not a Diagnosis',
              body: DisclaimerConfig.searchNotice,
              level: NoticeLevel.info,
            ),
            const SizedBox(height: AyuSpacing.s),
            Expanded(child: _results(context, repo)),
          ],
        ),
      ),
    );
  }

  Widget _results(BuildContext context, repo) {
    final q = _ctrl.text.trim();
    if (q.length < 3) {
      return const Center(child: Text('Type at least 3 letters to explore.'));
    }
    final hits = repo.search(q);
    if (hits.isEmpty) {
      return const Center(
          child: Text(
              'No educational matches found. Try another spelling or keyword.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Educational matches — not diagnosis results',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AyuSpacing.s),
        Expanded(
          child: ListView.separated(
            itemCount: hits.length,
            separatorBuilder: (_, __) => const SizedBox(height: AyuSpacing.s),
            itemBuilder: (context, i) {
              final c = hits[i];
              return Card(
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.short,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ConditionScreen(id: c.id))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
