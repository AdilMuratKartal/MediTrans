class SyncOutboxItem {
  final int id;
  final String entityType; // 'mood', 'mood_chart', 'last_played', 'weekly_habits', 'session', 'profile', 'favorite'
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

