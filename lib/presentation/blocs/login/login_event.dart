import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginDemoEvent extends LoginEvent {}

class LoginClassicEvent extends LoginEvent {
  final String username;
  final String password;

  const LoginClassicEvent(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class LoginXtreamEvent extends LoginEvent {
  final String url;
  final String username;
  final String password;

  const LoginXtreamEvent({required this.url, required this.username, required this.password});

  @override
  List<Object?> get props => [url, username, password];
}

/// Nuevo: login usando una URL M3U (solo URL)
class LoginM3uEvent extends LoginEvent {
  final String url;

  const LoginM3uEvent(this.url);

  @override
  List<Object?> get props => [url];
}

/// Evento para restaurar la sesión al iniciar la app/BLoC.
/// Permite que el LoginBloc lea la sesión persistida y emita el estado correspondiente.
class CheckSessionEvent extends LoginEvent {
  const CheckSessionEvent();

  @override
  List<Object?> get props => [];
}