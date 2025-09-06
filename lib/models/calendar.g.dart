// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    CalendarEvent(
      id: json['id'] as String,
      relationshipId: json['relationship_id'] as String,
      eventName: json['event_name'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CalendarEventToJson(CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'relationship_id': instance.relationshipId,
      'event_name': instance.eventName,
      'event_date': instance.eventDate.toIso8601String(),
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

CreateCalendarEventRequest _$CreateCalendarEventRequestFromJson(
  Map<String, dynamic> json,
) => CreateCalendarEventRequest(
  eventName: json['event_name'] as String,
  eventDate: json['event_date'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$CreateCalendarEventRequestToJson(
  CreateCalendarEventRequest instance,
) => <String, dynamic>{
  'event_name': instance.eventName,
  'event_date': instance.eventDate,
  'description': instance.description,
};

CalendarResponse _$CalendarResponseFromJson(Map<String, dynamic> json) =>
    CalendarResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: CalendarData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CalendarResponseToJson(CalendarResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

CalendarData _$CalendarDataFromJson(Map<String, dynamic> json) => CalendarData(
  events: (json['events'] as List<dynamic>)
      .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CalendarDataToJson(CalendarData instance) =>
    <String, dynamic>{'events': instance.events};
