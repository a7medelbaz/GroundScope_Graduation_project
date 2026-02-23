enum ErrorType {
  // Network errors
  noInternet,
  timeout,
  connectionError,
  
  // HTTP errors
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  internalServer,
  
  // Auth errors
  invalidCredentials,
  userNotFound,
  emailAlreadyExists,
  weakPassword,
  invalidEmail,
  sessionExpired,
  emailNotVerified,
  
  // Service specific
  supabaseAuth,
  supabaseDatabase,
  supabaseStorage,
  
  // General
  cancel,
  unknown,
  validation,
}

class ErrorCode {
  // HTTP Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;
  static const int internalServer = 500;
  
  // Local Error Codes
  static const int noInternet = -1;
  static const int timeout = -2;
  static const int cancel = -3;
  static const int unknown = -4;
}