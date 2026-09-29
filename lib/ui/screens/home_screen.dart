import 'package:flutter/material.dart';
import '../../configuration/app_config.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import '../widgets/ayu_widgets.dart';
import 'az_screen.dart';
import 'legal_screen.dart';
import 'search_screen.dart';

final _topics = [
  (
    'Digestive Health',
    Icons.restaurant_outlined,
    ['Constipation', 'Gastritis', 'Ulcerative Colitis']
  ),
  (
    'Skin Health',
    Icons.spa_outlined,
    ['Acne', 'Eczema', 'Psoriasis', 'Ringworm', 'Vitiligo', 'Xeroderma']
  ),
  (
    'Respiratory Health',
    Icons.air_outlined,
    [
      'Bronchitis',
      'Influenza',
      'Laryngitis',
      'Sinusitis',
      'Tonsillitis',
      'Whooping Cough'
    ]
  ),
  (
    'Brain & Nervous System',
    Icons.psychology_outlined,
    ['Headache', 'Migraine', 'Neuropathy']
  ),
  (
    'Heart & Circulation',
    Icons.favorite_outline,
    ['Osteoarthritis', 'Dengue', 'Yellow Fever', 'Zika', 'Q Fever', 'Jaundice']
  ),
  ('Everyday Conditions', Icons.wb_sunny_outlined, ['Fever', 'Kidney Stones']),
  ('Mental Wellbeing', Icons.self_improvement_outlined, []),
  ("Women's Health", Icons.pregnant_woman_outlined, []),
  ("Men's Health", Icons.man_outlined, []),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
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
                      fit: BoxFit.cover,
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
                      'Explore health conditions, symptoms & herbal knowledge.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AyuSpacing.m),
                  _SearchField(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SearchScreen(open: true)))),
                  const SizedBox(height: AyuSpacing.m),
                  const SafetyNotice(
                    title: 'AyuCare Safety Notice',
                    body:
                        '${DisclaimerConfig.homeNotice} Tap below for the full disclaimer.',
                    level: NoticeLevel.info,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const DisclaimerPage())),
                    child: const Text('Read Full Disclaimer'),
                  ),
                  Text('A–Z Explorer',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AyuSpacing.s),
                  const AzGrid(),
                  const SizedBox(height: AyuSpacing.m),
                  Text('Explore by Health Topic',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AyuSpacing.s),
                  for (final t in _topics)
                    _TopicCard(
                        title: t.$1,
                        icon: t.$2,
                        count: repo.conditions
                            .where((c) =>
                                List<String>.from(t.$3).contains(c.name))
                            .length),
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

class _TopicCard extends StatelessWidget {
  const _TopicCard(
      {required this.title, required this.icon, required this.count});
  final String title;
  final IconData icon;
  final int count;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: AyuColors.antiqueGold),
          title: Text(title),
          subtitle: Text(count == 0
              ? 'Growing library — more topics soon'
              : '$count condition${count == 1 ? '' : 's'}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      );
}
