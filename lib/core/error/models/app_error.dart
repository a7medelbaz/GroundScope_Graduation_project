import 'package:easy_localization/easy_localization.dart';
import '../types/error_type.dart';
import 'error_details.dart';

class AppError implements Exception {
  final String messageKey;
  final String? serverMessage;
  final ErrorType type;
  final int? code;
  final String? technicalMessage;
  final ErrorDetails? details;
  final dynamic originalError;

  const AppError({
    required this.messageKey,
    this.serverMessage,
    required this.type,
    this.code,
    this.technicalMessage,
    this.details,
    this.originalError,
  });

  factory AppError.noInternet() {
    return AppError(
      // We pass the translated string immediately to the messageKey
      messageKey: 'errors.no_internet'.tr(),
      type: ErrorType.noInternet,
      code: ErrorCode.noInternet,
    );
  }

  factory AppError.timeout() {
    return AppError(
      messageKey: 'errors.timeout'.tr(),
      type: ErrorType.timeout,
      code: ErrorCode.timeout,
    );
  }

  factory AppError.unauthorized([final String? serverMessage]) {
    return AppError(
      messageKey: 'errors.unauthorized'.tr(),
      serverMessage: serverMessage,
      type: ErrorType.unauthorized,
      code: ErrorCode.unauthorized,
    );
  }

  factory AppError.serverError() {
    return AppError(
      messageKey: 'errors.server_error'.tr(),
      type: ErrorType.internalServer,
      code: ErrorCode.internalServer,
    );
  }

  factory AppError.unknown([final String? technicalMessage]) {
    return AppError(
      messageKey: 'errors.unknown'.tr(),
      type: ErrorType.unknown,
      code: ErrorCode.unknown,
      technicalMessage: technicalMessage,
    );
  }

  String getUserMessage() {
    if (serverMessage != null && serverMessage!.isNotEmpty) {
      return serverMessage!;
    }
    return messageKey; // Already translated via .tr()
  }

  String getTechnicalMessage() {
    return technicalMessage ?? serverMessage ?? messageKey;
  }

  bool get isNetworkError =>
      type == ErrorType.noInternet ||
      type == ErrorType.timeout ||
      type == ErrorType.connectionError;

  bool get isAuthError =>
      type == ErrorType.unauthorized || type == ErrorType.forbidden;

  bool get shouldRetry =>
      isNetworkError || type == ErrorType.timeout || code == 503;

  AppError copyWith({
    final String? messageKey,
    final String? serverMessage,
    final ErrorType? type,
    final int? code,
    final String? technicalMessage,
    final ErrorDetails? details,
    final dynamic originalError,
  }) {
    return AppError(
      messageKey: messageKey ?? this.messageKey,
      serverMessage: serverMessage ?? this.serverMessage,
      type: type ?? this.type,
      code: code ?? this.code,
      technicalMessage: technicalMessage ?? this.technicalMessage,
      details: details ?? this.details,
      originalError: originalError ?? this.originalError,
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, code: $code, message: ${getUserMessage()})';
  }

  Map<String, dynamic> toJson() {
    return {
      'messageKey': messageKey,
      'serverMessage': serverMessage,
      'type': type.toString(),
      'code': code,
      'technicalMessage': technicalMessage,
      'details': details?.toJson(),
    };
  }
}
