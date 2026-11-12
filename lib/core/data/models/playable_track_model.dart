import 'session_category_model.dart';

/// Unified playable item for `GlobalAudioController`, `UniversalPlayerBar`,
/// LocalStore persistence, and Firestore `last_played_tracks` collection synchronization.
class PlayableTrack {
  final String id;
  final String userId;
  final String title;
  final String subtitle;
  final SessionCategory category;
  final String localAudioAsset;
  final String remoteStoragePath;
  final String backgroundAsset;
  final int durationSeconds;
  final double? frequencyHz;
  final int lastPositionSeconds;
  final DateTime? updatedAt;

  const PlayableTrack({
    required this.id,
    this.userId = 'local_user',
    required this.title,
    required this.subtitle,
    required this.category,
    required this.localAudioAsset,
    required this.remoteStoragePath,
    required this.backgroundAsset,
    required this.durationSeconds,
    this.frequencyHz,
    this.lastPositionSeconds = 0,
    this.updatedAt,
  });

  String get categoryLabelTr => category.labelTr;

  PlayableTrack copyWith({
    String? id,
    String? userId,
    String? title,
    String? subtitle,
    SessionCategory? category,
    String? localAudioAsset,
    String? remoteStoragePath,
    String? backgroundAsset,
    int? durationSeconds,
    double? frequencyHz,
    int? lastPositionSeconds,
    DateTime? updatedAt,
  }) {
    return PlayableTrack(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      localAudioAsset: localAudioAsset ?? this.localAudioAsset,
      remoteStoragePath: remoteStoragePath ?? this.remoteStoragePath,
      backgroundAsset: backgroundAsset ?? this.backgroundAsset,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      lastPositionSeconds: lastPositionSeconds ?? this.lastPositionSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson({String? overrideUserId}) {
    final resolvedUid = overrideUserId ?? userId;
    final nowIso = (updatedAt ?? DateTime.now()).toIso8601String();
    return {
      'id': id,
      'trackId': id,
      'userId': resolvedUid,
      'title': title,
      'subtitle': subtitle,
      'category': category.name,
      'categoryLabelTr': category.labelTr,
      'localAudioAsset': localAudioAsset,
      'remoteStoragePath': remoteStoragePath,
      'backgroundAsset': backgroundAsset,
      'durationSeconds': durationSeconds,
      'frequencyHz': frequencyHz,
      'lastPositionSeconds': lastPositionSeconds,
      'updatedAt': nowIso,
      'metadata': {
        'id': id,
        'userId': resolvedUid,
        'title': title,
        'subtitle': subtitle,
        'category': category.name,
        'categoryLabelTr': category.labelTr,
        'localAudioAsset': localAudioAsset,
        'remoteStoragePath': remoteStoragePath,
        'backgroundAsset': backgroundAsset,
        'durationSeconds': durationSeconds,
        'frequencyHz': frequencyHz,
        'lastPositionSeconds': lastPositionSeconds,
        'updatedAt': nowIso,
      },
    };
  }

  factory PlayableTrack.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : <String, dynamic>{};
    final catName =
        (json['category'] ?? meta['category']) as String? ?? 'frequency';
    final category = SessionCategory.values.firstWhere(
      (c) => c.name == catName,
      orElse: () => SessionCategory.frequency,
    );
    return PlayableTrack(
      id: (json['trackId'] ?? json['id'] ?? meta['id']) as String? ?? 'hz_432',
      userId: (json['userId'] ?? meta['userId']) as String? ?? 'local_user',
      title:
          (json['title'] ?? meta['title']) as String? ??
          '432 Hz • Evrensel Uyum',
      subtitle:
          (json['subtitle'] ?? meta['subtitle']) as String? ??
          'Kalp & Zihin Dengesi • Doğal Frekans',
      category: category,
      localAudioAsset:
          (json['localAudioAsset'] ?? meta['localAudioAsset']) as String? ??
          'assets/audio/frequencies/hz_432.wav',
      remoteStoragePath:
          (json['remoteStoragePath'] ?? meta['remoteStoragePath']) as String? ??
          'frequencies/hz_432.wav',
      backgroundAsset:
          (json['backgroundAsset'] ?? meta['backgroundAsset']) as String? ??
          'assets/images/backgrounds/hz_styles_sheet.jpg',
      durationSeconds:
          ((json['durationSeconds'] ?? meta['durationSeconds']) as num?)
              ?.toInt() ??
          900,
      frequencyHz: ((json['frequencyHz'] ?? meta['frequencyHz']) as num?)
          ?.toDouble(),
      lastPositionSeconds:
          ((json['lastPositionSeconds'] ?? meta['lastPositionSeconds']) as num?)
              ?.toInt() ??
          0,
      updatedAt: DateTime.tryParse(
        (json['updatedAt'] ?? meta['updatedAt']) as String? ?? '',
      ),
    );
  }
}

