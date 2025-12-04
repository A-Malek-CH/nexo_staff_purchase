import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';

final fcmTokenServiceProvider = Provider<FcmTokenService>((ref) {
  return FcmTokenService(ref.read(dioProvider));
});

class FcmTokenService {
  final Dio _dio;
  
  FcmTokenService(this._dio);
  
  /// Send FCM token to backend
  Future<void> registerToken(String fcmToken) async {
    try {
      await _dio.put(
        '${AppConstants.authEndpoint}/fcm-token',
        data: {'fcmToken': fcmToken},
      );
    } on DioException catch (e) {
      // Log error but don't crash - notifications are optional
      debugPrint('Failed to register FCM token: ${e.message}');
    }
  }
}
