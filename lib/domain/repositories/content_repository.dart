import 'package:vidian_stream/domain/entities/content.dart';

/// Interfaz (contrato) para repositorios de contenido.
/// Implementaciones concretas (data layer) deben implementar estos métodos.
abstract class ContentRepository {
  /// Fetch a paginated list of Content.
  Future<List<Content>> fetchContentsPage({int page = 1, int pageSize = 20});

  /// Fetch contents by downloading and parsing an M3U playlist located at [url].
  ///
  /// Implementations should handle network errors and parsing and throw
  /// appropriate exceptions or propagate them.
  Future<List<Content>> fetchContentsFromM3u(String url);

  /// Optional: get a single content by id.
  Future<Content?> getContentById(String id);

  // ---------- Persistencia / sesión (M3U) ----------
  /// Guarda la URL M3U de la sesión para uso posterior (persistencia local).
  /// Implementaciones típicas la almacenarán en Hive/SharedPreferences/DB.
  Future<void> saveM3uUrl(String url);

  /// Lee la URL M3U persistida si existe, o `null` si no hay ninguna.
  Future<String?> loadM3uUrl();

  /// Borra la URL M3U persistida (logout / cambio de sesión).
  Future<void> clearM3uUrl();
}