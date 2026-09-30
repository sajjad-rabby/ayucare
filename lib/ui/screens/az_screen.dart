import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import 'condition_screen.dart';

class AzScreen extends StatelessWidget {
  const AzScreen({super.key, this.push = false});
  final bool push;
  @override
  Widget build(BuildContext context) {
    final body = const WheelExplorer();
    if (!push) {
      return Scaffold(
          appBar: AppBar(title: const Text('Explore A–Z')), body: body);
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Diseases & Treatment')), body: body);
  }
}

/// Glossy rolling letter wheel. The centered letter is the selection;
/// tapping it (or Open) goes to that letter's conditions.
class WheelExplorer extends StatefulWidget {
  const WheelExplorer({super.key});
  @override
  State<WheelExplorer> createState() => _WheelExplorerState();
}

class _WheelExplorerState extends State<WheelExplorer> {
  late final FixedExtentScrollController _ctrl;
  int _sel = 0;
  bool _navigating = false; // guards double-push from tap + button races

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open(String letter) {
    if (_navigating) return;
    _navigating = true;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LetterScreen(letter: letter)))
        .then((_) {
      _navigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    final letters = repo.letters;
    return Column(
      children: [
        const SizedBox(height: AyuSpacing.m),
        Text('Roll to a letter',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AyuSpacing.s),
        Expanded(
          child: Stack(
            children: [
              ListWheelScrollView.useDelegate(
                controller: _ctrl,
                itemExtent: 64,
                diameterRatio: 1.6,
                perspective: 0.004,
                useMagnifier: true,
                magnification: 1.25,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) {
                  // Highlight follows the wheel; navigation ONLY on tap/Open.
                  // (Auto-push on settle caused double pages — removed.)
                  if (mounted) setState(() => _sel = i);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: letters.length,
                  builder: (context, i) {
                    final active = i == _sel;
                    final n = repo.byLetter(letters[i]).length;
                    return GestureDetector(
                      onTap: () => _open(letters[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 64, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AyuRadius.m),
                          gradient: active
                              ? LinearGradient(colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.75),
                                ])
                              : null,
                          color: active
                              ? null
                              : Theme.of(context)
                                  .cardTheme
                                  .color
                                  ?.withValues(alpha: 0.6),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: active ? 0.9 : 0.25)),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6))
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${letters[i]}${n > 0 ? '  ·  $n' : ''}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: active
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                          semanticsLabel:
                              'Letter ${letters[i]}, $n conditions. Tap to open.',
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Glossy sheen overlays (non-interactive)
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.85),
                        Colors.transparent,
                        Colors.transparent,
                        Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AyuSpacing.m),
          child: FilledButton(
            onPressed: () => _open(letters[_sel]),
            child: Text('Open ${letters[_sel]}'),
          ),
        ),
      ],
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
