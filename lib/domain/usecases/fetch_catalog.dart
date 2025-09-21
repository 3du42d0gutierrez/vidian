import 'package:vidian_stream/domain/entities/content.dart';
import 'package:vidian_stream/domain/repositories/content_repository.dart';

/// Use case: Fetch paginated catalog from remote (or remote-backed repository).
///
/// Usage:
/// final usecase = FetchCatalog(contentRepository);
/// final page1 = await usecase.call(page: 1, pageSize: 20);
class FetchCatalog {
  final ContentRepository repository;

  FetchCatalog(this.repository);

  /// Fetch a page of catalog content.
  ///
  /// - page: 1-based page index (default 1)
  /// - pageSize: number of items per page (default 20)
  ///
  /// Throws whatever exceptions the repository throws (network, parsing, etc).
  Future<List<Content>> call({int page = 1, int pageSize = 20}) async {
    if (page <= 0) page = 1;
    if (pageSize <= 0) pageSize = 20;
    return repository.fetchContentsPage(page: page, pageSize: pageSize);
  }
}

/// Use case: Fetch catalog by downloading and parsing an M3U (Xtream/M3U flow).
///
/// Useful for flows where the user provides a M3U URL (loginXtream/loginM3u flow).
///
/// Usage:
/// final usecase = FetchCatalogFromM3u(contentRepository);
/// final items = await usecase.call('https://example.com/playlist.m3u');
class FetchCatalogFromM3u {
  final ContentRepository repository;

  FetchCatalogFromM3u(this.repository);

  /// Download + parse the M3U located at [url] and return the list of contents.
  ///
  /// Throws repository exceptions (network/parse).
  Future<List<Content>> call(String url) async {
    if (url.trim().isEmpty) {
      throw ArgumentError.value(url, 'url', 'M3U URL must not be empty');
    }
    return repository.fetchContentsFromM3u(url);
  }
}