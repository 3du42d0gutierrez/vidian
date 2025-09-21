import 'package:equatable/equatable.dart';

abstract class PlayerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerReady extends PlayerState {
  final String url;
  final String? title;
  PlayerReady({required this.url, this.title});

  @override
  List<Object?> get props => [url, title];
}

class PlayerError extends PlayerState {
  final String message;
  PlayerError({required this.message});

  @override
  List<Object?> get props => [message];
}