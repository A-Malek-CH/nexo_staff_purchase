import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/services/firebase_service.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/fcm_token_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(authServiceProvider),
    ref.read(secureStorageServiceProvider),
    ref.read(fcmTokenServiceProvider),
  );
});

class AuthRepository {
  final AuthService _authService;
  final SecureStorageService _secureStorage;
  final FcmTokenService _fcmTokenService;

  AuthRepository(this._authService, this._secureStorage, this._fcmTokenService);

  Future<User> login(String email, String password) async {
    final authResponse = await _authService.login(email, password);
    
    // Save tokens and user data
    await _secureStorage.saveAccessToken(authResponse.accessToken);
    if (authResponse.refreshToken != null) {
      await _secureStorage.saveRefreshToken(authResponse.refreshToken!);
    }
    await _secureStorage.saveUserData(jsonEncode(authResponse.user.toJson()));
    await _secureStorage.setLoggedIn(true);
    
    // Register FCM token after successful login
    try {
      final fcmToken = await FirebaseService.getToken();
      if (fcmToken != null) {
        await _fcmTokenService.registerToken(fcmToken);
      }
    } catch (e) {
      // Log error but don't fail login - notifications are optional
      debugPrint('Failed to register FCM token during login: $e');
    }
    
    return authResponse.user;
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  Future<bool> isLoggedIn() async {
    return await _secureStorage.isLoggedIn();
  }

  Future<User?> getCurrentUser() async {
    final userData = await _secureStorage.getUserData();
    if (userData == null) return null;
    
    try {
      final userMap = jsonDecode(userData) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  Future<void> refreshToken() async {
    final currentToken = await _secureStorage.getAccessToken();
    if (currentToken == null) {
      throw Exception('No access token available');
    }

    final authResponse = await _authService.refreshToken(currentToken);
    
    await _secureStorage.saveAccessToken(authResponse.accessToken);
    // Note: The new authentication flow uses the current access token for refreshing.
    // No refresh token storage is needed.
  }
}
