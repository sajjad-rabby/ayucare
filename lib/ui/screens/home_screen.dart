import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import '../widgets/ayu_icons.dart';
import 'az_screen.dart';
import 'hubs_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    final skinCount =
        repo.conditions.where((c) => c.category == 'Skin Health').length;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/brand/ayucare_logo.jpg',
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.spa, size: 36)),
                ),
                const SizedBox(width: AyuSpacing.s),
                const Text('AyuCare'),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AyuSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Explore health knowledge. Discover nature\u2019s traditions.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AyuSpacing.m),
                  _SearchField(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SearchScreen(open: true)))),
                  const SizedBox(height: AyuSpacing.m),
                  _HubCard(
                    icon: Icons.medical_information_outlined,
                    title: 'Diseases & Treatment',
                    subtitle:
                        '${repo.conditions.length} conditions A–Z · educational reference',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AzScreen(push: true))),
                  ),
                  _HubCard(
                    icon: Icons.spa_outlined,
                    title: 'Skin Health',
                    subtitle: '$skinCount skin conditions · 10 in-app guides',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const SkinReadsScreen())),
                  ),
                  _HubCard(
                    icon: Icons.fitness_center_outlined,
                    title: 'Exercises',
                    subtitle: 'Guided routines with counters & timers',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ExerciseHubScreen())),
                  ),
                  _HubCard(
                    icon: Icons.pregnant_woman_outlined,
                    title: 'Gentle Beginnings',
                    subtitle:
                        'Pregnancy care tips that inform, never replace care',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const PregnancyHubScreen())),
                  ),
                  _HubCard(
                    icon: Icons.self_improvement_outlined,
                    glyph: const AyuGlyph.lotus(),
                    title: 'Mental Health',
                    subtitle: 'Everyday psychological tips + support paths',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MentalHubScreen())),
                  ),
                  _HubCard(
                    icon: Icons.eco_outlined,
                    glyph: const AyuGlyph.leaf(),
                    title: 'Everyday Herbs',
                    subtitle: 'Kitchen herbs for daily wellness routines',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const EverydayHerbsScreen())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AyuSpacing.m, vertical: AyuSpacing.m),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AyuRadius.pill),
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AyuSpacing.s),
              Expanded(
                child: Text('Search conditions, symptoms or herbs…',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).hintColor),
                    semanticsLabel: 'Search conditions, symptoms or herbs'),
              ),
            ],
          ),
        ),
      );
}

class _HubCard extends StatelessWidget {
  const _HubCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.glyph});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final Widget? glyph;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: AyuSpacing.s),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(AyuSpacing.s),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
                AyuColors.antiqueGold.withValues(alpha: 0.16),
              ]),
              borderRadius: BorderRadius.circular(AyuRadius.s),
            ),
            child: glyph ??
                Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
