import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/services/auth_services.dart';
import 'package:fuodz/utils/local_storage.service.dart';

/// API service utama. Semua feature service `extends ApiService`.
/// Mirror dari mbf-mobile/services/api_service.dart.
///
/// Memusatkan:
///  - Satu Dio instance + base options
///  - Auth/language header via interceptor (no per-call boilerplate)
///  - Error formatting (DioException -> Response yang friendly buat ApiResponse)
///  - Caching (dio_http_cache_lts)
///  - Logging (pretty_dio_logger)
class ApiService {
  static Dio? _dio;
  static DioCacheManager? _cacheManager;

  ApiService() {
    _ensureInit();
  }

  String get host => Api.baseUrl;
  Dio get dio => _dio!;
  DioCacheManager get cacheManager => _cacheManager!;

  static void _ensureInit() {
    if (_dio != null) return;
    LocalStorageService.getPrefs();

    _dio = Dio(
      BaseOptions(
        baseUrl: Api.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status <= 500,
        headers: {HttpHeaders.acceptHeader: 'application/json'},
      ),
    );

    _cacheManager = DioCacheManager(
      CacheConfig(
        baseUrl: Api.baseUrl,
        defaultMaxAge: const Duration(minutes: 1),
      ),
    );

    _dio!.interceptors.add(_AuthInterceptor());
    _dio!.interceptors.add(_cacheManager!.interceptor);
    _dio!.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// Header builder untuk non-Dio HTTP consumer (mis. webview).
  static Future<Map<String, String>> getHeaders() async {
    final token = await AuthServices.getAuthBearerToken();
    return {
      HttpHeaders.acceptHeader: 'application/json',
      if (token.isNotEmpty) HttpHeaders.authorizationHeader: 'Bearer $token',
      'lang': translator.activeLocale.languageCode,
    };
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(url,
          queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      return _formatDioException(e);
    }
  }

  Future<Response> post(String url, dynamic body, {Options? options}) async {
    try {
      return await dio.post(url, data: body, options: options);
    } on DioException catch (e) {
      return _formatDioException(e);
    }
  }

  Future<Response> postWithFiles(
    String url,
    dynamic body, {
    FormData? formData,
    Options? options,
  }) async {
    try {
      return await dio.post(
        url,
        data: formData ?? (body is FormData ? body : FormData.fromMap(body ?? {})),
        options: options,
      );
    } on DioException catch (e) {
      return _formatDioException(e);
    }
  }

  Future<Response> putWithFiles(
    String url,
    dynamic body, {
    FormData? formData,
    Options? options,
  }) async {
    try {
      return await dio.put(
        url,
        data: formData ?? (body is FormData ? body : FormData.fromMap(body ?? {})),
        options: options,
      );
    } on DioException catch (e) {
      return _formatDioException(e);
    }
  }

  Future<Response> patch(String url, Map<String, dynamic> body) async {
    try {
      return await dio.patch(url, data: body);
    } on DioException catch (e) {
      return _formatDioException(e);
    }
  }

  Future<Response> put(String url, dynamic body) async {
    try {
      return await dio.put(url, data: body);
    } on DioException catch (e) {
      return _formatDioException(e);
    }
  }

  Future<Response> delete(String url, {dynamic body}) async {
    try {
      return await dio.delete(url, data: body);
    } on DioException catch (e) {
      return _formatDioException(e);
    }
  }

  Future<ApiResponse> getResponse(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await get(url, queryParameters: queryParameters);
    return ApiResponse.fromResponse(res);
  }

  Future<ApiResponse> postResponse(String url, dynamic body) async {
    final res = await post(url, body);
    return ApiResponse.fromResponse(res);
  }

  Response _formatDioException(DioException ex) {
    final response = Response(requestOptions: ex.requestOptions);
    response.statusCode = ex.response?.statusCode ?? 400;

    String message;
    switch (ex.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Periksa koneksi internet Anda.';
        break;
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        message = 'Tidak dapat tersambung. Periksa koneksi internet Anda.';
        break;
      case DioExceptionType.cancel:
        message = 'Permintaan dibatalkan.';
        break;
      case DioExceptionType.badResponse:
        message = ex.response?.data is Map
            ? (ex.response?.data['message']?.toString() ?? 'Terjadi kesalahan.')
            : 'Terjadi kesalahan pada server.';
        break;
      case DioExceptionType.unknown:
        message = 'Terjadi kesalahan. Coba lagi.';
        break;
    }

    response.data = ex.response?.data is Map
        ? {...(ex.response!.data as Map), 'message': message}
        : {'message': message};
    return response;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AuthServices.getAuthBearerToken();
    if (token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    options.headers['lang'] = translator.activeLocale.languageCode;
    handler.next(options);
  }
}
