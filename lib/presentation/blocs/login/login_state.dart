import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String sessionType; // e.g. 'demo', 'classic', 'xtream', 'm3u'
  final Map<String, dynamic>? meta;

  const LoginSuccess({required this.sessionType, this.meta});

  @override
  List<Object?> get props => [sessionType, meta];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}