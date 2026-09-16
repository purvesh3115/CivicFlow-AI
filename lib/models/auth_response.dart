import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;
  final UserModel? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
    };
  }
}
