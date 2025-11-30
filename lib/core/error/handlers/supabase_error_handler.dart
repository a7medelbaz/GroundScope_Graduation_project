import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_error.dart';
import '../types/error_type.dart';

class SupabaseErrorHandler {
  /// Main handler: convert any Supabase or generic exception into AppError
  static AppError handle(dynamic error) {
    if (error is AuthApiException) {
      return _handleAuthApiException(error);
    } else if (error is PostgrestException) {
      return _handlePostgrestException(error);
    } else if (error is StorageException) {
      return _handleStorageException(error);
    } else if (error is Exception) {
      return _handleGenericException(error);
    }

    // Fallback for unknown errors
    return AppError.unknown('Something went wrong. Please try again.');
  }

  // =========================
  // Auth Error Handling
  // =========================
  static AppError _handleAuthApiException(AuthApiException error) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode != null
        ? int.tryParse(error.statusCode!)
        : null;

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return AppError(
        message: 'Invalid email or password.',
        type: ErrorType.invalidCredentials,
        code: statusCode,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('user not found') ||
        message.contains('user does not exist')) {
      return AppError(
        message: 'No account found with this email.',
        type: ErrorType.userNotFound,
        code: statusCode,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('user already registered') ||
        message.contains('email already exists') ||
        message.contains('already been registered')) {
      return AppError(
        message: 'Email already registered.',
        type: ErrorType.emailAlreadyExists,
        code: statusCode,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('password') && message.contains('weak')) {
      return AppError(
        message: 'Password is too weak.',
        type: ErrorType.weakPassword,
        code: statusCode,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('invalid email')) {
      return AppError(
        message: 'Please enter a valid email.',
        type: ErrorType.invalidEmail,
        code: statusCode,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('session') && message.contains('expired')) {
      return AppError(
        message: 'Your session expired. Please log in again.',
        type: ErrorType.sessionExpired,
        code: statusCode,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('not authenticated') || message.contains('jwt')) {
      return AppError(
        message: 'You need to log in to continue.',
        type: ErrorType.unauthorized,
        code: statusCode,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('rate limit') ||
        message.contains('too many requests')) {
      return AppError(
        message: 'Too many attempts. Please try again later.',
        type: ErrorType.supabaseAuth,
        code: ErrorCode.tooManyRequests,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('email not confirmed') || message.contains('verify')) {
      return AppError(
        message: 'Please verify your email address.',
        type: ErrorType.emailNotVerified,
        code: statusCode,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('network') || message.contains('connection')) {
      return AppError.noInternet();
    }

    // Default fallback
    return AppError(
      message: 'Something went wrong with login. Please try again.',
      type: ErrorType.supabaseAuth,
      code: statusCode,
      technicalMessage: error.message,
      originalError: error,
    );
  }

  // =========================
  // Database Error Handling
  // =========================
  static AppError _handlePostgrestException(PostgrestException error) {
    final message = error.message.toLowerCase();
    final code = error.code ?? '';

    if (code == 'PGRST116' || message.contains('not found')) {
      return AppError(
        message: 'Data not found.',
        type: ErrorType.notFound,
        code: ErrorCode.notFound,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('duplicate') || message.contains('already exists')) {
      return AppError(
        message: 'Data already exists.',
        type: ErrorType.conflict,
        code: ErrorCode.conflict,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('permission') || message.contains('policy')) {
      return AppError(
        message: 'You don\'t have permission to perform this action.',
        type: ErrorType.forbidden,
        code: ErrorCode.forbidden,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    return AppError(
      message: 'Something went wrong with the database. Please try again.',
      type: ErrorType.supabaseDatabase,
      code: ErrorCode.unknown,
      technicalMessage: error.message,
      originalError: error,
    );
  }

  // =========================
  // Storage Error Handling
  // =========================
  static AppError _handleStorageException(StorageException error) {
    final message = error.message.toLowerCase();
    final statusCode = int.tryParse(error.statusCode ?? '') ?? 0;

    if (statusCode == 404 || message.contains('not found')) {
      return AppError(
        message: 'File not found.',
        type: ErrorType.notFound,
        code: ErrorCode.notFound,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (statusCode == 413 ||
        message.contains('too large') ||
        message.contains('size')) {
      return AppError(
        message: 'File is too large.',
        type: ErrorType.supabaseStorage,
        code: 413,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    if (message.contains('permission') || message.contains('unauthorized')) {
      return AppError(
        message: 'You don\'t have permission to access this file.',
        type: ErrorType.forbidden,
        code: ErrorCode.forbidden,
        technicalMessage: error.message,
        originalError: error,
      );
    }

    return AppError(
      message: 'Something went wrong with file storage. Please try again.',
      type: ErrorType.supabaseStorage,
      code: statusCode,
      technicalMessage: error.message,
      originalError: error,
    );
  }

  // =========================
  // Generic Exception Handling
  // =========================
  static AppError _handleGenericException(Exception error) {
    final message = error.toString().toLowerCase();

    if (message.contains('socket') || message.contains('network')) {
      return AppError.noInternet();
    }

    if (message.contains('timeout')) {
      return AppError.timeout();
    }

    return AppError.unknown(error.toString());
  }
}
