
// import '../models/app_error.dart';
// import '../types/error_type.dart';

// class FirebaseErrorHandler {
//   static AppError handle(dynamic error) {
//     if (error is FirebaseAuthException) {
//       return _handleAuthException(error);
//     }

//     if (error is FirebaseException) {
//       return _handleFirebaseException(error);
//     }

//     return AppError.unknown(error.toString());
//   }

//   // Handle Firebase Auth Errors
//   static AppError _handleAuthException(FirebaseAuthException error) {
//     switch (error.code) {
//       // Email/Password errors
//       case 'invalid-email':
//         return AppError(
//           message: 'Invalid email address format.',
//           type: ErrorType.invalidEmail,
//           code: ErrorCode.badRequest,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'user-disabled':
//         return AppError(
//           message: 'This account has been disabled.',
//           type: ErrorType.firebaseAuth,
//           code: ErrorCode.forbidden,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'user-not-found':
//         return AppError(
//           message: 'No account found with this email.',
//           type: ErrorType.userNotFound,
//           code: ErrorCode.notFound,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'wrong-password':
//       case 'invalid-credential':
//         return AppError(
//           message: 'Invalid email or password.',
//           type: ErrorType.invalidCredentials,
//           code: ErrorCode.unauthorized,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'email-already-in-use':
//         return AppError(
//           message: 'An account with this email already exists.',
//           type: ErrorType.emailAlreadyExists,
//           code: ErrorCode.conflict,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'weak-password':
//         return AppError(
//           message: 'Password is too weak. Please use a stronger password.',
//           type: ErrorType.weakPassword,
//           code: ErrorCode.badRequest,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'operation-not-allowed':
//         return AppError(
//           message: 'This operation is not allowed.',
//           type: ErrorType.firebaseAuth,
//           code: ErrorCode.forbidden,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       // Session errors
//       case 'requires-recent-login':
//         return AppError(
//           message: 'Please login again to complete this action.',
//           type: ErrorType.sessionExpired,
//           code: ErrorCode.unauthorized,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'user-token-expired':
//       case 'invalid-user-token':
//         return AppError(
//           message: 'Your session has expired. Please login again.',
//           type: ErrorType.sessionExpired,
//           code: ErrorCode.unauthorized,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       // Network errors
//       case 'network-request-failed':
//         return AppError.noInternet();

//       case 'too-many-requests':
//         return AppError(
//           message: 'Too many attempts. Please try again later.',
//           type: ErrorType.firebaseAuth,
//           code: 429,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       // Timeout
//       case 'timeout':
//         return AppError.timeout();

//       default:
//         return AppError(
//           message: error.message ?? 'Authentication error occurred.',
//           type: ErrorType.firebaseAuth,
//           code: ErrorCode.unknown,
//           technicalMessage: error.message,
//           originalError: error,
//         );
//     }
//   }

//   // Handle Firestore and Storage Errors
//   static AppError _handleFirebaseException(FirebaseException error) {
//     // Check if it's a Firestore error
//     if (error.plugin == 'cloud_firestore') {
//       return _handleFirestoreError(error);
//     }

//     // Check if it's a Storage error
//     if (error.plugin == 'firebase_storage') {
//       return _handleStorageError(error);
//     }

//     // Generic Firebase error
//     switch (error.code) {
//       case 'permission-denied':
//         return AppError(
//           message: 'You don\'t have permission to perform this action.',
//           type: ErrorType.forbidden,
//           code: ErrorCode.forbidden,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'unavailable':
//         return AppError(
//           message: 'Service temporarily unavailable. Please try again.',
//           type: ErrorType.internalServer,
//           code: ErrorCode.internalServer,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'cancelled':
//         return AppError(
//           message: 'Operation was cancelled.',
//           type: ErrorType.cancel,
//           code: ErrorCode.cancel,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'deadline-exceeded':
//         return AppError.timeout();

//       default:
//         return AppError(
//           message: error.message ?? 'An error occurred.',
//           type: ErrorType.unknown,
//           code: ErrorCode.unknown,
//           technicalMessage: error.message,
//           originalError: error,
//         );
//     }
//   }

//   static AppError _handleFirestoreError(FirebaseException error) {
//     switch (error.code) {
//       case 'not-found':
//         return AppError(
//           message: 'Document not found.',
//           type: ErrorType.notFound,
//           code: ErrorCode.notFound,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'already-exists':
//         return AppError(
//           message: 'Document already exists.',
//           type: ErrorType.conflict,
//           code: ErrorCode.conflict,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'failed-precondition':
//         return AppError(
//           message: 'Operation failed. Please ensure all conditions are met.',
//           type: ErrorType.firebaseFirestore,
//           code: ErrorCode.badRequest,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'aborted':
//         return AppError(
//           message: 'Operation aborted due to conflict. Please try again.',
//           type: ErrorType.firebaseFirestore,
//           code: ErrorCode.conflict,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'out-of-range':
//         return AppError(
//           message: 'Invalid input range.',
//           type: ErrorType.validation,
//           code: ErrorCode.badRequest,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'data-loss':
//         return AppError(
//           message: 'Unrecoverable data loss occurred.',
//           type: ErrorType.firebaseFirestore,
//           code: ErrorCode.internalServer,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       default:
//         return AppError(
//           message: error.message ?? 'Database error occurred.',
//           type: ErrorType.firebaseFirestore,
//           code: ErrorCode.unknown,
//           technicalMessage: error.message,
//           originalError: error,
//         );
//     }
//   }

//   static AppError _handleStorageError(FirebaseException error) {
//     switch (error.code) {
//       case 'object-not-found':
//       case 'bucket-not-found':
//         return AppError(
//           message: 'File not found.',
//           type: ErrorType.notFound,
//           code: ErrorCode.notFound,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'unauthorized':
//         return AppError(
//           message: 'You don\'t have permission to access this file.',
//           type: ErrorType.forbidden,
//           code: ErrorCode.forbidden,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'quota-exceeded':
//         return AppError(
//           message: 'Storage quota exceeded.',
//           type: ErrorType.firebaseStorage,
//           code: 507,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'unauthenticated':
//         return AppError(
//           message: 'Please login to access this file.',
//           type: ErrorType.unauthorized,
//           code: ErrorCode.unauthorized,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'retry-limit-exceeded':
//         return AppError(
//           message: 'Upload failed. Please try again.',
//           type: ErrorType.firebaseStorage,
//           code: ErrorCode.unknown,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       case 'invalid-checksum':
//         return AppError(
//           message: 'File upload failed. Please try again.',
//           type: ErrorType.firebaseStorage,
//           code: ErrorCode.badRequest,
//           technicalMessage: error.message,
//           originalError: error,
//         );

//       default:
//         return AppError(
//           message: error.message ?? 'Storage error occurred.',
//           type: ErrorType.firebaseStorage,
//           code: ErrorCode.unknown,
//           technicalMessage: error.message,
//           originalError: error,
//         );
//     }
//   }
// }