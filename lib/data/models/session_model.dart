import 'dart:convert';

import 'package:vidian_stream/domain/entities/session.dart';

/// Model que representa la sesión en la capa de datos.
/// Se encarga de serializar/deserializar a JSON/Map para persistencia (SharedPreferences/Hive).
class SessionModel {
  final String type; // 'demo' | 'classic' | 'xtream'
  final String? token;
  final String? m3uUrl;
  final DateTime createdAt;

  SessionModel({
    required this.type,
    this.token,
    this.m3uUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Session toEntity() => Session(
        type: type,
        token: token,
        m3uUrl: m3uUrl,
        createdAt: createdAt,
      );

  factory SessionModel.fromEntity(Session s) => SessionModel(
        type: s.type,
        token: s.token,
        m3uUrl: s.m3uUrl,
        createdAt: s.createdAt,
      );

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'token': token,
      'm3uUrl': m3uUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      type: map['type'] as String,
      token: map['token'] as String?,
      m3uUrl: map['m3uUrl'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SessionModel.fromJson(String source) => SessionModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  SessionModel copyWith({
    String? type,
    String? token,
    String? m3uUrl,
    DateTime? createdAt,
  }) {
    return SessionModel(
      type: type ?? this.type,
      token: token ?? this.token,
      m3uUrl: m3uUrl ?? this.m3uUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'SessionModel(type: $type, token: $token, m3uUrl: $m3uUrl, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionModel &&
        other.type == type &&
        other.token == token &&
        other.m3uUrl == m3uUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => type.hashCode ^ (token?.hashCode ?? 0) ^ (m3uUrl?.hashCode ?? 0) ^ createdAt.hashCode;
}