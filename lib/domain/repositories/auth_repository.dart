import 'package:vidian_stream/domain/entities/session.dart';

abstract class AuthRepository {
  Future<Session> loginDemo();

  /// For M3U flow we use loginXtream with url (user/pass can be empty for plain M3U).
  Future<Session> loginXtream(String url, String user, String pass);

  Future<Session> loginClassic(String user, String pass);

  Future<void> logout();

  /// Devuelve la sesión guardada (o null).
  Future<Session?> getSavedSession();
}