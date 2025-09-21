// Minimal M3U parser that extracts EXTINF entries and their following URL.
// Returns a list of M3uEntry: id, title, url, logo, group.
// The parser is lenient and aims to work with common Xtream/M3U playlists.

class M3uEntry {
  final String id; // tvg-id or url fallback
  final String title;
  final String url;
  final String? logo; // tvg-logo
  final String? group; // group-title

  M3uEntry({required this.id, required this.title, required this.url, this.logo, this.group});
}

/// Parse an M3U playlist body and return entries.
/// Optionally provide baseUrl to resolve relative URLs (very basic resolution).
List<M3uEntry> parseM3u(String raw, {String? baseUrl}) {
  final lines = raw.split(RegExp(r'\r?\n'));
  final List<M3uEntry> result = [];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;

    if (line.startsWith('#EXTINF')) {
      final extinf = line;
      final idx = extinf.lastIndexOf(',');
      final title = idx >= 0 ? extinf.substring(idx + 1).trim() : extinf;

      final meta = idx >= 0 ? extinf.substring(0, idx) : extinf;

      final tvgIdMatch = RegExp(r'tvg-id="([^"]+)"').firstMatch(meta);
      final tvgLogoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(meta);
      final groupMatch = RegExp(r'group-title="([^"]+)"').firstMatch(meta);

      String? tvgId = tvgIdMatch?.group(1);
      String? tvgLogo = tvgLogoMatch?.group(1);
      String? groupTitle = groupMatch?.group(1);

      // Find next non-empty, non-comment line as URL
      String? url;
      for (var j = i + 1; j < lines.length; j++) {
        final candidate = lines[j].trim();
        if (candidate.isEmpty) continue;
        if (candidate.startsWith('#')) continue;
        url = candidate;
        break;
      }

      if (url == null || url.isEmpty) continue;

      // Simple resolution for relative URLs: if url doesn't have scheme and baseUrl provided, join.
      final uri = Uri.tryParse(url);
      String finalUrl = url;
      if ((uri == null || !uri.hasScheme) && baseUrl != null) {
        try {
          final base = Uri.parse(baseUrl);
          final resolved = base.resolve(url);
          finalUrl = resolved.toString();
        } catch (_) {
          // fallthrough keep original
        }
      }

      final id = tvgId ?? finalUrl;
      result.add(M3uEntry(id: id, title: title, url: finalUrl, logo: tvgLogo, group: groupTitle));
    }
  }

  return result;
}