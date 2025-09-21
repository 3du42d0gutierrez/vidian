import 'package:vidian_stream/domain/entities/playback_data.dart';
import 'package:vidian_stream/domain/repositories/player_repository.dart';

/// Implementación demo / mock — reemplaza por llamadas reales al backend/Xtream.
class PlayerRepositoryImpl implements PlayerRepository {
  PlayerRepositoryImpl();

  @override
  Future<PlaybackData> getPlaybackData(String contentId) async {
    // Simula latencia de red
    await Future.delayed(const Duration(milliseconds: 300));

    // Demo HLS público (usa un stream de test). En producción se obtiene del backend.
    final url = 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8';

    // Demo subtitle (WebVTT) opcional — reemplaza por URL real si está disponible.
    final subtitle =
        'https://raw.githubusercontent.com/mitodl/ocw-data-parser/master/tests/test_data/subs.vtt';

    // Duración demo desconocida (puede obtenerse desde manifest en producción)
    return PlaybackData(contentId: contentId, url: url, subtitleUrl: subtitle, durationMillis: null);
  }
}