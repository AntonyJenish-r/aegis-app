class AlertModel {
  final String id;
  final String userId;
  final String triggerType;
  final double aiScore;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final DateTime createdAt;
  final String status;
  final String? notes;

  AlertModel({
    required this.id,
    required this.userId,
    required this.triggerType,
    required this.aiScore,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    required this.createdAt,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'trigger_type': triggerType,
        'ai_score': aiScore,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy_meters': accuracyMeters,
        'created_at': createdAt.toIso8601String(),
        'status': status,
        'notes': notes,
      };

  factory AlertModel.fromMap(Map<String, dynamic> map) => AlertModel(
        id: map['id'] ?? '',
        userId: map['user_id'] ?? map['userId'] ?? '',
        triggerType: map['trigger_type'] ?? map['triggerType'] ?? 'UNKNOWN',
        aiScore: (map['ai_score'] as num?)?.toDouble() ?? 0,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        accuracyMeters: (map['accuracy_meters'] as num?)?.toDouble(),
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : DateTime.now(),
        status: map['status'] ?? 'PENDING',
        notes: map['notes'],
      );
}