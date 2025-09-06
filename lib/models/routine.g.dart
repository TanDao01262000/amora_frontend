// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Routine _$RoutineFromJson(Map<String, dynamic> json) => Routine(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  state: json['state'] as String,
  lastCompleted: json['last_completed'] == null
      ? null
      : DateTime.parse(json['last_completed'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RoutineToJson(Routine instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'state': instance.state,
  'last_completed': instance.lastCompleted?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

CreateRoutineRequest _$CreateRoutineRequestFromJson(
  Map<String, dynamic> json,
) => CreateRoutineRequest(
  title: json['name'] as String,
  description: json['description'] as String,
  state: json['state'] as String?,
);

Map<String, dynamic> _$CreateRoutineRequestToJson(
  CreateRoutineRequest instance,
) => <String, dynamic>{
  'name': instance.title,
  'description': instance.description,
  'state': instance.state,
};

UpdateRoutineRequest _$UpdateRoutineRequestFromJson(
  Map<String, dynamic> json,
) => UpdateRoutineRequest(
  title: json['name'] as String?,
  description: json['description'] as String?,
  state: json['state'] as String?,
  lastCompleted: json['last_completed'] as String?,
);

Map<String, dynamic> _$UpdateRoutineRequestToJson(
  UpdateRoutineRequest instance,
) => <String, dynamic>{
  'name': instance.title,
  'description': instance.description,
  'state': instance.state,
  'last_completed': instance.lastCompleted,
};

MarkRoutineRequest _$MarkRoutineRequestFromJson(Map<String, dynamic> json) =>
    MarkRoutineRequest(state: json['state'] as String);

Map<String, dynamic> _$MarkRoutineRequestToJson(MarkRoutineRequest instance) =>
    <String, dynamic>{'state': instance.state};

RoutinesResponse _$RoutinesResponseFromJson(Map<String, dynamic> json) =>
    RoutinesResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: RoutinesData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoutinesResponseToJson(RoutinesResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

RoutinesData _$RoutinesDataFromJson(Map<String, dynamic> json) => RoutinesData(
  routines: (json['routines'] as List<dynamic>)
      .map((e) => Routine.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoutinesDataToJson(RoutinesData instance) =>
    <String, dynamic>{'routines': instance.routines};
