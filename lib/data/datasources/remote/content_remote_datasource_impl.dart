// Implementación concreta del data source remoto para contenidos.
// - Obtiene playlists M3U (Xtream / M3U) y las parsea a ContentModel.
// - Obtiene páginas JSON desde un endpoint REST (configurable).
//
// Requisitos:
// - Usa Dio para las llamadas HTTP.
// - Usa parseM3u(...) para parsear el body de M3U (lib/data/datasources/m3u_parser.dart).
// - Mapea las entradas a ContentModel usando factories convencionales.
//
// Ajusta basePath/headers/auth en el constructor según tu backend.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vidian_stream/data/models/content_model.dart';
import 'package:vidian_stream/core/utils/m3u_parser.dart';

import 'content_remote_datasource.dart';

/// Excepción propia para errores del data source remoto.
class ContentRemoteException implements Exception {
  final String message;
  ContentRemoteException(this.message);
  @override
  String toString() => 'ContentRemoteException: $message';
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final Dio _dio;
  final String? contentsEndpoint; // e.g. '/contents' or full path if no baseUrl configured.

  /// [dio] se puede inyectar para tests. [contentsEndpoint] personaliza el endpoint de paginación.
  ContentRemoteDataSourceImpl({Dio? dio, this.contentsEndpoint})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ));

  @override
  Future<List<ContentModel>> fetchContentsFromM3u(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'))) {
      throw ContentRemoteException('Invalid M3U URL: $url');
    }

    try {
      final resp = await _dio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      final status = resp.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ContentRemoteException('HTTP ${status} when fetching M3U: $url');
      }

      final body = resp.data ?? '';
      final parsed = parseM3u(body, baseUrl: url);

      // Mapea M3uEntry -> ContentModel (usa factory conveniente)
      return parsed
          .map((entry) => ContentModel.fromTitleAndUrl(
                entry.title.isNotEmpty ? entry.title : entry.url,
                entry.url,
                thumbnail: entry.logo,
                category: entry.group,
              ))
          .toList();
    } on DioError catch (e) {
      final msg = (e.error is SocketException) ? 'Network error' : (e.message ?? e.type.toString());
      throw ContentRemoteException('Dio error fetching M3U: $msg');
    } catch (e) {
      throw ContentRemoteException('Error fetching/parsing M3U: $e');
    }
  }

  @override
  Future<List<ContentModel>> fetchContentsPage({required int page, required int pageSize}) async {
    // Normaliza valores
    final _page = page <= 0 ? 1 : page;
    final _pageSize = pageSize <= 0 ? 20 : pageSize;

    try {
      final endpoint = contentsEndpoint ?? '/contents';
      final resp = await _dio.get(endpoint, queryParameters: {'page': _page, 'pageSize': _pageSize});

      final status = resp.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ContentRemoteException('HTTP ${status} when fetching contents page');
      }

      final data = resp.data;

      // Soporta dos formatos comunes:
      // 1) { items: [...] } (API paginada con objeto wrapper)
      // 2) [ ... ] (lista directa)
      if (data is Map && data['items'] is List) {
        final items = List<Map<String, dynamic>>.from(data['items']);
        return items.map((m) => ContentModel.fromMap(m)).toList();
      } else if (data is List) {
        final items = List<Map<String, dynamic>>.from(data);
        return items.map((m) => ContentModel.fromMap(m)).toList();
      } else {
        // No hay items detectables: devolver lista vacía
        return <ContentModel>[];
      }
    } on DioError catch (e) {
      final msg = (e.error is SocketException) ? 'Network error' : (e.message ?? e.type.toString());
      throw ContentRemoteException('Dio error fetching page: $msg');
    } catch (e) {
      throw ContentRemoteException('Error mapping remote page: $e');
    }
  }
}