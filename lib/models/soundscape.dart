import 'package:json_annotation/json_annotation.dart';

part 'soundscape.g.dart';

@JsonSerializable()
class Soundscape {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String title;
  final String note;
  @JsonKey(name: 'audio_url')
  final String? audioUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Soundscape({
    required this.id,
    required this.userId,
    required this.title,
    required this.note,
    this.audioUrl,
    required this.createdAt,
  });

  factory Soundscape.fromJson(Map<String, dynamic> json) => _$SoundscapeFromJson(json);
  Map<String, dynamic> toJson() => _$SoundscapeToJson(this);
}

@JsonSerializable()
class CreateSoundscapeRequest {
  final String title;
  final String note;

  CreateSoundscapeRequest({
    required this.title,
    required this.note,
  });

  factory CreateSoundscapeRequest.fromJson(Map<String, dynamic> json) => _$CreateSoundscapeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSoundscapeRequestToJson(this);
}

@JsonSerializable()
class SoundscapesResponse {
  final bool success;
  final String message;
  final SoundscapesData data;

  SoundscapesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SoundscapesResponse.fromJson(Map<String, dynamic> json) => _$SoundscapesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SoundscapesResponseToJson(this);
}

@JsonSerializable()
class SoundscapesData {
  final List<Soundscape> soundscapes;

  SoundscapesData({
    required this.soundscapes,
  });

  factory SoundscapesData.fromJson(Map<String, dynamic> json) => _$SoundscapesDataFromJson(json);
  Map<String, dynamic> toJson() => _$SoundscapesDataToJson(this);
}
