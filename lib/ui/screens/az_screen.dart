import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import 'condition_screen.dart';

class AzScreen extends StatelessWidget {
  const AzScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Explore A–Z')),
        body: const Padding(
          padding: EdgeInsets.all(AyuSpacing.m),
          child: AzGrid(navigate: true),
        ),
      );
}

class AzGrid extends StatelessWidget {
  const AzGrid({super.key, this.navigate = false});
  final bool navigate;
  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: repo.letters.length,
      itemBuilder: (context, i) {
        final letter = repo.letters[i];
        final n = repo.byLetter(letter).length;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LetterScreen(letter: letter))),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(AyuRadius.s),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(letter,
                    style: Theme.of(context).textTheme.titleMedium,
                    semanticsLabel: 'Letter $letter, $n conditions'),
                if (n > 0)
                  Text('$n', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LetterScreen extends StatelessWidget {
  const LetterScreen({super.key, required this.letter});
  final String letter;
  @override
  Widget build(BuildContext context) {
    final items = Scope.of(context).byLetter(letter);
    return Scaffold(
      appBar: AppBar(title: Text('Conditions — $letter')),
      body: items.isEmpty
          ? const Center(child: Text('More conditions coming soon.'))
          : ListView.separated(
              padding: const EdgeInsets.all(AyuSpacing.m),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AyuSpacing.s),
              itemBuilder: (context, i) {
                final c = items[i];
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
    );
  }
}
