import 'package:json_annotation/json_annotation.dart';

part 'timeline.g.dart';

@JsonSerializable()
class TimelineEntry {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String note;
  @JsonKey(name: 'media_url')
  final String? mediaUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final int? likes;
  final int? loves;
  @JsonKey(name: 'is_liked')
  final bool? isLiked;
  @JsonKey(name: 'is_loved')
  final bool? isLoved;

  TimelineEntry({
    required this.id,
    required this.userId,
    required this.note,
    this.mediaUrl,
    required this.createdAt,
    this.likes,
    this.loves,
    this.isLiked,
    this.isLoved,
  });

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => _$TimelineEntryFromJson(json);
  Map<String, dynamic> toJson() => _$TimelineEntryToJson(this);
}

@JsonSerializable()
class CreateTimelineRequest {
  final String note;
  @JsonKey(name: 'media_url')
  final String? mediaUrl;

  CreateTimelineRequest({
    required this.note,
    this.mediaUrl,
  });

  factory CreateTimelineRequest.fromJson(Map<String, dynamic> json) => _$CreateTimelineRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTimelineRequestToJson(this);
}

@JsonSerializable()
class TimelineResponse {
  final bool success;
  final String message;
  final TimelineData data;

  TimelineResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TimelineResponse.fromJson(Map<String, dynamic> json) => _$TimelineResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TimelineResponseToJson(this);
}

@JsonSerializable()
class TimelineData {
  final List<TimelineEntry> timeline;

  TimelineData({
    required this.timeline,
  });

  factory TimelineData.fromJson(Map<String, dynamic> json) => _$TimelineDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimelineDataToJson(this);
}
