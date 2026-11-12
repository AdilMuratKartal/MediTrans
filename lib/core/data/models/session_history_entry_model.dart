import 'session_category_model.dart';

class SessionHistoryEntry {
  final String id;
  final String userId;
  final SessionCategory category;
  final String itemId;
  final String titleTr;
  final int completedSeconds;
  final DateTime completedAt;
  final bool isSynced;

  const SessionHistoryEntry({
    required this.id,
    this.userId = 'local_user',
    required this.category,
    required this.itemId,
    required this.titleTr,
    required this.completedSeconds,
    required this.completedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson({String? overrideUserId}) => {
    'id': id,
    'userId': overrideUserId ?? userId,
    'category': category.name,
    'categoryLabelTr': category.labelTr,
    'itemId': itemId,
    'titleTr': titleTr,
    'completedSeconds': completedSeconds,
    'completedAt': completedAt.toIso8601String(),
    'isSynced': isSynced,
  };

  factory SessionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SessionHistoryEntry(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? 'local_user',
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

