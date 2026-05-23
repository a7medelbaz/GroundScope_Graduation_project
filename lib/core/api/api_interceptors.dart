import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs all requests, responses, and errors in debug mode only
class LoggerInterceptor extends Interceptor {
  static const _line = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  @override
  void onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(_line);
      debugPrint('📤 REQUEST [${options.method}] ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('Query: ${options.queryParameters}');
      }
      if (options.data != null) debugPrint('Body: ${options.data}');
      debugPrint(_line);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    final Response response,
    final ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(_line);
      debugPrint(
        '📥 RESPONSE [${response.statusCode}] ${response.requestOptions.uri}',
      );
      debugPrint('Data: ${response.data}');
      debugPrint(_line);
    }
    handler.next(response);
  }

  @override
  void onError(final DioException err, final ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(_line);
      debugPrint(
        '❌ ERROR [${err.response?.statusCode}] ${err.requestOptions.uri}',
      );
      debugPrint('Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('Response: ${err.response?.data}');
      }
      debugPrint(_line);
    }
    handler.next(err);
  }
}

/// Injects the auth token from SecureStorage into every request
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;

  AuthInterceptor({required this.getToken});

  @override
  void onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
