import 'dart:math';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidian_stream/domain/entities/session.dart';
import 'package:vidian_stream/domain/repositories/auth_repository.dart';
import 'package:vidian_stream/core/utils/m3u_parser.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _kSession = 'session_v1';
  final SharedPreferences _prefs;
  final Dio _dio;

  AuthRepositoryImpl({required SharedPreferences prefs, Dio? dio})
      : _prefs = prefs,
        _dio = dio ?? Dio();

  @override
  Future<Session> loginDemo() async {
    final session = Session(type: 'demo', token: 'demo-${_randomToken()}');
    await _prefs.setString(_kSession, session.encode());
    return session;
  }

  @override
  Future<Session> loginClassic(String user, String pass) async {
    // Mock: acepta cualquier credencial no vacía. En integración real: llamar API y validar.
    if (user.isEmpty || pass.isEmpty) {
      throw Exception('Usuario/clave vacíos');
    }
    final session = Session(type: 'classic', token: 'classic-${user}-${_randomToken()}');
    await _prefs.setString(_kSession, session.encode());
    return session;
  }

  @override
  Future<Session> loginXtream(String url, String user, String pass) async {
    // Para el caso M3U, user/pass pueden venir vacíos. Intentamos descargar y parsear la url.
    try {
      final resp = await _dio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      final body = resp.data ?? '';
      final items = parseM3u(body);
      if (items.isEmpty) {
        throw Exception('El M3U no contiene streams válidos');
      }

      // Si quieres validar credenciales Xtream reales, aquí va la llamada a la API Xtream.
      final session = Session(type: 'xtream', token: 'xtream-${_randomToken()}', m3uUrl: url);
      await _prefs.setString(_kSession, session.encode());

      // Opcional: cachear el M3U en Hive/DB para no volver a descargarlo en catálogo.
      return session;
    } on DioError catch (e) {
      throw Exception('Error descargando M3U: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(_kSession);
  }

  @override
  Future<Session?> getSavedSession() async {
    final json = _prefs.getString(_kSession);
    return Session.tryDecode(json);
  }

  String _randomToken([int len = 8]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return List.generate(len, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}