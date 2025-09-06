import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  final String? details;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.details,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => 
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable()
class ErrorResponse {
  final bool success;
  final String error;
  final String? details;

  ErrorResponse({
    required this.success,
    required this.error,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}
