import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Location({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class UpdateLocationRequest {
  final double latitude;
  final double longitude;

  UpdateLocationRequest({
    required this.latitude,
    required this.longitude,
  });

  factory UpdateLocationRequest.fromJson(Map<String, dynamic> json) => _$UpdateLocationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateLocationRequestToJson(this);
}

@JsonSerializable()
class LocationResponse {
  final bool success;
  final String message;
  final LocationData data;

  LocationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) => _$LocationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LocationResponseToJson(this);
}

@JsonSerializable()
class LocationData {
  final Location location;

  LocationData({
    required this.location,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}
