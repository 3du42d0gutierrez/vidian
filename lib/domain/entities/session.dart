import 'dart:convert';

class Session {
  final String type; // 'demo' | 'classic' | 'xtream'
  final String? token;
  final String? m3uUrl;
  final DateTime createdAt;

  Session({
    required this.type,
    this.token,
    this.m3uUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Factory para sesión demo (acceso rápido y limitado)
  factory Session.demo() => Session(
        type: 'demo',
        token: 'demo-token',
        m3uUrl: null,
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'token': token,
        'm3uUrl': m3uUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        type: json['type'] as String,
        token: json['token'] as String?,
        m3uUrl: json['m3uUrl'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      );

  String encode() => jsonEncode(toJson());

  static Session? tryDecode(String? jsonStr) {
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Session.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}