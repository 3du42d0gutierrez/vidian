import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Resuelve la URL a reproducir a partir de un contentId
class LoadPlayerByIdEvent extends PlayerEvent {
  final String contentId;
  LoadPlayerByIdEvent(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

/// Cargar directamente usando una URL conocida
class LoadPlayerByUrlEvent extends PlayerEvent {
  final String url;
  final String? title;
  LoadPlayerByUrlEvent({required this.url, this.title});

  @override
  List<Object?> get props => [url, title];
}