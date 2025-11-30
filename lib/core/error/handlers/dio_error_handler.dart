
// import 'package:dio/dio.dart';
// import '../models/app_error.dart';
// import '../models/error_details.dart';
// import '../types/error_type.dart';

// class DioErrorHandler {
//   static AppError handle(dynamic error) {
//     if (error is DioException) {
//       return _handleDioException(error);
//     }
//     return AppError.unknown(error.toString());
//   }

//   static AppError _handleDioException(DioException error) {
//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         return AppError(
//           message: 'Request timeout. Please check your connection and try again.',
//           type: ErrorType.timeout,
//           code: ErrorCode.timeout,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case DioExceptionType.connectionError:
//       case DioExceptionType.badCertificate:
//         return AppError(
//           message: 'Connection error. Please check your internet connection.',
//           type: ErrorType.noInternet,
//           code: ErrorCode.noInternet,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case DioExceptionType.cancel:
//         return AppError(
//           message: 'Request cancelled.',
//           type: ErrorType.cancel,
//           code: ErrorCode.cancel,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case DioExceptionType.badResponse:
//         return _handleBadResponse(error);

//       case DioExceptionType.unknown:
//         return _handleUnknownError(error);
//     }
//   }

//   static AppError _handleBadResponse(DioException error) {
//     final response = error.response;
//     final statusCode = response?.statusCode;
//     final data = response?.data;

//     // Try to extract error message from response
//     String message = _extractErrorMessage(data);
//     ErrorDetails? details = _extractErrorDetails(data);

//     switch (statusCode) {
//       case 400:
//         return AppError(
//           message: message.isEmpty ? 'Invalid request. Please check your input.' : message,
//           type: ErrorType.badRequest,
//           code: ErrorCode.badRequest,
//           technicalMessage: error.message,
//           details: details,
//           originalError: error,
//         );

//       case 401:
//         return AppError(
//           message: message.isEmpty ? 'Unauthorized. Please login again.' : message,
//           type: ErrorType.unauthorized,
//           code: ErrorCode.unauthorized,
//           technicalMessage: error.message,
//           details: details,
//           originalError: error,
//         );

//       case 403:
//         return AppError(
//           message: message.isEmpty ? 'Access forbidden. You don\'t have permission.' : message,
//           type: ErrorType.forbidden,
//           code: ErrorCode.forbidden,
//           technicalMessage: error.message,
//           details: details,
//           originalError: error,
//         );

//       case 404:
//         return AppError(
//           message: message.isEmpty ? 'Resource not found.' : message,
//           type: ErrorType.notFound,
//           code: ErrorCode.notFound,
//           technicalMessage: error.message,
//           details: details,
//           originalError: error,
//         );

//       case 409:
//         return AppError(
//           message: message.isEmpty ? 'Conflict error. Data already exists.' : message,
//           type: ErrorType.conflict,
//           code: ErrorCode.conflict,
//           technicalMessage: error.message,
//           details: details,
//           originalError: error,
//         );

//       case 422:
//         return AppError(
//           message: message.isEmpty ? 'Validation error. Please check your input.' : message,
//           type: ErrorType.validation,
//           code: ErrorCode.unprocessableEntity,
//           technicalMessage: error.message,
//           details: details,
//           originalError: error,
//         );

//       case 500:
//       case 502:
//       case 503:
//         return AppError(
//           message: 'Server error. Please try again later.',
//           type: ErrorType.internalServer,
//           code: ErrorCode.internalServer,
//           technicalMessage: error.message,
//           details: details,
//           originalError: error,
//         );

//       default:
//         return AppError(
//           message: message.isEmpty ? 'An error occurred. Please try again.' : message,
//           type: ErrorType.unknown,
//           code: statusCode ?? ErrorCode.unknown,
//           technicalMessage: error.message,
//           details: details,
//           originalError: error,
//         );
//     }
//   }

//   static AppError _handleUnknownError(DioException error) {
//     // Check if it's a network error
//     if (error.error.toString().toLowerCase().contains('socket') ||
//         error.error.toString().toLowerCase().contains('network')) {
//       return AppError.noInternet();
//     }

//     return AppError(
//       message: 'An unexpected error occurred. Please try again.',
//       type: ErrorType.unknown,
//       code: ErrorCode.unknown,
//       technicalMessage: error.message ?? error.error.toString(),
//       originalError: error,
//     );
//   }

//   static String _extractErrorMessage(dynamic data) {
//     if (data == null) return '';

//     try {
//       if (data is Map<String, dynamic>) {
//         // Try common message fields
//         if (data['message'] != null) {
//           return data['message'].toString();
//         }
//         if (data['error'] != null) {
//           if (data['error'] is String) {
//             return data['error'];
//           }
//           if (data['error'] is Map && data['error']['message'] != null) {
//             return data['error']['message'].toString();
//           }
//         }
//         if (data['msg'] != null) {
//           return data['msg'].toString();
//         }
//         if (data['detail'] != null) {
//           return data['detail'].toString();
//         }
//       }
      
//       if (data is String) {
//         return data;
//       }
//     } catch (e) {
//       // If extraction fails, return empty string
//     }

//     return '';
//   }

//   static ErrorDetails? _extractErrorDetails(dynamic data) {
//     if (data == null || data is! Map<String, dynamic>) return null;

//     try {
//       // Try to extract validation errors or additional details
//       if (data['errors'] != null) {
//         return ErrorDetails(
//           metadata: {'errors': data['errors']},
//         );
//       }
//       if (data['data'] != null && data['data'] is Map) {
//         return ErrorDetails.fromJson(data['data']);
//       }
//     } catch (e) {
//       // If extraction fails, return null
//     }

//     return null;
//   }
// }