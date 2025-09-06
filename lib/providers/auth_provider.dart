import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  bool _isLoadingPartnerInfo = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _apiService.isAuthenticated;

  // Initialize auth state - optimized for speed
  Future<void> initialize() async {
    print('🔧 AuthProvider: Initializing...');
    try {
      await _apiService.initialize();
      print('🔧 AuthProvider: API service initialized');
      
      // Clear user data if no valid token
      if (!_apiService.isAuthenticated) {
        print('🔧 AuthProvider: No valid token, clearing user data');
        _user = null;
        notifyListeners();
      }
      
      if (_apiService.isAuthenticated) {
        print('🔧 AuthProvider: User is authenticated, loading profile in background...');
        // Load profile in background to avoid blocking initialization
        _loadUserProfileInBackground();
      } else {
        print('🔧 AuthProvider: User is not authenticated');
      }
    } catch (e) {
      print('❌ AuthProvider: Initialization failed: $e');
      _setError('Failed to initialize authentication: $e');
    }
    print('🔧 AuthProvider: Initialization complete');
  }

  // Load user profile in background without blocking initialization
  Future<void> _loadUserProfileInBackground() async {
    try {
      await loadUserProfile();
      print('🔧 AuthProvider: Background profile load complete');
    } catch (e) {
      print('❌ AuthProvider: Background profile load failed: $e');
      // Don't set error here as it's background loading
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    print('🔐 AuthProvider: Starting login for $email');
    _setLoading(true);
    _clearError();
    
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);
      
      print('🔐 AuthProvider: Login response received: ${response.success}');
      
      if (response.success && response.data != null) {
        _user = response.data!.user;
        print('🔐 AuthProvider: User logged in successfully: ${_user?.username}');
        print('🔐 AuthProvider: User data from login: ${_user?.toJson()}');
        print('🔐 AuthProvider: Login email: ${_user?.email}');
        
        // If the login response doesn't include email, use the email from the login form
        if (_user?.email == null) {
          _user = User(
            id: _user!.id,
            username: _user!.username,
            email: email, // Use the email from the login form
            partnerId: _user!.partnerId,
            createdAt: _user!.createdAt,
          );
          print('🔐 AuthProvider: Using email from login form: $email');
        }
        
        // Load complete profile to get partner_id and other fields
        await loadUserProfile();
        print('🔐 AuthProvider: Complete user data after profile load: ${_user?.toJson()}');
        print('🔐 AuthProvider: Final email: ${_user?.email}');
        
        // startPartnerRefresh(); // Temporarily disabled to stop continuous requests
        notifyListeners();
        return true;
      } else {
        print('❌ AuthProvider: Login failed: ${response.message}');
        _setError('Login failed: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ AuthProvider: Login exception: $e');
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
      print('🔐 AuthProvider: Login process complete');
    }
  }

  // Register user
  Future<bool> register(String email, String username, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final request = RegisterRequest(
        email: email,
        username: username,
        password: password,
      );
      final response = await _apiService.register(request);
      
      if (response.success) {
        // Registration successful, but user needs to login separately
        // since registration doesn't return user data
        print('🔐 AuthProvider: Registration successful: ${response.message}');
        return true;
      } else {
        _setError('Registration failed: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      stopPartnerRefresh(); // Stop auto-refresh timer
      await _apiService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    try {
      print('🔄 AuthProvider: Loading user profile...');
      final profileUser = await _apiService.getProfile();
      print('🔄 AuthProvider: Profile loaded - partnerId: ${profileUser.partnerId}');

      // Preserve email from login response if profile doesn't have it
      final preservedEmail = _user?.email;
      final oldPartnerId = _user?.partnerId;
      _user = profileUser;

      // If the profile user doesn't have an email but we have one from login, preserve it
      if (_user?.email == null && preservedEmail != null) {
        _user = User(
          id: _user!.id,
          username: _user!.username,
          email: preservedEmail,
          partnerId: _user!.partnerId,
          createdAt: _user!.createdAt,
        );
        print('🔄 AuthProvider: Preserved email from login: $preservedEmail');
      }

      // If partner ID changed, automatically load partner info
      if (_user?.partnerId != oldPartnerId) {
        print('🔄 AuthProvider: Partner ID changed, will load partner info on next request');
        // Don't clear cache here, let getPartnerInfo() handle it based on partner ID change
      }

      print('🔄 AuthProvider: User updated - partnerId: ${_user?.partnerId}, email: ${_user?.email}');
      notifyListeners();
    } catch (e) {
      print('❌ AuthProvider: Failed to load user profile: $e');
      _setError('Failed to load user profile: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile({String? username}) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _apiService.updateProfile(username: username);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Connect with partner
  Future<bool> connectWithPartner(String partnerUsername) async {
    print('🔗 AuthProvider: Starting partner connection with username: $partnerUsername');
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.connectWithPartner(partnerUsername);
      print('🔗 AuthProvider: Partner connection API call successful');
      
      // Clear partner info cache since partner has changed
      clearPartnerInfoCache();
      
      await loadUserProfile(); // Reload to get updated partner info
      print('🔗 AuthProvider: User profile reloaded after partner connection');
      return true;
    } catch (e) {
      print('🔗 AuthProvider: Partner connection failed: $e');
      _setError('Failed to connect with partner: $e');
      return false;
    } finally {
      _setLoading(false);
      print('🔗 AuthProvider: Partner connection process complete');
    }
  }

  // Cached partner info - only loaded when partner status changes
  PartnerInfo? _cachedPartnerInfo;
  String? _lastPartnerId; // Track partner ID to detect changes

  // Get partner info - only loads if partner ID changed or not cached
  Future<PartnerInfo?> getPartnerInfo({bool forceRefresh = false}) async {
    final currentPartnerId = _user?.partnerId;
    
    // If no partner, clear cache and return null
    if (currentPartnerId == null) {
      if (_cachedPartnerInfo != null) {
        _cachedPartnerInfo = null;
        _lastPartnerId = null;
        print('🔍 AuthProvider: No partner, cleared partner info cache');
      }
      return null;
    }

    // If partner ID hasn't changed and we have cached data, return it
    if (!forceRefresh && 
        _cachedPartnerInfo != null && 
        _lastPartnerId == currentPartnerId) {
      print('🔍 AuthProvider: Returning cached partner info: ${_cachedPartnerInfo!.username}');
      return _cachedPartnerInfo;
    }

    // If partner ID changed or force refresh, load new partner info
    if (_lastPartnerId != currentPartnerId) {
      print('🔍 AuthProvider: Partner ID changed from $_lastPartnerId to $currentPartnerId, loading new partner info');
    }

    // Prevent multiple simultaneous calls
    if (_isLoadingPartnerInfo) {
      print('🔍 AuthProvider: Partner info request already in progress, skipping...');
      return _cachedPartnerInfo; // Return cached data if available
    }

    try {
      _isLoadingPartnerInfo = true;
      print('🔍 AuthProvider: Getting partner info...');
      final partnerInfo = await _apiService.getPartnerInfo();
      
      // Cache the result and update partner ID
      _cachedPartnerInfo = partnerInfo;
      _lastPartnerId = currentPartnerId;
      
      print('🔍 AuthProvider: Partner info received and cached: ${partnerInfo.username} (${partnerInfo.email})');
      return partnerInfo;
    } catch (e) {
      print('❌ AuthProvider: Failed to get partner info: $e');
      
      // If partner not found (404), create a placeholder partner info
      if (e.toString().contains('No partner found') || e.toString().contains('Partner not found')) {
        print('⚠️ AuthProvider: Partner info endpoint returned 404 - creating placeholder partner info');
        print('⚠️ AuthProvider: Partner relationship exists (timeline shows partner entries) but info endpoint is broken');
        
        // Use a more descriptive placeholder name
        String partnerName = 'My Partner';
        
        // Create a placeholder partner info since we know the partner exists
        final placeholderPartner = PartnerInfo(
          id: currentPartnerId,
          email: 'partner@example.com', // Placeholder email
          username: partnerName, // Use better placeholder name
          createdAt: DateTime.now(),
        );
        
        _cachedPartnerInfo = placeholderPartner;
        _lastPartnerId = currentPartnerId;
        
        print('🔍 AuthProvider: Created placeholder partner info for ID: $currentPartnerId with name: $partnerName');
        return placeholderPartner;
      }
      
      _setError('Failed to get partner info: $e');
      return _cachedPartnerInfo; // Return cached data if available
    } finally {
      _isLoadingPartnerInfo = false;
    }
  }

  // Clear partner info cache (called when partner disconnects)
  void clearPartnerInfoCache() {
    _cachedPartnerInfo = null;
    _lastPartnerId = null;
    print('🔍 AuthProvider: Partner info cache cleared');
  }

  // Update partner name (useful when we get the name from other sources)
  void updatePartnerName(String name) {
    if (_cachedPartnerInfo != null) {
      _cachedPartnerInfo = PartnerInfo(
        id: _cachedPartnerInfo!.id,
        email: _cachedPartnerInfo!.email,
        username: name,
        createdAt: _cachedPartnerInfo!.createdAt,
      );
      print('🔍 AuthProvider: Updated partner name to: $name');
      notifyListeners();
    }
  }

  // Get cached partner info synchronously
  PartnerInfo? get cachedPartnerInfo => _cachedPartnerInfo;

  // Clear orphaned partner reference (when partner not found)
  void clearOrphanedPartnerReference() {
    if (_user?.partnerId != null) {
      print('🔧 AuthProvider: Clearing orphaned partner reference');
      _user = User(
        id: _user!.id,
        username: _user!.username,
        email: _user!.email,
        partnerId: null,
        createdAt: _user!.createdAt,
      );
      _cachedPartnerInfo = null;
      _lastPartnerId = null;
      notifyListeners();
    }
  }

  // Disconnect from partner
  Future<bool> disconnectPartner() async {
    print('🔗 AuthProvider: Disconnecting from partner...');
    _setLoading(true);
    _clearError();
    
    try {
      // Call API to disconnect (if you have this endpoint)
      // await _apiService.disconnectPartner();
      
      // For now, just clear the partner ID from user profile
      if (_user != null) {
        _user = User(
          id: _user!.id,
          username: _user!.username,
          email: _user!.email,
          partnerId: null, // Clear partner ID
          createdAt: _user!.createdAt,
        );
      }
      
      // Clear partner info cache
      clearPartnerInfoCache();
      
      print('🔗 AuthProvider: Partner disconnected successfully');
      notifyListeners();
      return true;
    } catch (e) {
      print('🔗 AuthProvider: Partner disconnection failed: $e');
      _setError('Failed to disconnect from partner: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Start auto-refresh for partner connection status
  void startPartnerRefresh() {
    print('🔄 AuthProvider: Starting partner refresh timer');
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_user != null) {
        _refreshUserProfile();
      }
    });
  }

  // Stop auto-refresh
  void stopPartnerRefresh() {
    print('🔄 AuthProvider: Stopping partner refresh timer');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Refresh user profile (for auto-refresh)
  Future<void> _refreshUserProfile() async {
    try {
      print('🔄 AuthProvider: Auto-refreshing user profile...');
      await loadUserProfile();
    } catch (e) {
      print('❌ AuthProvider: Auto-refresh failed: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Clean up resources
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
