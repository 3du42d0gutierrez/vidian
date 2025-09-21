import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vidian_stream/data/models/content_model.dart';
import 'package:vidian_stream/core/utils/m3u_parser.dart';

class RemoteDataSourceException implements Exception {
  final String message;
  RemoteDataSourceException(this.message);
  @override
  String toString() => 'RemoteDataSourceException: $message';
}

abstract class ContentRemoteDataSource {
  Future<List<ContentModel>> fetchContentsFromM3u(String url);
  Future<List<ContentModel>> fetchContentsPage({required int page, required int pageSize});
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final Dio _dio;

  ContentRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ));

  @override
  Future<List<ContentModel>> fetchContentsFromM3u(String url) async {
    // Validate url
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'))) {
      throw RemoteDataSourceException('Invalid M3U URL: $url');
    }

    try {
      final resp = await _dio.get<String>(url, options: Options(responseType: ResponseType.plain));
      final status = resp.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw RemoteDataSourceException('Unexpected HTTP status $status when fetching M3U');
      }
      final body = resp.data ?? '';

      final parsed = parseM3u(body, baseUrl: url);
      // map parsed items to ContentModel using a stable factory
      return parsed
          .map((p) => ContentModel.fromTitleAndUrl(
                p.title.isNotEmpty ? p.title : p.url,
                p.url,
                thumbnail: p.logo,
                category: p.group,
              ))
          .toList();
    } on DioError catch (e) {
      final msg = e.error is SocketException ? 'Network error' : e.message;
      throw RemoteDataSourceException('Dio error fetching M3U: $msg');
    } catch (e) {
      throw RemoteDataSourceException('Error fetching/parsing M3U: $e');
    }
  }

  @override
  Future<List<ContentModel>> fetchContentsPage({required int page, required int pageSize}) async {
    try {
      final resp = await _dio.get('/contents', queryParameters: {'page': page, 'pageSize': pageSize});
      final status = resp.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw RemoteDataSourceException('Unexpected HTTP status $status when fetching contents page');
      }

      final data = resp.data;
      if (data is Map && data['items'] is List) {
        return List<Map<String, dynamic>>.from(data['items']).map((m) => ContentModel.fromMap(m)).toList();
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data).map((m) => ContentModel.fromMap(m)).toList();
      } else {
        return [];
      }
    } on DioError catch (e) {
      final msg = e.error is SocketException ? 'Network error' : e.message;
      throw RemoteDataSourceException('Dio error fetching page: $msg');
    } catch (e) {
      throw RemoteDataSourceException('Error mapping remote page: $e');
    }
  }
}