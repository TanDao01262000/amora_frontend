// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'updated_at': instance.updatedAt.toIso8601String(),
};

UpdateLocationRequest _$UpdateLocationRequestFromJson(
  Map<String, dynamic> json,
) => UpdateLocationRequest(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$UpdateLocationRequestToJson(
  UpdateLocationRequest instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

LocationResponse _$LocationResponseFromJson(Map<String, dynamic> json) =>
    LocationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: LocationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationResponseToJson(LocationResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{'location': instance.location};
