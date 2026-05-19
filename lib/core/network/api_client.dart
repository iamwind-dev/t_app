import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'api_token_store.dart';

class ApiClient {
  ApiClient({
    required Dio dio,
    required ApiTokenStore tokenStore,
    HttpClientAdapter? httpClientAdapter,
  }) : _dio = dio,
       _tokenStore = tokenStore {
    _dio.options
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 20)
      ..validateStatus = (_) => true;

    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final ApiTokenStore _tokenStore;

  Future<T> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    required T Function(Object? value) decode,
  }) {
    return _request<T>(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
      path: path,
      decode: decode,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    required T Function(Object? value) decode,
  }) {
    return _request<T>(
      () => _dio.post<Object?>(path, data: data),
      path: path,
      decode: decode,
    );
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    required T Function(Object? value) decode,
  }) {
    return _request<T>(
      () => _dio.patch<Object?>(path, data: data),
      path: path,
      decode: decode,
    );
  }

  Future<T> delete<T>(
    String path, {
    required T Function(Object? value) decode,
  }) {
    return _request<T>(
      () => _dio.delete<Object?>(path),
      path: path,
      decode: decode,
    );
  }

  Future<T> _request<T>(
    Future<Response<Object?>> Function() send, {
    required String path,
    required T Function(Object? value) decode,
    bool allowRefresh = true,
  }) async {
    try {
      final response = await send();
      final envelope = _readEnvelope(response.data);

      if (envelope.success) {
        return decode(envelope.data);
      }

      if (_shouldRefresh(
        path: path,
        statusCode: response.statusCode,
        allowRefresh: allowRefresh,
      )) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return _request<T>(
            send,
            path: path,
            decode: decode,
            allowRefresh: false,
          );
        }
      }

      throw ApiException(
        code: envelope.errorCode,
        message: envelope.errorMessage ?? 'Request failed.',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Failed to decode API response: $error');
    }
  }

  bool _shouldRefresh({
    required String path,
    required int? statusCode,
    required bool allowRefresh,
  }) {
    if (!allowRefresh || statusCode != 401) {
      return false;
    }

    return path != '/auth/login' &&
        path != '/auth/register' &&
        path != '/auth/refresh' &&
        path != '/auth/logout';
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStore.clearToken();
      return false;
    }

    try {
      final response = await _dio.post<Object?>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final envelope = _readEnvelope(response.data);
      if (!envelope.success || envelope.data is! Map<String, dynamic>) {
        await _tokenStore.clearToken();
        return false;
      }

      final data = envelope.data as Map<String, dynamic>;
      final nextAccessToken = data['accessToken'] as String?;
      final nextRefreshToken = data['refreshToken'] as String?;
      if (nextAccessToken == null ||
          nextAccessToken.isEmpty ||
          nextRefreshToken == null ||
          nextRefreshToken.isEmpty) {
        await _tokenStore.clearToken();
        return false;
      }

      await _tokenStore.writeToken(nextAccessToken);
      await _tokenStore.writeRefreshToken(nextRefreshToken);
      return true;
    } catch (_) {
      await _tokenStore.clearToken();
      return false;
    }
  }

  _ApiEnvelope _readEnvelope(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const ApiException(message: 'Invalid API response envelope.');
    }

    return _ApiEnvelope.fromJson(data);
  }

  ApiException _mapDioException(DioException error) {
    final response = error.response;
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final envelope = _ApiEnvelope.fromJson(data);
      return ApiException(
        code: envelope.errorCode,
        message: envelope.errorMessage ?? error.message ?? 'Request failed.',
        statusCode: response?.statusCode,
      );
    }

    return ApiException(
      message: error.message ?? 'Network request failed.',
      statusCode: response?.statusCode,
    );
  }
}

class _ApiEnvelope {
  const _ApiEnvelope({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
  });

  factory _ApiEnvelope.fromJson(Map<String, dynamic> json) {
    final error = json['error'];
    final errorMap = error is Map<String, dynamic> ? error : null;

    return _ApiEnvelope(
      success: json['success'] == true,
      data: json['data'],
      errorCode: errorMap?['code'] as String?,
      errorMessage: errorMap?['message'] as String?,
    );
  }

  final bool success;
  final Object? data;
  final String? errorCode;
  final String? errorMessage;
}
