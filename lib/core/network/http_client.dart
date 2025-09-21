import 'package:dio/dio.dart';

class HttpClient {
  final Dio dio;

  HttpClient._internal(this.dio);

  factory HttpClient({BaseOptions? options}) {
    final dio = Dio(options ?? BaseOptions(connectTimeout: Duration(milliseconds: 5000), receiveTimeout: Duration(milliseconds: 5000)));
    // Añade interceptores, logging y manejo de errores según necesites
    dio.interceptors.add(LogInterceptor(responseBody: false, requestBody: false));
    return HttpClient._internal(dio);
  }
}