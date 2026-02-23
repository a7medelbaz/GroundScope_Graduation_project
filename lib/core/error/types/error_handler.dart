import 'package:supabase_flutter/supabase_flutter.dart';

import '../handlers/supabase_error_handler.dart';
import '../models/app_error.dart';

class ErrorHandler {
  /// Handle any error and convert it to AppError
  static AppError handle(dynamic error) {
    // Check for Supabase errors
    if (_isSupabaseError(error)) {
      return SupabaseErrorHandler.handle(error);
    }

    // Handle AppError (already processed)
    if (error is AppError) {
      return error;
    }

    // Handle generic Exception
    if (error is Exception) {
      return AppError.unknown(error.toString());
    }

    // Handle any other error type
    return AppError.unknown(error?.toString() ?? 'Unknown error occurred');
  }

  /// Check if the error is a Supabase-related error
  static bool _isSupabaseError(dynamic error) {
    return error is AuthApiException || // for API auth errors
        error is AuthException || // general auth errors
        error is PostgrestException ||
        error is StorageException;
  }
}

// =================================================================
// Extension for easy error handling
// =================================================================

extension ErrorHandlerExtension on Object {
  AppError toAppError() {
    return ErrorHandler.handle(this);
  }
}
