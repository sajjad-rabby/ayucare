import 'package:flutter/material.dart';
import '../configuration/app_config.dart';
import '../data/content_repository.dart';
import '../services/reminder_service.dart';
import '../theme/ayu_theme.dart';
import 'ui/screens/az_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/more_screen.dart';
import 'ui/screens/saved_screen.dart';
import 'ui/screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = ContentRepository();
  await repo.load();
  try {
    await ReminderService.init();
  } catch (_) {
    // Reminders are best-effort (permissions/OEM quirks) — app works without.
  }
  runApp(AyuCareApp(repo: repo));
}

class Scope extends InheritedWidget {
  const Scope({super.key, required this.repo, required super.child});
  final ContentRepository repo;
  static ContentRepository of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<Scope>()!.repo;
  @override
  bool updateShouldNotify(Scope old) => false;
}

class AyuCareApp extends StatefulWidget {
  const AyuCareApp({super.key, required this.repo});
  final ContentRepository repo;
  @override
  State<AyuCareApp> createState() => _AyuCareAppState();
}

class _AyuCareAppState extends State<AyuCareApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) => Scope(
        repo: widget.repo,
        child: MaterialApp(
          title: AppConfig.appName,
          theme: ayuLightTheme(),
          darkTheme: ayuDarkTheme(),
          themeMode: _mode,
          home: RootShell(
            mode: _mode,
            onMode: (m) => setState(() => _mode = m),
          ),
        ),
      );
}

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.mode, required this.onMode});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onMode;
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const AzScreen(),
      const SearchScreen(),
      // Fresh key per visit: Saved always reloads (instant bookmark feedback).
      SavedScreen(key: ValueKey('saved-$_i')),
      MoreScreen(mode: widget.mode, onMode: widget.onMode),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Explore'),
          NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search'),
          NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Saved'),
          NavigationDestination(
              icon: Icon(Icons.menu_outlined),
              selectedIcon: Icon(Icons.menu),
              label: 'More'),
        ],
      ),
    );
  }
}
