import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'seed_catalog.dart';

/// Drift SQLite / WASM Database Engine (`meditrans_local_db`) executing canonical DDL
/// from `data_referance.md` without requiring fragile external code generation.
class MediTransDriftDb extends GeneratedDatabase {
  MediTransDriftDb([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'meditrans_local_db',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await customStatement('''
            CREATE TABLE IF NOT EXISTS mood_logs (
              id TEXT PRIMARY KEY,
              date_key TEXT NOT NULL,
              logged_at INTEGER NOT NULL,
              mood_codes_json TEXT NOT NULL,
              average_score INTEGER NOT NULL,
              reflection_note TEXT,
              is_synced INTEGER NOT NULL DEFAULT 0
            )
          ''');
      await customStatement('''
            CREATE TABLE IF NOT EXISTS session_history (
              id TEXT PRIMARY KEY,
              category TEXT NOT NULL,
              item_id TEXT NOT NULL,
              title_tr TEXT NOT NULL,
              completed_seconds INTEGER NOT NULL,
              completed_at INTEGER NOT NULL,
              is_synced INTEGER NOT NULL DEFAULT 0
            )
          ''');
      await customStatement('''
            CREATE TABLE IF NOT EXISTS user_profile (
              uid TEXT PRIMARY KEY,
              display_name TEXT NOT NULL,
              email TEXT,
              level_title_tr TEXT NOT NULL,
              age_years INTEGER NOT NULL,
              weight_kg REAL NOT NULL,
              habits_json TEXT NOT NULL,
              daily_reminder_time TEXT NOT NULL,
              notifications_enabled INTEGER NOT NULL DEFAULT 1
            )
          ''');
      await customStatement('''
            CREATE TABLE IF NOT EXISTS cached_media (
              media_id TEXT PRIMARY KEY,
              bucket_name TEXT NOT NULL,
              remote_path TEXT NOT NULL,
              local_file_path TEXT NOT NULL,
              byte_size INTEGER NOT NULL,
              last_accessed_at INTEGER NOT NULL
            )
          ''');
      await customStatement('''
            CREATE TABLE IF NOT EXISTS sync_outbox (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              entity_type TEXT NOT NULL,
              entity_id TEXT NOT NULL,
              operation TEXT NOT NULL,
              payload_json TEXT NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');
    },
  );
}

/// Offline-First Local Store combining Drift SQLite/WASM and SharedPreferences
/// fast runtime state (`data_referance.md` Sections 3 & 4).
class LocalStore extends ChangeNotifier {
  static const String _kMoodLogsKey = 'aura.mood_logs.v1';
  static const String _kProfileKey = 'aura.user_profile.v1';
  static const String _kSessionHistoryKey = 'aura.session_history.v1';
  static const String _kFavoritesKey = 'aura.favorites.v1';
  static const String _kOutboxKey = 'aura.sync_outbox.v1';
  static const String _kBellEnabledKey = 'aura.yoga.bell_enabled';
  static const String _kLastFreqIdKey = 'aura.audio.last_track_id';

  SharedPreferences? _prefs;
  MediTransDriftDb? _driftDb;
  bool _driftReady = false;

  UserProfileModel _profile = const UserProfileModel(
    uid: 'local_user',
    displayName: 'Adil Murat',
    email: 'adil.murat@meditrans.app',
    levelTitleTr: 'Mindful Gezgin • Seviye 3',
    ageYears: 28,
    weightKg: 74.0,
    habitsTr: ['Sabah Nefesi', 'Su Tüketimi', 'Gece Okuması'],
    dailyReminderTime: '21:30',
    notificationsEnabled: true,
  );

  final Map<String, MoodEntry> _moodsByDate = {};
  final List<SessionHistoryEntry> _sessions = [];
  final Set<String> _favoriteIds = {'hz_432', 'hz_528', 'story_1'};
  final List<SyncOutboxItem> _outbox = [];
  bool _yogaBellEnabled = true;
  String _lastPlayedTrackId = 'hz_432';

  UserProfileModel get profile => _profile;
  List<SessionHistoryEntry> get sessions => List.unmodifiable(_sessions);
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  List<SyncOutboxItem> get outbox => List.unmodifiable(_outbox);
  bool get yogaBellEnabled => _yogaBellEnabled;
  String get lastPlayedTrackId => _lastPlayedTrackId;
  bool get isDriftActive => _driftReady;

  Future<void> initialize() async {
    _buildDefaultWeekSeed();
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadFromPrefs();
    } catch (_) {}

    // Initialize Drift SQLite/WASM in background-safe try block
    if (!kIsWeb) {
      try {
        _driftDb = MediTransDriftDb();
        await _driftDb!.customSelect('SELECT 1').get();
        _driftReady = true;
      } catch (_) {
        _driftReady = false;
      }
    }
    notifyListeners();
  }

  void _buildDefaultWeekSeed() {
    final now = DateTime.now();
    // Monday = 1 .. Sunday = 7
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sampleMoods = <int, List<String>>{
      0: ['mutlu', 'sakin'],
      1: ['sakin', 'odakli'],
      2: ['notr', 'yorgun'],
      3: ['mutlu', 'huzurlu'],
      4: ['mutlu', 'sakin'],
      5: ['enerjik', 'mutlu'],
      6: ['huzurlu', 'minnettar'],
    };
    final sampleNotes = <int, String>{
      0: 'Haftaya 432 Hz frekansı ve derin nefesle dengeli başladım.',
      1: 'Sasangasana pratiği sırtımdaki gerginliği çok iyi rahatlattı.',
      2: 'Yoğun bir gündü, akşam Gece Yağmuru sesiyle dinlendim.',
      3: 'Zihnim berrak ve odaklanmış hissediyor.',
      4: 'Bugün içsel dinginliğim oldukça yüksek.',
    };

    for (var i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final key = formatDateKey(d);
      final codes = sampleMoods[i] ?? ['sakin'];
      final avg = _computeAverageScore(codes);
      _moodsByDate[key] = MoodEntry(
        id: 'seed_$key',
        dateKey: key,
        loggedAt: d,
        moodCodes: codes,
        averageScore: avg,
        reflectionNote: sampleNotes[i],
        isSynced: true,
      );
    }
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;

    final rawProfile = prefs.getString(_kProfileKey);
    if (rawProfile != null) {
      try {
        _profile = UserProfileModel.fromJson(
          jsonDecode(rawProfile) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    final rawMoods = prefs.getString(_kMoodLogsKey);
    if (rawMoods != null) {
      try {
        final list = jsonDecode(rawMoods) as List<dynamic>;
        for (final item in list) {
          final entry = MoodEntry.fromJson(item as Map<String, dynamic>);
          if (entry.dateKey.isNotEmpty) {
            _moodsByDate[entry.dateKey] = entry;
          }
        }
      } catch (_) {}
    }

    final rawSessions = prefs.getString(_kSessionHistoryKey);
    if (rawSessions != null) {
      try {
        final list = jsonDecode(rawSessions) as List<dynamic>;
        _sessions
          ..clear()
          ..addAll(
            list.map(
              (e) => SessionHistoryEntry.fromJson(e as Map<String, dynamic>),
            ),
          );
      } catch (_) {}
    }

    final favList = prefs.getStringList(_kFavoritesKey);
    if (favList != null) {
      _favoriteIds
        ..clear()
        ..addAll(favList);
    }

    final rawOutbox = prefs.getString(_kOutboxKey);
    if (rawOutbox != null) {
      try {
        final list = jsonDecode(rawOutbox) as List<dynamic>;
        _outbox
          ..clear()
          ..addAll(
            list.map((e) => SyncOutboxItem.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {}
    }

    _yogaBellEnabled = prefs.getBool(_kBellEnabledKey) ?? true;
    _lastPlayedTrackId = prefs.getString(_kLastFreqIdKey) ?? 'hz_432';
  }

  static String formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  int _computeAverageScore(List<String> codes) {
    if (codes.isEmpty) return 3;
    var sum = 0;
    for (final c in codes) {
      sum += SeedCatalog.findMood(c).score;
    }
    return (sum / codes.length).round().clamp(1, 5);
  }

  MoodEntry getMoodForDate(DateTime date) {
    final key = formatDateKey(date);
    return _moodsByDate[key] ??
        MoodEntry(
          id: 'mood_$key',
          dateKey: key,
          loggedAt: date,
          moodCodes: const ['mutlu', 'sakin'],
          averageScore: 5,
        );
  }

  /// Returns 7 days (Monday -> Sunday) of the current week for the Home strip & Profile chart.
  List<MoodEntry> getCurrentWeekMoods() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final d = monday.add(Duration(days: index));
      return getMoodForDate(d);
    });
  }

  Future<void> addMoodTagForDate(DateTime date, String moodCode) async {
    final current = getMoodForDate(date);
    final updatedCodes = List<String>.from(current.moodCodes);
    if (!updatedCodes.contains(moodCode)) {
      updatedCodes.add(moodCode);
    }
    await _saveMoodEntry(
      current.copyWith(
        moodCodes: updatedCodes,
        averageScore: _computeAverageScore(updatedCodes),
        loggedAt: DateTime.now(),
        isSynced: false,
      ),
    );
  }

  Future<void> removeMoodTagForDate(DateTime date, String moodCode) async {
    final current = getMoodForDate(date);
    if (current.moodCodes.length <= 1) return;
    final updatedCodes = List<String>.from(current.moodCodes)..remove(moodCode);
    await _saveMoodEntry(
      current.copyWith(
        moodCodes: updatedCodes,
        averageScore: _computeAverageScore(updatedCodes),
        loggedAt: DateTime.now(),
        isSynced: false,
      ),
    );
  }

  Future<void> saveReflectionNoteForDate(DateTime date, String note) async {
    final current = getMoodForDate(date);
    await _saveMoodEntry(
      current.copyWith(
        reflectionNote: note.trim(),
        loggedAt: DateTime.now(),
        isSynced: false,
      ),
    );
  }

  Future<void> _saveMoodEntry(MoodEntry entry) async {
    _moodsByDate[entry.dateKey] = entry;
    _enqueueOutbox(
      entityType: 'mood',
      entityId: entry.id,
      operation: 'UPSERT',
      payload: entry.toJson(),
    );
    await _persistMoods();

    if (_driftReady && _driftDb != null) {
      try {
        await _driftDb!.customStatement(
          '''
          INSERT OR REPLACE INTO mood_logs
          (id, date_key, logged_at, mood_codes_json, average_score, reflection_note, is_synced)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            entry.id,
            entry.dateKey,
            entry.loggedAt.millisecondsSinceEpoch,
            jsonEncode(entry.moodCodes),
            entry.averageScore,
            entry.reflectionNote,
            entry.isSynced ? 1 : 0,
          ],
        );
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> recordCompletedSession({
    required SessionCategory category,
    required String itemId,
    required String titleTr,
    required int completedSeconds,
  }) async {
    final entry = SessionHistoryEntry(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      itemId: itemId,
      titleTr: titleTr,
      completedSeconds: completedSeconds,
      completedAt: DateTime.now(),
      isSynced: false,
    );
    _sessions.insert(0, entry);
    _enqueueOutbox(
      entityType: 'session',
      entityId: entry.id,
      operation: 'UPSERT',
      payload: entry.toJson(),
    );
    await _prefs?.setString(
      _kSessionHistoryKey,
      jsonEncode(_sessions.take(50).map((e) => e.toJson()).toList()),
    );
    if (_driftReady && _driftDb != null) {
      try {
        await _driftDb!.customStatement(
          '''
          INSERT OR REPLACE INTO session_history
          (id, category, item_id, title_tr, completed_seconds, completed_at, is_synced)
          VALUES (?, ?, ?, ?, ?, ?, 0)
          ''',
          [
            entry.id,
            entry.category.name,
            entry.itemId,
            entry.titleTr,
            entry.completedSeconds,
            entry.completedAt.millisecondsSinceEpoch,
          ],
        );
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> updateProfile(UserProfileModel updated) async {
    _profile = updated;
    _enqueueOutbox(
      entityType: 'profile',
      entityId: updated.uid,
      operation: 'UPSERT',
      payload: updated.toJson(),
    );
    await _prefs?.setString(_kProfileKey, jsonEncode(updated.toJson()));
    if (_driftReady && _driftDb != null) {
      try {
        await _driftDb!.customStatement(
          '''
          INSERT OR REPLACE INTO user_profile
          (uid, display_name, email, level_title_tr, age_years, weight_kg, habits_json, daily_reminder_time, notifications_enabled)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            updated.uid,
            updated.displayName,
            updated.email,
            updated.levelTitleTr,
            updated.ageYears,
            updated.weightKg,
            jsonEncode(updated.habitsTr),
            updated.dailyReminderTime,
            updated.notificationsEnabled ? 1 : 0,
          ],
        );
      } catch (_) {}
    }
    notifyListeners();
  }

  bool isFavorite(String itemId) => _favoriteIds.contains(itemId);

  Future<void> toggleFavorite(String itemId) async {
    final added = !_favoriteIds.contains(itemId);
    if (added) {
      _favoriteIds.add(itemId);
    } else {
      _favoriteIds.remove(itemId);
    }
    _enqueueOutbox(
      entityType: 'favorite',
      entityId: itemId,
      operation: added ? 'UPSERT' : 'DELETE',
      payload: {
        'itemId': itemId,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
    await _prefs?.setStringList(_kFavoritesKey, _favoriteIds.toList());
    notifyListeners();
  }

  Future<void> setYogaBellEnabled(bool enabled) async {
    _yogaBellEnabled = enabled;
    await _prefs?.setBool(_kBellEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setLastPlayedTrackId(String trackId) async {
    _lastPlayedTrackId = trackId;
    await _prefs?.setString(_kLastFreqIdKey, trackId);
  }

  void _enqueueOutbox({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) {
    final item = SyncOutboxItem(
      id: DateTime.now().microsecondsSinceEpoch,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      createdAt: DateTime.now(),
    );
    _outbox.add(item);
    _prefs?.setString(
      _kOutboxKey,
      jsonEncode(_outbox.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> markOutboxItemsFlushed(List<int> ids) async {
    _outbox.removeWhere((item) => ids.contains(item.id));
    await _prefs?.setString(
      _kOutboxKey,
      jsonEncode(_outbox.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> _persistMoods() async {
    await _prefs?.setString(
      _kMoodLogsKey,
      jsonEncode(_moodsByDate.values.map((e) => e.toJson()).toList()),
    );
  }
}
