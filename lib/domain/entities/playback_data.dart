class PlaybackData {
  final String contentId;
  final String url; // HLS/DASH URL
  final String? subtitleUrl; // WebVTT (opcional)
  final int? durationMillis;

  PlaybackData({
    required this.contentId,
    required this.url,
    this.subtitleUrl,
    this.durationMillis,
  });
}