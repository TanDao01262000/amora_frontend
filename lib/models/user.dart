import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String? email;
  @JsonKey(name: 'partner_id')
  final String? partnerId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.partnerId,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response formats
    final success = json['success'] as bool? ?? true; // Default to true if missing
    final message = json['message'] as String;
    final data = json['data'] != null 
        ? AuthData.fromJson(json['data'] as Map<String, dynamic>)
        : null;
    
    return AuthResponse(
      success: success,
      message: message,
      data: data,
    );
  }
  
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class AuthData {
  @JsonKey(name: 'access_token')
  final String accessToken;
  final User user;

  AuthData({
    required this.accessToken,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String username;
  final String password;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class ConnectPartnerRequest {
  @JsonKey(name: 'partner_username')
  final String partnerUsername;

  ConnectPartnerRequest({
    required this.partnerUsername,
  });

  factory ConnectPartnerRequest.fromJson(Map<String, dynamic> json) => _$ConnectPartnerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectPartnerRequestToJson(this);
}

@JsonSerializable()
class PartnerInfo {
  final String id;
  final String email;
  final String username;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
  final DateTime createdAt;

  PartnerInfo({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
  });

  factory PartnerInfo.fromJson(Map<String, dynamic> json) => _$PartnerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PartnerInfoToJson(this);
  
  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    } else {
      throw FormatException('Invalid date format: $value');
    }
  }
}
