import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:vidian_stream/domain/repositories/content_repository.dart';
import 'package:vidian_stream/domain/entities/content.dart';

import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final ContentRepository repository;

  PlayerBloc({required this.repository}) : super(PlayerInitial()) {
    on<LoadPlayerByIdEvent>(_onLoadById);
    on<LoadPlayerByUrlEvent>(_onLoadByUrl);
  }

  Future<void> _onLoadById(LoadPlayerByIdEvent event, Emitter<PlayerState> emit) async {
    debugPrint('[PlayerBloc] LoadPlayerByIdEvent: ${event.contentId}');
    emit(PlayerLoading());
    try {
      final Content? content = await repository.getContentById(event.contentId);
      debugPrint('[PlayerBloc] Content fetched: $content');
      if (content == null) {
        emit(PlayerError(message: 'Content not found for id: ${event.contentId}'));
        return;
      }

      final String? url = content.url;
      final String title = content.title ?? 'Player';
      debugPrint('[PlayerBloc] URL: $url, Title: $title');

      if (url == null || url.trim().isEmpty) {
        emit(PlayerError(message: 'No playable URL available for: ${content.id}'));
        return;
      }

      final lower = url.toLowerCase();
      if (lower.endsWith('.m3u') || lower.endsWith('.m3u8')) {
        debugPrint('[PlayerBloc] Detected M3U playlist');
        try {
          final List<Content> parsed = await repository.fetchContentsFromM3u(url);
          debugPrint('[PlayerBloc] Parsed M3U: ${parsed.length} entries');
          if (parsed.isNotEmpty && parsed.first.url != null && parsed.first.url!.isNotEmpty) {
            debugPrint('[PlayerBloc] Using first entry URL: ${parsed.first.url}');
            emit(PlayerReady(url: parsed.first.url ?? '', title: parsed.first.title ?? title));
            return;
          } else {
            emit(PlayerError(message: 'No playable entries found in M3U at $url'));
            return;
          }
        } catch (e) {
          debugPrint('[PlayerBloc] Error parsing M3U: $e');
          emit(PlayerError(message: 'Error parsing M3U: ${e.toString()}'));
          return;
        }
      }

      debugPrint('[PlayerBloc] Emitting PlayerReady with direct URL');
      emit(PlayerReady(url: url, title: title));
    } catch (e) {
      debugPrint('[PlayerBloc] Exception: $e');
      emit(PlayerError(message: e.toString()));
    }
  }

  Future<void> _onLoadByUrl(LoadPlayerByUrlEvent event, Emitter<PlayerState> emit) async {
    debugPrint('[PlayerBloc] LoadPlayerByUrlEvent: ${event.url}');
    emit(PlayerLoading());
    try {
      final String url = event.url;
      final String title = event.title ?? 'Player';
      debugPrint('[PlayerBloc] URL: $url, Title: $title');

      if (url.trim().isEmpty) {
        emit(PlayerError(message: 'Provided URL is empty'));
        return;
      }

      final lower = url.toLowerCase();
      if (lower.endsWith('.m3u') || lower.endsWith('.m3u8')) {
        debugPrint('[PlayerBloc] Detected M3U playlist');
        try {
          final List<Content> parsed = await repository.fetchContentsFromM3u(url);
          debugPrint('[PlayerBloc] Parsed M3U: ${parsed.length} entries');
          if (parsed.isNotEmpty && parsed.first.url != null && parsed.first.url!.isNotEmpty) {
            debugPrint('[PlayerBloc] Using first entry URL: ${parsed.first.url}');
            emit(PlayerReady(url: parsed.first.url ?? '', title: parsed.first.title ?? title));
            return;
          } else {
            emit(PlayerError(message: 'No playable entries found in provided M3U'));
            return;
          }
        } catch (e) {
          debugPrint('[PlayerBloc] Error parsing M3U: $e');
          emit(PlayerError(message: 'Error parsing provided M3U: ${e.toString()}'));
          return;
        }
      }

      debugPrint('[PlayerBloc] Emitting PlayerReady with direct URL');
      emit(PlayerReady(url: url, title: title));
    } catch (e) {
      debugPrint('[PlayerBloc] Exception: $e');
      emit(PlayerError(message: e.toString()));
    }
  }
}
