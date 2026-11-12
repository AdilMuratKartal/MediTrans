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

  Map<String, dynamic> toJson({String? overrideUserId}) {
    final resolvedUid = overrideUserId ?? uid;
    return {
      'uid': resolvedUid,
      'userId': resolvedUid,
      'displayName': displayName,
      'email': email,
      'levelTitleTr': levelTitleTr,
      'ageYears': ageYears,
      'weightKg': weightKg,
      'habitsTr': habitsTr,
      'dailyReminderTime': dailyReminderTime,
      'notificationsEnabled': notificationsEnabled,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Builds the relational document payload for the `weekly_habits` top-level collection
  /// containing `userId` as foreign key back to `users/{userId}`.
  Map<String, dynamic> toWeeklyHabitsPayload({String? overrideUserId}) {
    final resolvedUid = overrideUserId ?? uid;
    final nowIso = DateTime.now().toIso8601String();
    return {
      'id': 'habits_$resolvedUid',
      'userId': resolvedUid,
      'userEmail': email,
      'displayName': displayName,
      'habitsTr': habitsTr,
      'habitItems': List.generate(habitsTr.length, (index) {
        return {
          'id': '${resolvedUid}_habit_${index + 1}',
          'userId': resolvedUid,
          'orderIndex': index + 1,
          'title': habitsTr[index],
          'dailyReminderTime': dailyReminderTime,
          'isActive': true,
        };
      }),
      'dailyReminderTime': dailyReminderTime,
      'notificationsEnabled': notificationsEnabled,
      'updatedAt': nowIso,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: (json['userId'] ?? json['uid']) as String? ?? 'local_user',
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

