// Canonical Domain Models for MediTrans (strictly matching `data_referance.md`).

enum MoodValence {
  mutlu('mutlu', '😊', 'Mutlu', 5),
  sakin('sakin', '😌', 'Sakin', 4),
  notr('notr', '😐', 'Nötr', 3),
  endisel('endisel', '😟', 'Endişeli', 2),
  uzgun('uzgun', '😔', 'Üzgün', 2),
  yorgun('yorgun', '😴', 'Yorgun', 2),
  stresli('stresli', '😣', 'Stresli', 1);

  final String code;
  final String emoji;
  final String labelTr;
  final int score;
  const MoodValence(this.code, this.emoji, this.labelTr, this.score);

  static MoodValence fromCode(String code) {
    return MoodValence.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MoodValence.sakin,
    );
  }
}

enum SessionCategory {
  breathwork,
  yogaPose,
  frequency,
  natureSound,
  noiseSound,
  sleepStory,
}

class MoodOption {
  final String code;
  final String emoji;
  final String label;
  final int score;

  const MoodOption({
    required this.code,
    required this.emoji,
    required this.label,
    required this.score,
  });
}

class MoodEntry {
  final String id;
  final String dateKey; // YYYY-MM-DD
  final DateTime loggedAt;
  final List<String> moodCodes; // e.g. ['mutlu', 'sakin']
  final int averageScore;
  final String? reflectionNote;
  final bool isSynced;

  const MoodEntry({
    required this.id,
    required this.dateKey,
    required this.loggedAt,
    required this.moodCodes,
    required this.averageScore,
    this.reflectionNote,
    this.isSynced = false,
  });

  MoodEntry copyWith({
    String? id,
    String? dateKey,
    DateTime? loggedAt,
    List<String>? moodCodes,
    int? averageScore,
    String? reflectionNote,
    bool? isSynced,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      loggedAt: loggedAt ?? this.loggedAt,
      moodCodes: moodCodes ?? this.moodCodes,
      averageScore: averageScore ?? this.averageScore,
      reflectionNote: reflectionNote ?? this.reflectionNote,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateKey': dateKey,
    'loggedAt': loggedAt.toIso8601String(),
    'moodCodes': moodCodes,
    'averageScore': averageScore,
    'reflectionNote': reflectionNote,
    'isSynced': isSynced,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String? ?? '',
      dateKey: json['dateKey'] as String? ?? '',
      loggedAt:
          DateTime.tryParse(json['loggedAt'] as String? ?? '') ??
          DateTime.now(),
      moodCodes:
          (json['moodCodes'] as List<dynamic>?)?.map((e) => '$e').toList() ??
          const ['sakin'],
      averageScore: (json['averageScore'] as num?)?.toInt() ?? 4,
      reflectionNote: json['reflectionNote'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}

class BreathCadence {
  final String id;
  final String titleTr;
  final String subtitleTr;
  final int inhaleSec;
  final int holdSec;
  final int exhaleSec;
  final List<int> durationMinutesOptions;
  final String localAudioAsset;
  final String remoteStoragePath;
  final String backgroundAsset;

  const BreathCadence({
    required this.id,
    required this.titleTr,
    required this.subtitleTr,
    required this.inhaleSec,
    required this.holdSec,
    required this.exhaleSec,
    this.durationMinutesOptions = const [5, 10, 15],
    required this.localAudioAsset,
    required this.remoteStoragePath,
    required this.backgroundAsset,
  });

  int get cycleSeconds => inhaleSec + holdSec + exhaleSec;
}

class YogaPoseItem {
  final int orderIndex; // 1..8
  final String id;
  final String sanskritName;
  final String turkishName;
  final String subtitleTr;
  final String levelBadgeTr;
  final int recommendedSeconds;
  final List<int> durationPresetsSec;
  final String illustrationAsset;
  final List<String> stepInstructionsTr;
  final List<String> benefitBadgesTr;

  const YogaPoseItem({
    required this.orderIndex,
    required this.id,
    required this.sanskritName,
    required this.turkishName,
    required this.subtitleTr,
    required this.levelBadgeTr,
    this.recommendedSeconds = 60,
    this.durationPresetsSec = const [10, 20, 30, 60, 90],
    required this.illustrationAsset,
    required this.stepInstructionsTr,
    required this.benefitBadgesTr,
  });
}

class FrequencyTrack {
  final String id;
  final String codeLabel; // '432 Hz', '7.83 Hz', '528 Hz', '999'
  final double frequencyValue;
  final bool isAngelSequence;
  final String titleTr;
  final String chakraOrThemeTr;
  final String descriptionTr;
  final String backgroundAsset;
  final int styleIndex; // 0..8 for visual slice & color theme
  final String localAudioAsset;
  final String remoteAudioStoragePath;
  final int defaultDurationSeconds;

  const FrequencyTrack({
    required this.id,
    required this.codeLabel,
    required this.frequencyValue,
    this.isAngelSequence = false,
    required this.titleTr,
    required this.chakraOrThemeTr,
    required this.descriptionTr,
    required this.backgroundAsset,
    required this.styleIndex,
    required this.localAudioAsset,
    required this.remoteAudioStoragePath,
    this.defaultDurationSeconds = 900,
  });
}

class SleepMediaTrack {
  final String id;
  final SessionCategory category;
  final String titleTr;
  final String subtitleTr;
  final String backgroundAsset;
  final String localAudioAsset;
  final String remoteStoragePath;
  final String? storyTextAsset;
  final int durationSeconds;

  const SleepMediaTrack({
    required this.id,
    required this.category,
    required this.titleTr,
    required this.subtitleTr,
    required this.backgroundAsset,
    required this.localAudioAsset,
    required this.remoteStoragePath,
    this.storyTextAsset,
    required this.durationSeconds,
  });
}

class UserProfileModel {
  final String uid;
  final String displayName;
  final String? email;
  final String levelTitleTr;
  final int ageYears;
  final double weightKg;
  final List<String> habitsTr;
  final String dailyReminderTime; // "21:30"
  final bool notificationsEnabled;

  const UserProfileModel({
    required this.uid,
    required this.displayName,
    this.email,
    this.levelTitleTr = 'Mindful Gezgin • Seviye 3',
    required this.ageYears,
    required this.weightKg,
    required this.habitsTr,
    this.dailyReminderTime = '21:30',
    this.notificationsEnabled = true,
  });

  UserProfileModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? levelTitleTr,
    int? ageYears,
    double? weightKg,
    List<String>? habitsTr,
    String? dailyReminderTime,
    bool? notificationsEnabled,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      levelTitleTr: levelTitleTr ?? this.levelTitleTr,
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      habitsTr: habitsTr ?? this.habitsTr,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'levelTitleTr': levelTitleTr,
    'ageYears': ageYears,
    'weightKg': weightKg,
    'habitsTr': habitsTr,
    'dailyReminderTime': dailyReminderTime,
    'notificationsEnabled': notificationsEnabled,
  };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String? ?? 'local_user',
      displayName: json['displayName'] as String? ?? 'Adil Murat',
      email: json['email'] as String?,
      levelTitleTr:
          json['levelTitleTr'] as String? ?? 'Mindful Gezgin • Seviye 3',
      ageYears: (json['ageYears'] as num?)?.toInt() ?? 28,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 74.0,
      habitsTr:
          (json['habitsTr'] as List<dynamic>?)?.map((e) => '$e').toList() ??
          const ['Sabah Nefesi', 'Su Tüketimi', 'Gece Okuması'],
      dailyReminderTime: json['dailyReminderTime'] as String? ?? '21:30',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }
}

class SessionHistoryEntry {
  final String id;
  final SessionCategory category;
  final String itemId;
  final String titleTr;
  final int completedSeconds;
  final DateTime completedAt;
  final bool isSynced;

  const SessionHistoryEntry({
    required this.id,
    required this.category,
    required this.itemId,
    required this.titleTr,
    required this.completedSeconds,
    required this.completedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'itemId': itemId,
    'titleTr': titleTr,
    'completedSeconds': completedSeconds,
    'completedAt': completedAt.toIso8601String(),
    'isSynced': isSynced,
  };

  factory SessionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SessionHistoryEntry(
      id: json['id'] as String? ?? '',
      category: SessionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => SessionCategory.frequency,
      ),
      itemId: json['itemId'] as String? ?? '',
      titleTr: json['titleTr'] as String? ?? '',
      completedSeconds: (json['completedSeconds'] as num?)?.toInt() ?? 60,
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}

class SyncOutboxItem {
  final int id;
  final String entityType; // 'mood', 'session', 'profile', 'favorite'
  final String entityId;
  final String operation; // 'UPSERT', 'DELETE'
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const SyncOutboxItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType,
    'entityId': entityId,
    'operation': operation,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SyncOutboxItem.fromJson(Map<String, dynamic> json) {
    return SyncOutboxItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      entityType: json['entityType'] as String? ?? 'mood',
      entityId: json['entityId'] as String? ?? '',
      operation: json['operation'] as String? ?? 'UPSERT',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Unified playable item for `GlobalAudioController` and `UniversalPlayerBar`.
class PlayableTrack {
  final String id;
  final String title;
  final String subtitle;
  final SessionCategory category;
  final String localAudioAsset;
  final String remoteStoragePath;
  final String backgroundAsset;
  final int durationSeconds;
  final double? frequencyHz;

  const PlayableTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.localAudioAsset,
    required this.remoteStoragePath,
    required this.backgroundAsset,
    required this.durationSeconds,
    this.frequencyHz,
  });
}
