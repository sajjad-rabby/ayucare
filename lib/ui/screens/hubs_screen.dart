import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../theme/ayu_theme.dart';
import '../widgets/ayu_widgets.dart';
import 'herb_screen.dart';

Future<void> openExternal(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  var ok = false;
  if (uri != null && await canLaunchUrl(uri)) {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Opening external page…'
          : 'External link unavailable right now.')));
}

// ---------- Skin Health reads (verified reputable links) ----------
const _skinReads = [
  (
    'Acne: causes and care',
    'American Academy of Dermatology',
    'https://www.aad.org/public/diseases/acne'
  ),
  (
    'Eczema resource center',
    'American Academy of Dermatology',
    'https://www.aad.org/public/diseases/eczema'
  ),
  (
    'Psoriasis resource center',
    'American Academy of Dermatology',
    'https://www.aad.org/public/diseases/psoriasis'
  ),
  (
    'Skin care basics',
    'American Academy of Dermatology',
    'https://www.aad.org/public/everyday-care/skin-care-basics'
  ),
  ('Acne guide', 'NHS', 'https://www.nhs.uk/conditions/acne/'),
  ('Eczema guide', 'NHS', 'https://www.nhs.uk/conditions/atopic-eczema/'),
  ('Psoriasis guide', 'NHS', 'https://www.nhs.uk/conditions/psoriasis/'),
  ('Acne overview', 'MedlinePlus', 'https://medlineplus.gov/acne.html'),
  ('Eczema overview', 'MedlinePlus', 'https://medlineplus.gov/eczema.html'),
  (
    'Psoriasis overview',
    'MedlinePlus',
    'https://medlineplus.gov/psoriasis.html'
  ),
];

class SkinReadsScreen extends StatelessWidget {
  const SkinReadsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Skin Health Reads')),
        body: ListView.separated(
          padding: const EdgeInsets.all(AyuSpacing.m),
          itemCount: _skinReads.length,
          separatorBuilder: (_, __) => const SizedBox(height: AyuSpacing.s),
          itemBuilder: (context, i) {
            final r = _skinReads[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  child: Text('${i + 1}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ),
                title: Text(r.$1),
                subtitle: Text('${r.$2} · External article'),
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () => openExternal(context, r.$3),
              ),
            );
          },
        ),
      );
}

// ---------- Exercises (interactive) ----------
class _Exercise {
  const _Exercise(this.name, this.desc, this.steps, this.kind);
  final String name, desc;
  final List<String> steps;
  final String kind; // counter | timer | guide
}

const _exercises = [
  _Exercise(
      'Morning Walk',
      '20–30 minutes of brisk walking most days.',
      [
        'Warm up 3 minutes at easy pace',
        'Walk briskly 20 minutes',
        'Cool down 3 minutes, gentle stretch'
      ],
      'guide'),
  _Exercise(
      'Surya Namaskar Flow',
      'Traditional sun-salutation sequence for flexibility.',
      [
        'Stand tall, palms together',
        'Raise arms, gentle backbend',
        'Fold forward, hands to floor',
        'Step back to plank, lower slowly',
        'Cobra pose, breathe',
        'Downward dog, hold 5 breaths',
        'Step forward, rise up'
      ],
      'counter'),
  _Exercise(
      'Anulom Vilom Breathing',
      'Alternate-nostril breathing for calm focus.',
      [
        'Sit comfortably, spine tall',
        'Close right nostril, inhale left 4 counts',
        'Close left, exhale right 4 counts',
        'Repeat 5 rounds'
      ],
      'timer'),
  _Exercise(
      'Bhujangasana (Cobra)',
      'Gentle backbend for spine mobility.',
      [
        'Lie face down, palms under shoulders',
        'Inhale, lift chest slowly',
        'Hold 15–30 seconds, breathe',
        'Lower down, repeat 3 times'
      ],
      'counter'),
  _Exercise(
      'Tadasana (Mountain Pose)',
      'Posture and balance foundation.',
      [
        'Stand tall, feet together',
        'Engage thighs, lift chest',
        'Arms alongside, breathe 1 minute'
      ],
      'timer'),
  _Exercise(
      'Chair Squats',
      'Leg strength without equipment.',
      [
        'Stand before a sturdy chair',
        'Lower until just touching seat',
        'Stand up, repeat 8–12 times',
        'Rest, 2 rounds'
      ],
      'counter'),
  _Exercise(
      'Neck & Shoulder Rolls',
      'Release desk tension.',
      [
        'Slow circles, 5 each direction',
        'Ear to shoulder hold 15 seconds each side',
        'Shoulder shrugs 10 times'
      ],
      'guide'),
  _Exercise(
      'Evening Stretch',
      '10-minute wind-down routine.',
      [
        'Cat-cow 1 minute',
        'Child pose 1 minute',
        'Seated twist each side',
        'Legs-up-wall 3 minutes'
      ],
      'timer'),
];

class ExerciseHubScreen extends StatelessWidget {
  const ExerciseHubScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Everyday Exercises')),
        body: ListView.separated(
          padding: const EdgeInsets.all(AyuSpacing.m),
          itemCount: _exercises.length,
          separatorBuilder: (_, __) => const SizedBox(height: AyuSpacing.s),
          itemBuilder: (context, i) => _ExerciseCard(ex: _exercises[i]),
        ),
      );
}

class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({required this.ex});
  final _Exercise ex;
  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _open = false;
  int _count = 0;
  int _secs = 60;
  Timer? _timer;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secs <= 0) {
          t.cancel();
          setState(() => _running = false);
        } else {
          setState(() => _secs--);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AyuSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.fitness_center_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AyuSpacing.s),
                  Expanded(
                      child: Text(widget.ex.name,
                          style: Theme.of(context).textTheme.titleMedium)),
                  IconButton(
                    icon: Icon(_open ? Icons.expand_less : Icons.expand_more),
                    tooltip: _open ? 'Collapse' : 'Expand steps',
                    onPressed: () => setState(() => _open = !_open),
                  ),
                ],
              ),
              Text(widget.ex.desc),
              if (_open) ...[
                const SizedBox(height: AyuSpacing.s),
                for (var i = 0; i < widget.ex.steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${i + 1}. ${widget.ex.steps[i]}'),
                  ),
                const SizedBox(height: AyuSpacing.s),
                if (widget.ex.kind == 'counter')
                  Row(
                    children: [
                      FilledButton.tonal(
                          onPressed: () => setState(() => _count++),
                          child: const Text('Count rep')),
                      const SizedBox(width: AyuSpacing.s),
                      Text('$_count reps',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton(
                          onPressed: () => setState(() => _count = 0),
                          child: const Text('Reset')),
                    ],
                  ),
                if (widget.ex.kind == 'timer')
                  Row(
                    children: [
                      FilledButton.tonal(
                          onPressed: _toggleTimer,
                          child: Text(_running ? 'Pause' : 'Start timer')),
                      const SizedBox(width: AyuSpacing.s),
                      Text('$_secs s',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
              ],
            ],
          ),
        ),
      );
}

// ---------- Pregnancy: Gentle Beginnings ----------
const _pregnancyTips = [
  (
    'Eat rainbow plates',
    'Fruits, vegetables, lentils, whole grains and dairy or alternatives daily; small frequent meals ease nausea.'
  ),
  (
    'Folic acid matters',
    'Ask your clinician about folic acid before and during early pregnancy.'
  ),
  (
    'Rest without guilt',
    'Short naps and early nights support recovery; avoid heavy lifting.'
  ),
  (
    'Stay hydrated',
    'Water through the day; limit excess caffeine after clinician advice.'
  ),
  (
    'Keep every checkup',
    'Regular antenatal visits catch issues early — never skip them.'
  ),
  (
    'Know red flags',
    'Bleeding, severe headache, vision changes, reduced fetal movement, or fluid leakage need urgent care.'
  ),
  (
    'Gentle movement',
    'Short walks and clinician-approved stretches; stop if dizzy or in pain.'
  ),
  (
    'Medicines need review',
    'No herbal or over-the-counter product without clinician approval.'
  ),
  (
    'Avoid risky foods',
    'Unpasteurized items, raw preparations, and alcohol are best avoided — confirm with your clinician.'
  ),
  (
    'Prepare support',
    'Line up family help and transport for appointments and delivery week.'
  ),
];

class PregnancyHubScreen extends StatelessWidget {
  const PregnancyHubScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Gentle Beginnings')),
        body: ListView(
          padding: const EdgeInsets.all(AyuSpacing.m),
          children: [
            const SafetyNotice(
              title: 'Care with your clinician',
              body:
                  'Pregnancy care is personal. Use these tips alongside your doctor or midwife — not instead of them.',
              level: NoticeLevel.safety,
            ),
            const SizedBox(height: AyuSpacing.s),
            for (var i = 0; i < _pregnancyTips.length; i++)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AyuColors.antiqueGold.withValues(alpha: 0.18),
                    child: Text('${i + 1}',
                        style: const TextStyle(color: AyuColors.antiqueGold)),
                  ),
                  title: Text(_pregnancyTips[i].$1),
                  subtitle: Text(_pregnancyTips[i].$2),
                ),
              ),
          ],
        ),
      );
}

// ---------- Mental health: Calm Mind ----------
const _mentalTips = [
  (
    'Sleep anchors mood',
    'Same bedtime daily; screens off 30 minutes before sleep.'
  ),
  (
    'Breathe for 2 minutes',
    'Slow inhales, longer exhales — try it before stressful moments.'
  ),
  (
    'Move a little daily',
    'A 15-minute walk lifts mood more reliably than scrolling.'
  ),
  ('Sunlight early', 'Morning daylight steadies sleep and energy.'),
  ('Write it out', 'Three lines in a journal untangle looping thoughts.'),
  ('One small win', 'Finish one tiny task fully; momentum follows.'),
  (
    'Connect weekly',
    'Call one person who steadies you — connection protects mood.'
  ),
  (
    'Limit doomscrolling',
    'Set app timers; replace 20 minutes with tea and air.'
  ),
  (
    'Ask early for help',
    'Persistent low mood, anxiety, or hopelessness deserve professional support.'
  ),
  (
    'Crisis lines exist',
    'If you may act on harmful thoughts, seek emergency help or a crisis helpline immediately.'
  ),
];

class MentalHubScreen extends StatelessWidget {
  const MentalHubScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Calm Mind, Every Day')),
        body: ListView(
          padding: const EdgeInsets.all(AyuSpacing.m),
          children: [
            const SafetyNotice(
              title: 'Seek professional support',
              body:
                  'Tips support everyday wellbeing; they never replace professional care. If you struggle, reach a counselor, doctor, or crisis helpline promptly.',
              level: NoticeLevel.urgent,
            ),
            const SizedBox(height: AyuSpacing.s),
            for (var i = 0; i < _mentalTips.length; i++)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.self_improvement_outlined),
                  title: Text(_mentalTips[i].$1),
                  subtitle: Text(_mentalTips[i].$2),
                ),
              ),
          ],
        ),
      );
}

// ---------- Everyday herbs ----------
class EverydayHerbsScreen extends StatelessWidget {
  const EverydayHerbsScreen({super.key});
  static const _ids = ['tulsi', 'ginger', 'amla', 'turmeric', 'honey'];
  @override
  Widget build(BuildContext context) {
    final repo = Scope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Everyday Herbs')),
      body: ListView(
        padding: const EdgeInsets.all(AyuSpacing.m),
        children: [
          const SafetyNotice(
            title: 'Gentle daily use',
            body:
                'These kitchen herbs suit everyday food and tea routines for most people. Concentrated supplements, pregnancy, medicines, and illness change the equation — check with a clinician.',
            level: NoticeLevel.info,
          ),
          const SizedBox(height: AyuSpacing.s),
          for (final id in _ids)
            Builder(builder: (context) {
              final h = repo.herbById(id);
              if (h == null) return const SizedBox.shrink();
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.eco_outlined),
                  title: Text(h.name),
                  subtitle: Text(h.desc,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => HerbScreen(id: h.id))),
                ),
              );
            }),
        ],
      ),
    );
  }
}
