import 'package:vidian_stream/domain/entities/session.dart';

/// Interface for remote authentication (Xtream, clásico, etc).
abstract class AuthRemoteDataSource {
  Future<Session> loginXtream(String url, String user, String pass);
  Future<Session> loginClassic(String user, String pass);
}