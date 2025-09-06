// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soundscape.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Soundscape _$SoundscapeFromJson(Map<String, dynamic> json) => Soundscape(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  note: json['note'] as String,
  audioUrl: json['audio_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SoundscapeToJson(Soundscape instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'note': instance.note,
      'audio_url': instance.audioUrl,
      'created_at': instance.createdAt.toIso8601String(),
    };

CreateSoundscapeRequest _$CreateSoundscapeRequestFromJson(
  Map<String, dynamic> json,
) => CreateSoundscapeRequest(
  title: json['title'] as String,
  note: json['note'] as String,
);

Map<String, dynamic> _$CreateSoundscapeRequestToJson(
  CreateSoundscapeRequest instance,
) => <String, dynamic>{'title': instance.title, 'note': instance.note};

SoundscapesResponse _$SoundscapesResponseFromJson(Map<String, dynamic> json) =>
    SoundscapesResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: SoundscapesData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SoundscapesResponseToJson(
  SoundscapesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

SoundscapesData _$SoundscapesDataFromJson(Map<String, dynamic> json) =>
    SoundscapesData(
      soundscapes: (json['soundscapes'] as List<dynamic>)
          .map((e) => Soundscape.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SoundscapesDataToJson(SoundscapesData instance) =>
    <String, dynamic>{'soundscapes': instance.soundscapes};
