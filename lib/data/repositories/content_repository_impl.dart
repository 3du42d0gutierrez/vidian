import 'dart:convert';

import 'package:vidian_stream/data/datasources/local/content_hive_datasource.dart';
import 'package:vidian_stream/data/datasources/remote/content_remote_datasource.dart';
import 'package:vidian_stream/data/models/content_model.dart';
import 'package:vidian_stream/domain/entities/content.dart';
import 'package:vidian_stream/domain/repositories/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource remote;
  final ContentHiveDataSource local;

  ContentRepositoryImpl({required this.remote, required this.local});

  // Helper: normalizar cualquier entrada dinámica a la entidad domain Content.
  Content _toContent(dynamic c) {
    if (c is Content) return c;
    if (c is ContentModel) return c.toEntity();
    if (c is Map<String, dynamic>) return ContentModel.fromMap(c).toEntity();
    if (c is String) {
      final decoded = json.decode(c);
      if (decoded is Map<String, dynamic>) return ContentModel.fromMap(decoded).toEntity();
    }
    throw Exception('Unknown content type: ${c.runtimeType}');
  }

  // Helper: intentar obtener ContentModel si la entrada es convertible (Map / ContentModel / JSON string).
  ContentModel? _toContentModelIfPossible(dynamic c) {
    if (c is ContentModel) return c;
    if (c is Map<String, dynamic>) return ContentModel.fromMap(c);
    if (c is String) {
      final decoded = json.decode(c);
      if (decoded is Map<String, dynamic>) return ContentModel.fromMap(decoded);
    }
    // No convertimos entidades domain Content a ContentModel (no hay fromEntity)
    return null;
  }

  @override
  Future<List<Content>> fetchContentsPage({int page = 1, int pageSize = 20}) async {
    try {
      final raw = await remote.fetchContentsPage(page: page, pageSize: pageSize);
      final List<dynamic> items = (raw is List) ? raw.cast<dynamic>() : <dynamic>[];

      // Normalizar a entidades Content
      final List<Content> contents = items.map<Content>((c) => _toContent(c)).toList();

      // Intentar cachear localmente solo los elementos que podemos convertir a ContentModel
      try {
        final models = items.map(_toContentModelIfPossible).whereType<ContentModel>().toList();
        if (models.isNotEmpty) {
          await local.saveContents(models);
        }
      } catch (_) {
        // Ignorar errores de cacheo para no romper la respuesta primaria
      }

      return contents;
    } catch (e) {
      // Fallback: usar cache local
      final models = await local.getCachedContents(page: page, pageSize: pageSize);
      return models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<List<Content>> fetchContentsFromM3u(String url) async {
    final raw = await remote.fetchContentsFromM3u(url);
    final List<dynamic> items = (raw is List) ? raw.cast<dynamic>() : <dynamic>[];

    // Intento de cacheo: convertir a ContentModel cuando sea posible (Map / ContentModel / JSON string)
    try {
      final models = items.map(_toContentModelIfPossible).whereType<ContentModel>().toList();
      if (models.isNotEmpty) {
        await local.saveContents(models);
      }
    } catch (_) {
      // ignorar errores de guardado en cache
    }

    // Normalizar a entidad Content para devolver
    final List<Content> contents = items.map<Content>((c) => _toContent(c)).toList();
    return contents;
  }

  @override
  Future<Content?> getContentById(String id) async {
    // Uso cache local. Si tu remote datasource tiene getContentById, podemos intentar remote primero.
    final model = await local.getContentById(id);
    return model?.toEntity();
  }

  // ---------- Persistencia de M3U (delegada al datasource local) ----------

  @override
  Future<void> saveM3uUrl(String url) async {
    await local.saveM3uUrl(url);
  }

  @override
  Future<String?> loadM3uUrl() async {
    return await local.loadM3uUrl();
  }

  @override
  Future<void> clearM3uUrl() async {
    await local.clearM3uUrl();
  }
}