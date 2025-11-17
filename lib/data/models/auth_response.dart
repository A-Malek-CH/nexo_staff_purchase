import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  
  final User user;
  
  @JsonKey(name: 'token_type')
  final String? tokenType;
  
  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.tokenType,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
