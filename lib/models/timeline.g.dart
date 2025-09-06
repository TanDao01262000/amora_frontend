// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineEntry _$TimelineEntryFromJson(Map<String, dynamic> json) =>
    TimelineEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      note: json['note'] as String,
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      likes: (json['likes'] as num?)?.toInt(),
      loves: (json['loves'] as num?)?.toInt(),
      isLiked: json['is_liked'] as bool?,
      isLoved: json['is_loved'] as bool?,
    );

Map<String, dynamic> _$TimelineEntryToJson(TimelineEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'note': instance.note,
      'media_url': instance.mediaUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'likes': instance.likes,
      'loves': instance.loves,
      'is_liked': instance.isLiked,
      'is_loved': instance.isLoved,
    };

CreateTimelineRequest _$CreateTimelineRequestFromJson(
  Map<String, dynamic> json,
) => CreateTimelineRequest(
  note: json['note'] as String,
  mediaUrl: json['media_url'] as String?,
);

Map<String, dynamic> _$CreateTimelineRequestToJson(
  CreateTimelineRequest instance,
) => <String, dynamic>{'note': instance.note, 'media_url': instance.mediaUrl};

TimelineResponse _$TimelineResponseFromJson(Map<String, dynamic> json) =>
    TimelineResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TimelineData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimelineResponseToJson(TimelineResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

TimelineData _$TimelineDataFromJson(Map<String, dynamic> json) => TimelineData(
  timeline: (json['timeline'] as List<dynamic>)
      .map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TimelineDataToJson(TimelineData instance) =>
    <String, dynamic>{'timeline': instance.timeline};
