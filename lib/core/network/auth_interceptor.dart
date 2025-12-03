import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService secureStorage;
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for auth endpoints
    if (options.path.contains(AppConstants.loginEndpoint) ||
        options.path.contains(AppConstants.refreshTokenEndpoint)) {
      return handler.next(options);
    }

    // Inject access token
    final accessToken = await secureStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        // Try to refresh the token using current access token
        final currentToken = await secureStorage.getAccessToken();
        if (currentToken != null) {
          final response = await dio.post(
            AppConstants.refreshTokenEndpoint,
            options: Options(
              headers: {
                'Authorization': 'Bearer $currentToken',
              },
            ),
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access_token'] as String?;

            if (newAccessToken != null) {
              await secureStorage.saveAccessToken(newAccessToken);

              // Retry the original request with new token
              final requestOptions = err.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              _isRefreshing = false;

              final retryResponse = await dio.fetch(requestOptions);
              return handler.resolve(retryResponse);
            }
          }
        }
      } catch (e) {
        // If refresh fails, clear tokens and redirect to login
        await secureStorage.clearTokens();
        _isRefreshing = false;
        return handler.next(err);
      }

      _isRefreshing = false;
    }

    return handler.next(err);
  }
}
