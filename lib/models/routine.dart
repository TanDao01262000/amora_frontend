import 'package:json_annotation/json_annotation.dart';

part 'routine.g.dart';

enum RoutineState { pending, completed, skipped }

@JsonSerializable()
class Routine {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'title')
  final String title;
  final String description;
  @JsonKey(name: 'state')
  final String state;
  @JsonKey(name: 'last_completed')
  final DateTime? lastCompleted;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Routine({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.state,
    this.lastCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getter for backward compatibility
  String get name => title;

  // Helper getter for state enum
  RoutineState get stateEnum {
    switch (state.toLowerCase()) {
      case 'completed':
        return RoutineState.completed;
      case 'skipped':
        return RoutineState.skipped;
      case 'pending':
      default:
        return RoutineState.pending;
    }
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    // Handle both old and new field names for backward compatibility
    final title = json['title'] ?? json['name'] ?? '';
    final state = json['state'] ?? 'pending';
    final updatedAt = json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'] as String)
        : DateTime.parse(json['created_at'] as String);
    
    return Routine(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: title,
      description: json['description'] as String,
      state: state,
      lastCompleted: json['last_completed'] == null
          ? null
          : DateTime.parse(json['last_completed'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: updatedAt,
    );
  }
  
  Map<String, dynamic> toJson() => _$RoutineToJson(this);
}

@JsonSerializable()
class CreateRoutineRequest {
  @JsonKey(name: 'name')
  final String title;
  final String description;
  final String? state;

  CreateRoutineRequest({
    required this.title,
    required this.description,
    this.state,
  });

  factory CreateRoutineRequest.fromJson(Map<String, dynamic> json) => _$CreateRoutineRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateRoutineRequestToJson(this);
}

@JsonSerializable()
class UpdateRoutineRequest {
  @JsonKey(name: 'name')
  final String? title;
  final String? description;
  final String? state;
  @JsonKey(name: 'last_completed')
  final String? lastCompleted;

  UpdateRoutineRequest({
    this.title,
    this.description,
    this.state,
    this.lastCompleted,
  });

  factory UpdateRoutineRequest.fromJson(Map<String, dynamic> json) => _$UpdateRoutineRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateRoutineRequestToJson(this);
}

@JsonSerializable()
class MarkRoutineRequest {
  final String state;

  MarkRoutineRequest({
    required this.state,
  });

  factory MarkRoutineRequest.fromJson(Map<String, dynamic> json) => _$MarkRoutineRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MarkRoutineRequestToJson(this);
}

@JsonSerializable()
class RoutinesResponse {
  final bool success;
  final String message;
  final RoutinesData data;

  RoutinesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RoutinesResponse.fromJson(Map<String, dynamic> json) => _$RoutinesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RoutinesResponseToJson(this);
}

@JsonSerializable()
class RoutinesData {
  final List<Routine> routines;

  RoutinesData({
    required this.routines,
  });

  factory RoutinesData.fromJson(Map<String, dynamic> json) => _$RoutinesDataFromJson(json);
  Map<String, dynamic> toJson() => _$RoutinesDataToJson(this);
}
