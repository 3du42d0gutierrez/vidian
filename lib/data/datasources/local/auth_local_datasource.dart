import 'package:vidian_stream/domain/entities/session.dart';

/// Interface for local session storage (SharedPreferences, Hive, etc).
abstract class AuthLocalDataSource {
  Future<void> saveSession(Session session);
  Future<Session?> getSession();
  Future<void> clearSession();
}