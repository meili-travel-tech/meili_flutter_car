import 'dart:convert';

import 'package:meili_flutter_example/meili_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [MeiliSettings] in `SharedPreferences` as a single JSON blob.
///
/// A [SharedPreferences] instance is injected so the repository stays a thin,
/// testable wrapper (MVVM data layer, per the project's architecture skill).
class SettingsRepository {
  /// Creates a repository backed by an already-loaded `SharedPreferences`.
  SettingsRepository(this._prefs);

  static const String _key = 'meili.sample.settings';

  final SharedPreferences _prefs;

  /// Reads the saved settings, falling back to defaults when absent/invalid.
  MeiliSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      return const MeiliSettings();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return MeiliSettings.fromJson(json);
    } on FormatException {
      return const MeiliSettings();
    }
  }

  /// Persists [settings].
  Future<void> save(MeiliSettings settings) {
    return _prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
