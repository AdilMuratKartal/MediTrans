class MoodEntry {
  final String id;
  final String userId;
  final String dateKey; // YYYY-MM-DD
  final DateTime loggedAt;
  final List<String> moodCodes; // e.g. ['mutlu', 'sakin']
  final int averageScore;
  final String? reflectionNote;
  final bool isSynced;

  const MoodEntry({
    required this.id,
    this.userId = 'local_user',
    required this.dateKey,
    required this.loggedAt,
    required this.moodCodes,
    required this.averageScore,
    this.reflectionNote,
    this.isSynced = false,
  });

  MoodEntry copyWith({
    String? id,
    String? userId,
    String? dateKey,
    DateTime? loggedAt,
    List<String>? moodCodes,
    int? averageScore,
    String? reflectionNote,
    bool? isSynced,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateKey: dateKey ?? this.dateKey,
      loggedAt: loggedAt ?? this.loggedAt,
      moodCodes: moodCodes ?? this.moodCodes,
      averageScore: averageScore ?? this.averageScore,
      reflectionNote: reflectionNote ?? this.reflectionNote,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson({String? overrideUserId}) => {
    'id': id,
    'userId': overrideUserId ?? userId,
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
      userId: json['userId'] as String? ?? 'local_user',
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

