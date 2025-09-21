import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:vidian_stream/domain/repositories/content_repository.dart';
import 'package:vidian_stream/data/models/content_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ContentRepository contentRepository;
  static const String _settingsBox = 'settings';

  LoginBloc({required this.contentRepository}) : super(LoginInitial()) {
    on<CheckSessionEvent>(_onCheckSession); // Evento para restaurar sesión automática
    on<LoginDemoEvent>(_onDemo);
    on<LoginClassicEvent>(_onClassic);
    on<LoginXtreamEvent>(_onXtream);
    on<LoginM3uEvent>(_onM3u);

    add(CheckSessionEvent()); // Se dispara automáticamente al crear el Bloc
  }

  Future<void> _onCheckSession(CheckSessionEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    final prefs = await SharedPreferences.getInstance();

    final sessionType = prefs.getString('session_type');
    if (sessionType == null) {
      emit(LoginInitial());
      return;
    }

    switch (sessionType) {
      case 'demo':
        emit(const LoginSuccess(sessionType: 'demo'));
        break;
      case 'classic':
        final username = prefs.getString('username');
        emit(LoginSuccess(sessionType: 'classic', meta: {'username': username}));
        break;
      case 'xtream':
        final url = prefs.getString('xtream_url');
        final username = prefs.getString('xtream_user');
        emit(LoginSuccess(sessionType: 'xtream', meta: {'url': url, 'username': username}));
        break;
      case 'm3u':
        final url = prefs.getString('m3u_url');
        emit(LoginSuccess(sessionType: 'm3u', meta: {'url': url}));
        break;
      default:
        emit(LoginInitial());
    }
  }

  Future<void> _onDemo(LoginDemoEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    await Future.delayed(const Duration(milliseconds: 400)); // simulate
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_type', 'demo');
    await _saveToHive('session_type', 'demo');
    emit(const LoginSuccess(sessionType: 'demo'));
  }

  Future<void> _onClassic(LoginClassicEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_type', 'classic');
      await prefs.setString('username', event.username);
      await _saveToHive('session_type', 'classic');
      await _saveToHive('username', event.username);
      emit(const LoginSuccess(sessionType: 'classic'));
    } catch (e) {
      emit(LoginFailure('Login clásico falló: ${e.toString()}'));
    }
  }

  Future<void> _onXtream(LoginXtreamEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_type', 'xtream');
      await prefs.setString('xtream_url', event.url);
      await prefs.setString('xtream_user', event.username);

      await _saveToHive('session_type', 'xtream');
      await _saveToHive('xtream_url', event.url);
      await _saveToHive('xtream_user', event.username);

      emit(const LoginSuccess(sessionType: 'xtream'));
    } catch (e) {
      emit(LoginFailure('Login Xtream falló: ${e.toString()}'));
    }
  }

  Future<void> _onM3u(LoginM3uEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final url = event.url.trim();
      if (url.isEmpty) {
        emit(const LoginFailure('La URL M3U no puede estar vacía.'));
        return;
      }

      final List contents = await contentRepository.fetchContentsFromM3u(url);

      if (contents.isEmpty) {
        emit(LoginFailure('No se encontraron entradas válidas en la M3U proporcionada.'));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_type', 'm3u');
      await prefs.setString('m3u_url', url);

      await _saveToHive('session_type', 'm3u');
      await _saveToHive('m3u_url', url);

      final first = contents.first;
      final meta = <String, dynamic>{
        'first_id': (first is ContentModel ? first.id : (first as dynamic).id),
        'first_title': (first is ContentModel ? first.title : (first as dynamic).title),
      };

      emit(LoginSuccess(sessionType: 'm3u', meta: meta));
    } catch (e, st) {
      debugPrint('Error en _onM3u: $e\n$st');
      emit(LoginFailure('Error al procesar la M3U: ${e.toString()}'));
    }
  }

  Future<void> _saveToHive(String key, dynamic value) async {
    try {
      if (!Hive.isBoxOpen(_settingsBox)) {
        await Hive.openBox(_settingsBox);
      }
      final box = Hive.box(_settingsBox);
      await box.put(key, value);
      await box.flush();
      debugPrint('Hive: guardado $key = $value');
    } catch (e, st) {
      debugPrint('Hive save error for $key: $e\n$st');
    }
  }
}