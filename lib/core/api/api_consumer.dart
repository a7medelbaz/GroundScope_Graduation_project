/// API Consumer Interface
/// Defines the contract for all API operations
/// Supports RESTful operations: GET, POST, PUT, DELETE, PATCH
abstract class ApiConsumer {
  /// Performs a GET request
  ///
  /// [path] - API endpoint path
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> get(
    final String path, {
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  });

  /// Performs a POST request
  ///
  /// [path] - API endpoint path
  /// [body] - Request body data
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> post(
    final String path, {
    final Map<String, dynamic>? body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  });

  /// Performs a PUT request
  ///
  /// [path] - API endpoint path
  /// [body] - Request body data
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> put(
    final String path, {
    final Map<String, dynamic>? body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  });

  /// Performs a DELETE request
  ///
  /// [path] - API endpoint path
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> delete(
    final String path, {
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  });

  /// Performs a PATCH request
  ///
  /// [path] - API endpoint path
  /// [body] - Request body data
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> patch(
    final String path, {
    final Map<String, dynamic>? body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  });
}
