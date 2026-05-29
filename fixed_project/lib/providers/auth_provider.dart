import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';

/// AuthProvider manages user authentication state
/// Handles login, registration, logout, and user profile management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // Timeout constants
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const Duration _firebaseTimeout = Duration(seconds: 15);

  // Getters
  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Initialize auth state listener
  void initialize() {
    if (_isInitialized) return;

    _authService.authStateChanges.listen(
      (user) {
        _currentUser = user;
        if (user != null) {
          // Load profile asynchronously - _isInitialized will be set after profile loads
          _loadUserProfile(user.uid);
        } else {
          _userProfile = null;
          _isInitialized = true;
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Error in auth state listener: $error');
        _error = 'Authentication error: ${error.toString()}';
        _isInitialized = true;
        notifyListeners();
      },
    );
    
    // Add timeout to ensure initialization completes even if no auth state received
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isInitialized) {
        debugPrint('Auth initialization timeout - marking as initialized');
        _isInitialized = true;
        notifyListeners();
      }
    });
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService
          .signIn(email, password)
          .timeout(_firebaseTimeout);
      _currentUser = user;

      if (user != null) {
        await _loadUserProfile(user.uid);
      }

      _error = null;
      return true;
    } on TimeoutException {
      _error = 'Login took too long. Please check your connection';
      _currentUser = null;
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _currentUser = null;
      return false;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register new user with email and password
  Future<bool> register(
      String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService
          .register(
            email,
            password,
            displayName: displayName,
          )
          .timeout(_firebaseTimeout);

      if (user != null) {
        _currentUser = user;

        // Create user profile in Firestore
        final profile = UserProfile(
          uid: user.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService
            .saveUserProfile(profile)
            .timeout(_defaultTimeout);
        _userProfile = profile;
      }

      _error = null;
      return true;
    } on TimeoutException {
      _error = 'Registration took too long. Please check your connection';
      _currentUser = null;
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _currentUser = null;
      return false;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout().timeout(_defaultTimeout);
      _currentUser = null;
      _userProfile = null;
      _error = null;
    } on TimeoutException {
      _error = 'Logout took too long';
      print('Logout timeout: $_error');
    } catch (e) {
      _error = e.toString();
      print('Error logging out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? shippingAddress,
    String? city,
    String? postalCode,
    String? country,
  }) async {
    if (_currentUser == null || _userProfile == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update Firebase Auth display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await _currentUser!
            .updateDisplayName(displayName)
            .timeout(_defaultTimeout);
      }

      // Update Firestore profile
      final updatedProfile = _userProfile!.copyWith(
        displayName: displayName,
        phoneNumber: phoneNumber,
        shippingAddress: shippingAddress,
        city: city,
        postalCode: postalCode,
        country: country,
      );

      await _firestoreService
          .saveUserProfile(updatedProfile)
          .timeout(_defaultTimeout);
      _userProfile = updatedProfile;

      _error = null;
      return true;
    } on TimeoutException {
      _error = 'Update took too long. Please check your connection';
      return false;
    } catch (e) {
      _error = e.toString();
      print('Error updating profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await _firestoreService
          .fetchUserProfile(userId)
          .timeout(_defaultTimeout);
      
      if (profile != null) {
        _userProfile = profile;
      } else {
        // Create default profile if doesn't exist
        _userProfile = UserProfile(
          uid: userId,
          email: _currentUser?.email ?? '',
          displayName: _currentUser?.displayName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestoreService
            .saveUserProfile(_userProfile!)
            .timeout(_defaultTimeout);
      }
    } on TimeoutException {
      debugPrint('Profile fetch timeout for user: $userId');
      // Create minimal profile to prevent blocking
      _userProfile = UserProfile(
        uid: userId,
        email: _currentUser?.email ?? '',
        displayName: _currentUser?.displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      _error = e.toString();
      // Create minimal profile to prevent blocking
      _userProfile = UserProfile(
        uid: userId,
        email: _currentUser?.email ?? '',
        displayName: _currentUser?.displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Get user-friendly error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'User account is disabled';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
