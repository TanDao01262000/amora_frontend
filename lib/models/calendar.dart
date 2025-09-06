import 'package:json_annotation/json_annotation.dart';

part 'calendar.g.dart';

@JsonSerializable()
class CalendarEvent {
  final String id;
  @JsonKey(name: 'relationship_id')
  final String relationshipId;
  @JsonKey(name: 'event_name')
  final String eventName;
  @JsonKey(name: 'event_date')
  final DateTime eventDate;
  final String description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  CalendarEvent({
    required this.id,
    required this.relationshipId,
    required this.eventName,
    required this.eventDate,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => _$CalendarEventFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);
}

@JsonSerializable()
class CreateCalendarEventRequest {
  @JsonKey(name: 'event_name')
  final String eventName;
  @JsonKey(name: 'event_date')
  final String eventDate; // Format: "2024-02-14"
  final String? description;

  CreateCalendarEventRequest({
    required this.eventName,
    required this.eventDate,
    this.description,
  });

  factory CreateCalendarEventRequest.fromJson(Map<String, dynamic> json) => _$CreateCalendarEventRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCalendarEventRequestToJson(this);
}

@JsonSerializable()
class CalendarResponse {
  final bool success;
  final String message;
  final CalendarData data;

  CalendarResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CalendarResponse.fromJson(Map<String, dynamic> json) => _$CalendarResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarResponseToJson(this);
}

@JsonSerializable()
class CalendarData {
  final List<CalendarEvent> events;

  CalendarData({
    required this.events,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) => _$CalendarDataFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarDataToJson(this);
}
