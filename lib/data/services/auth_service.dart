import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: LoginRequest(email: email, password: password).toJson(),
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> refreshToken(String currentToken) async {
    try {
      final response = await _dio.post(
        AppConstants.refreshTokenEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentToken',
          },
        ),
      );

      // Backend returns { message, access_token } - need to construct AuthResponse
      // Note: This method is not used in practice. Token refresh is handled by
      // AuthInterceptor which calls the API directly. The placeholder User data
      // here is acceptable since this response is not utilized.
      final data = response.data;
      return AuthResponse(
        accessToken: data['access_token'],
        refreshToken: null,
        user: User(
          id: '',
          email: '',
          fullname: '',
          role: '',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(AppConstants.logoutEndpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'An error occurred: ${error.response!.statusMessage}';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    }
    return 'An unexpected error occurred.';
  }
}
