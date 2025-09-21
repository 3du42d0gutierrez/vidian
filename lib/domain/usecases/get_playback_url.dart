import 'package:vidian_stream/domain/entities/playback_data.dart';
import 'package:vidian_stream/domain/repositories/player_repository.dart';

class GetPlaybackUrl {
  final PlayerRepository repository;
  GetPlaybackUrl(this.repository);

  Future<PlaybackData> call(String contentId) => repository.getPlaybackData(contentId);
}