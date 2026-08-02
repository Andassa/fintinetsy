import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isOffline = false});

  final String message;
  final int? statusCode;
  final bool isOffline;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timed out. Check your network and try again.',
          isOffline: true,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'No internet connection. Showing cached data when available.',
          isOffline: true,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String msg = 'Request failed';
        if (data is Map && data['message'] is String) {
          msg = data['message'] as String;
        } else if (status == 401) {
          msg = 'Please sign in again.';
        } else if (status == 404) {
          msg = 'Resource not found.';
        } else if (status == 429) {
          msg = 'Too many attempts. Wait a moment and retry.';
        }
        return ApiException(msg, statusCode: status);
      default:
        return ApiException('Unexpected network error.');
    }
  }

  @override
  String toString() => message;
}
