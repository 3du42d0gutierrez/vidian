import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  factory DioClient.create() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Interceptors pueden añadirse aquí (logger, auth, retries...)
    dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
    return DioClient._(dio);
  }
}