import 'package:shared_preferences/shared_preferences.dart';

/// Local bookmarks. No login required. Keys survive content updates
/// (stable condition/herb IDs — see content_version in meta.json).
class SavedRepository {
  SavedRepository(this._prefs);
  final SharedPreferences _prefs;
  static const _kConditions = 'saved.conditions.v1';
  static const _kHerbs = 'saved.herbs.v1';

  Set<String> get conditions =>
      Set.of(_prefs.getStringList(_kConditions) ?? []);
  Set<String> get herbs => Set.of(_prefs.getStringList(_kHerbs) ?? []);

  Future<void> toggleCondition(String id) async {
    final s = conditions;
    s.contains(id) ? s.remove(id) : s.add(id);
    await _prefs.setStringList(_kConditions, s.toList());
  }

  Future<void> toggleHerb(String id) async {
    final s = herbs;
    s.contains(id) ? s.remove(id) : s.add(id);
    await _prefs.setStringList(_kHerbs, s.toList());
  }
}
