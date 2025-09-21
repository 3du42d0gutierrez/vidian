import 'package:vidian_stream/domain/entities/playback_data.dart';

abstract class PlayerRepository {
  /// Obtiene URL de reproducción y metadatos (subtítulos, duración)
  Future<PlaybackData> getPlaybackData(String contentId);
}