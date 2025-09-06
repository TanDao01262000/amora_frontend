import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/routine.dart';
import '../models/timeline.dart';
import '../models/calendar.dart';
import '../models/soundscape.dart';
import '../models/location.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  static const String _tokenKey = 'auth_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Initialize token from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  // Save token to storage
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Remove token from storage
  Future<void> _removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Get headers for authenticated requests
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('🔍 API Response Status: ${response.statusCode}');
    print('🔍 API Response Headers: ${response.headers}');
    print('🔍 API Response Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      try {
        final data = json.decode(response.body);
        print('✅ API Success - Parsed Data: $data');
        return data;
      } catch (e) {
        print('❌ Error parsing JSON: $e');
        throw Exception('Invalid response format');
      }
    } else {
      print('❌ API Error - Status: ${response.statusCode}, Body: ${response.body}');
      try {
        final errorData = json.decode(response.body);
        String errorMessage = 'Unknown error';
        
        // Handle different error response formats
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'].toString();
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'].toString();
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'].toString();
        } else if (errorData is Map && errorData.isNotEmpty) {
          // Try to get the first error value
          errorMessage = errorData.values.first.toString();
        }
        
        // Provide user-friendly error messages for common cases
        if (response.statusCode == 400) {
          if (errorMessage.toLowerCase().contains('email')) {
            errorMessage = 'Invalid email address';
          } else if (errorMessage.toLowerCase().contains('password')) {
            errorMessage = 'Invalid password';
          } else if (errorMessage.toLowerCase().contains('username')) {
            errorMessage = 'Username already exists';
          } else if (errorMessage.toLowerCase().contains('user')) {
            errorMessage = 'User already exists with this email';
          }
        } else if (response.statusCode == 401) {
          errorMessage = 'Invalid email or password';
        } else if (response.statusCode == 404) {
          errorMessage = 'User not found';
        } else if (response.statusCode == 422) {
          // Handle validation errors more specifically
          if (errorData['detail'] != null) {
            if (errorData['detail'] is List) {
              // Handle list of validation errors
              final errors = errorData['detail'] as List;
              errorMessage = errors.map((e) => e.toString()).join(', ');
            } else {
              errorMessage = errorData['detail'].toString();
            }
          } else if (errorData['errors'] != null) {
            // Handle field-specific validation errors
            final errors = errorData['errors'] as Map<String, dynamic>;
            errorMessage = errors.values.map((e) => e.toString()).join(', ');
          } else {
            errorMessage = 'Invalid input data. Please check your input and try again.';
          }
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        }
        
        throw Exception(errorMessage);
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }

  // Authentication methods
  Future<AuthResponse> register(RegisterRequest request) async {
    print('🚀 API Call: POST $baseUrl/auth/register');
    print('📤 Request Body: ${json.encode(request.toJson())}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(includeAuth: false),
      body: json.encode(request.toJson()),
    );

    final data = _handleResponse(response);
    final authResponse = AuthResponse.fromJson(data);
    
    print('🔐 Register Response: ${authResponse.toJson()}');
    
    if (authResponse.success && authResponse.data != null) {
      await _saveToken(authResponse.data!.accessToken);
      print('💾 Token saved successfully');
    }
    
    return authResponse;
  }

  Future<AuthResponse> login(LoginRequest request) async {
    print('🚀 API Call: POST $baseUrl/auth/login');
    print('📤 Request Body: ${json.encode(request.toJson())}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(includeAuth: false),
      body: json.encode(request.toJson()),
    );

    final data = _handleResponse(response);
    print('🔐 Raw Login Response: $data');
    final authResponse = AuthResponse.fromJson(data);
    
    print('🔐 Login Response: ${authResponse.toJson()}');
    if (authResponse.data?.user != null) {
      print('🔐 Login User Email: ${authResponse.data!.user.email}');
    }
    
    if (authResponse.success && authResponse.data != null) {
      await _saveToken(authResponse.data!.accessToken);
      print('💾 Token saved successfully');
    }
    
    return authResponse;
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: _getHeaders(),
        );
      } catch (e) {
        // Continue with logout even if API call fails
        print('Logout API call failed: $e');
      }
    }
    await _removeToken();
  }

  Future<User> getProfile() async {
    print('🚀 API Call: GET $baseUrl/users/profile');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    final user = User.fromJson(data['data']);
    
    print('👤 Profile Data: ${user.toJson()}');
    return user;
  }

  Future<User> updateProfile({String? username}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: _getHeaders(),
      body: json.encode({'username': username}),
    );

    final data = _handleResponse(response);
    return User.fromJson(data['data']);
  }

  Future<void> connectWithPartner(String partnerUsername) async {
    print('🚀 API Call: POST $baseUrl/users/connect');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    print('📤 Request Body: ${json.encode(ConnectPartnerRequest(partnerUsername: partnerUsername).toJson())}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/users/connect'),
      headers: _getHeaders(),
      body: json.encode(ConnectPartnerRequest(partnerUsername: partnerUsername).toJson()),
    );

    print('🔍 Connect Partner Response Status: ${response.statusCode}');
    print('🔍 Connect Partner Response Body: ${response.body}');
    _handleResponse(response);
  }

  Future<PartnerInfo> getPartnerInfo() async {
    print('🚀 API Call: GET $baseUrl/users/partner');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/partner'),
      headers: _getHeaders(),
    );

    print('🔍 Get Partner Info Response Status: ${response.statusCode}');
    print('🔍 Get Partner Info Response Body: ${response.body}');
    
    // Handle specific error cases for partner info
    if (response.statusCode == 500) {
      print('❌ Partner info endpoint returned 500 - likely backend issue');
      throw Exception('Partner information is currently unavailable. Please check your connection and try again.');
    } else if (response.statusCode == 404) {
      print('❌ Partner not found via /users/partner endpoint - trying alternative method');
      
      // Try to get partner info by ID as fallback
      try {
        final user = await getProfile();
        if (user.partnerId != null) {
          print('🔄 Trying to get partner info by ID: ${user.partnerId}');
          return await getPartnerInfoById(user.partnerId!);
        }
      } catch (e) {
        print('❌ Alternative method also failed: $e');
      }
      
      throw Exception('No partner found. Please connect with a partner first.');
    }
    
    // Handle the new direct response format (no BaseResponse wrapper)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw Exception('Empty response from partner info endpoint');
      }
      try {
        final data = json.decode(response.body);
        print('✅ Partner Info Success - Parsed Data: $data');
        return PartnerInfo.fromJson(data);
      } catch (e) {
        print('❌ Error parsing partner info JSON: $e');
        throw Exception('Invalid partner info response format');
      }
    } else {
      print('❌ Partner Info API Error - Status: ${response.statusCode}, Body: ${response.body}');
      try {
        final errorData = json.decode(response.body);
        String errorMessage = 'Unknown error';
        
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'].toString();
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'].toString();
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'].toString();
        }
        
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Failed to get partner info: ${response.statusCode}');
      }
    }
  }

  // Alternative method to get partner info by ID
  Future<PartnerInfo> getPartnerInfoById(String partnerId) async {
    print('🚀 API Call: GET $baseUrl/users/$partnerId');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/$partnerId'),
      headers: _getHeaders(),
    );

    print('🔍 Get Partner Info by ID Response Status: ${response.statusCode}');
    print('🔍 Get Partner Info by ID Response Body: ${response.body}');
    
    if (response.statusCode == 404) {
      print('❌ Partner with ID $partnerId not found');
      throw Exception('Partner not found.');
    }

    final data = _handleResponse(response);
    return PartnerInfo.fromJson(data['data']);
  }

  // Routine methods
  Future<List<Routine>> getRoutines() async {
    print('🚀 API Call: GET $baseUrl/routines/');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/routines/'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    print('📋 Raw API Response: $data');
    
    // Handle different response formats
    List<Routine> routines = [];
    
    try {
      if (data['data'] != null && data['data']['routines'] != null) {
        // New format with RoutinesResponse
        final routinesResponse = RoutinesResponse.fromJson(data);
        routines = routinesResponse.data.routines;
        print('📋 Using new response format');
      } else if (data['routines'] != null) {
        // Direct routines array
        final routinesList = data['routines'] as List;
        routines = routinesList.map((json) => Routine.fromJson(json as Map<String, dynamic>)).toList();
        print('📋 Using direct routines format');
      } else if (data is List) {
        // Direct list of routines
        routines = (data as List).map((json) => Routine.fromJson(json as Map<String, dynamic>)).toList();
        print('📋 Using direct list format');
      } else {
        print('❌ Unknown response format: $data');
        throw Exception('Unknown response format');
      }
    } catch (e) {
      print('❌ Error parsing routines: $e');
      print('❌ Raw data: $data');
      rethrow;
    }
    
    print('📋 Number of routines: ${routines.length}');
    
    // Debug each routine
    for (int i = 0; i < routines.length; i++) {
      final routine = routines[i];
      print('📋 Routine $i: ${routine.toJson()}');
    }
    
    return routines;
  }

  Future<Routine> createRoutine(CreateRoutineRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routines/'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );

    final data = _handleResponse(response);
    return Routine.fromJson(data['data']);
  }

  Future<Routine> updateRoutine(String routineId, UpdateRoutineRequest request) async {
    print('🚀 API Call: PUT $baseUrl/routines/$routineId');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    print('📤 Request Body: ${json.encode(request.toJson())}');
    
    final response = await http.put(
      Uri.parse('$baseUrl/routines/$routineId'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );

    print('🔍 Update Routine Response Status: ${response.statusCode}');
    print('🔍 Update Routine Response Body: ${response.body}');
    final data = _handleResponse(response);
    return Routine.fromJson(data['data']);
  }

  Future<Routine> markRoutine(String routineId, String state) async {
    print('🚀 API Call: PATCH $baseUrl/routines/$routineId/mark');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    print('📤 Request Body: ${json.encode({'state': state})}');
    
    final response = await http.patch(
      Uri.parse('$baseUrl/routines/$routineId/mark'),
      headers: _getHeaders(),
      body: json.encode({'state': state}),
    );

    print('🔍 Mark Routine Response Status: ${response.statusCode}');
    print('🔍 Mark Routine Response Body: ${response.body}');
    final data = _handleResponse(response);
    return Routine.fromJson(data['data']);
  }

  Future<Routine> unmarkRoutine(String routineId) async {
    print('🚀 API Call: PATCH $baseUrl/routines/$routineId/unmark');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.patch(
      Uri.parse('$baseUrl/routines/$routineId/unmark'),
      headers: _getHeaders(),
    );

    print('🔍 Unmark Routine Response Status: ${response.statusCode}');
    print('🔍 Unmark Routine Response Body: ${response.body}');
    final data = _handleResponse(response);
    return Routine.fromJson(data['data']);
  }

  // Legacy methods for backward compatibility
  Future<void> completeRoutine(String routineId) async {
    await markRoutine(routineId, 'completed');
  }

  Future<void> uncompleteRoutine(String routineId) async {
    await unmarkRoutine(routineId);
  }

  Future<void> deleteRoutine(String routineId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routines/$routineId'),
      headers: _getHeaders(),
    );

    _handleResponse(response);
  }

  // Timeline methods
  Future<List<TimelineEntry>> getTimeline() async {
    print('🚀 API Call: GET $baseUrl/timeline/');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/timeline/'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    final timelineResponse = TimelineResponse.fromJson(data);
    
    print('📝 Timeline Data: ${timelineResponse.toJson()}');
    print('📝 Number of timeline entries: ${timelineResponse.data.timeline.length}');
    
    return timelineResponse.data.timeline;
  }

  Future<TimelineEntry> createTimelineEntry(CreateTimelineRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/timeline/'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );

    final data = _handleResponse(response);
    return TimelineEntry.fromJson(data['data']);
  }

  Future<TimelineEntry> updateTimelineEntry(String entryId, CreateTimelineRequest request) async {
    final response = await http.put(
      Uri.parse('$baseUrl/timeline/$entryId'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );

    final data = _handleResponse(response);
    return TimelineEntry.fromJson(data['data']);
  }

  Future<void> deleteTimelineEntry(String entryId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/timeline/$entryId'),
      headers: _getHeaders(),
    );

    _handleResponse(response);
  }

  // Like/Unlike timeline entry
  Future<TimelineEntry> likeTimelineEntry(String entryId) async {
    print('🚀 API Call: POST $baseUrl/timeline/$entryId/like');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/timeline/$entryId/like'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    return TimelineEntry.fromJson(data['data']);
  }

  Future<TimelineEntry> unlikeTimelineEntry(String entryId) async {
    print('🚀 API Call: DELETE $baseUrl/timeline/$entryId/like');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/timeline/$entryId/like'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    return TimelineEntry.fromJson(data['data']);
  }

  // Love/Unlove timeline entry
  Future<TimelineEntry> loveTimelineEntry(String entryId) async {
    print('🚀 API Call: POST $baseUrl/timeline/$entryId/love');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/timeline/$entryId/love'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    return TimelineEntry.fromJson(data['data']);
  }

  Future<TimelineEntry> unloveTimelineEntry(String entryId) async {
    print('🚀 API Call: DELETE $baseUrl/timeline/$entryId/love');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/timeline/$entryId/love'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    return TimelineEntry.fromJson(data['data']);
  }

  // Calendar methods
  Future<List<CalendarEvent>> getCalendarEvents() async {
    print('🚀 API Call: GET $baseUrl/calendar/');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/calendar/'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    print('📅 Raw Calendar Response: $data');
    
    // Handle the new API response format
    if (data['success'] == true && data['data'] != null && data['data']['events'] != null) {
      final calendarResponse = CalendarResponse.fromJson(data);
      print('📅 Calendar Data: ${calendarResponse.toJson()}');
      print('📅 Number of events: ${calendarResponse.data.events.length}');
      return calendarResponse.data.events;
    } else {
      print('❌ Unexpected calendar response format: $data');
      throw Exception('Invalid calendar response format');
    }
  }

  Future<CalendarEvent> createCalendarEvent(CreateCalendarEventRequest request) async {
    print('🚀 API Call: POST $baseUrl/calendar/');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    print('📤 Request Body: ${json.encode(request.toJson())}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/calendar/'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );

    final data = _handleResponse(response);
    print('📅 Create Calendar Response: $data');
    
    // Handle the new API response format
    if (data['success'] == true && data['data'] != null) {
      return CalendarEvent.fromJson(data['data']);
    } else {
      print('❌ Unexpected create calendar response format: $data');
      throw Exception('Invalid create calendar response format');
    }
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    print('🚀 API Call: DELETE $baseUrl/calendar/$eventId');
    print('🔑 Using token: ${_token?.substring(0, 20)}...');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/calendar/$eventId'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    print('📅 Delete Calendar Response: $data');
    
    // Handle the new API response format
    if (data['success'] == true) {
      print('✅ Calendar event deleted successfully');
    } else {
      print('❌ Unexpected delete calendar response format: $data');
      throw Exception('Invalid delete calendar response format');
    }
  }

  // Soundscape methods
  Future<List<Soundscape>> getSoundscapes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/soundscapes/'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    final soundscapesResponse = SoundscapesResponse.fromJson(data);
    return soundscapesResponse.data.soundscapes;
  }

  Future<Soundscape> getSoundscape(String soundscapeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/soundscapes/$soundscapeId'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    return Soundscape.fromJson(data['data']);
  }

  Future<Soundscape> createSoundscape(CreateSoundscapeRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/soundscapes/'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );

    final data = _handleResponse(response);
    return Soundscape.fromJson(data['data']);
  }

  Future<void> deleteSoundscape(String soundscapeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/soundscapes/$soundscapeId'),
      headers: _getHeaders(),
    );

    _handleResponse(response);
  }

  // Location methods
  Future<Location> updateLocation(UpdateLocationRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/locations/update'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );

    final data = _handleResponse(response);
    return Location.fromJson(data['data']);
  }

  Future<Location> getMyLocation() async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations/my'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    return Location.fromJson(data['data']);
  }

  Future<Location> getPartnerLocation() async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations/partner'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response);
    return Location.fromJson(data['data']);
  }

  // File upload methods
  Future<Map<String, dynamic>> uploadSoundscape(File file, String title, String note) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/soundscape'),
    );

    request.headers.addAll(_getHeaders());
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['title'] = title;
    request.fields['note'] = note;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadTimelineMedia(File file, String note) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/timeline'),
    );

    request.headers.addAll(_getHeaders());
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['note'] = note;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response);
  }

  Future<void> deleteUploadedFile(String fileType, String filename) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/upload/$fileType/$filename'),
      headers: _getHeaders(),
    );

    _handleResponse(response);
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    final hasToken = _token != null;
    print('🔑 API Service: isAuthenticated check - hasToken: $hasToken, token: ${_token?.substring(0, 20)}...');
    return hasToken;
  }
}
