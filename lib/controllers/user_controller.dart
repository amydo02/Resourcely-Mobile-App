import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  // Save user profile to Firestore
  Future<bool> saveUserProfile({
    required String userId,
    required String name,
    required String email,
    required String studentId,
    required String major,
    required String year,
    required List<String> interests,
  }) async {
    print('🔵 UserController: Starting saveUserProfile...');
    print('🔵 UserID: $userId');
    
    try {
      final userProfile = {
        'userId': userId,
        'name': name,
        'email': email,
        'studentId': studentId,
        'major': major,
        'year': year,
        'interests': interests,
        'isOnboarded': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('🔵 UserController: Saving to Firestore...');
      await _firestore.collection('users').doc(userId).set(userProfile);
      print('✅ UserController: Firestore save successful');

      // Save to local storage
      print('🔵 UserController: Saving to local storage...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isOnboarded', true);
      await prefs.setString('userId', userId);
      print('✅ UserController: Local storage save successful');

      _currentUser = UserModel(
        id: userId,
        name: name,
        email: email,
        studentId: studentId,
        major: major,
        year: year,
        interests: interests,
      );

      print('✅ UserController: Profile saved successfully');
      return true;
    } catch (e) {
      print('❌ UserController: Error saving user profile: $e');
      print('❌ Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      // First check local storage for faster response
      final prefs = await SharedPreferences.getInstance();
      final localOnboarded = prefs.getBool('isOnboarded') ?? false;
      final localUserId = prefs.getString('userId') ?? '';
      
      // If locally marked as onboarded and userId matches, return true immediately
      if (localOnboarded && localUserId == userId) {
        return true;
      }
      
      // Otherwise check Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data();
        final isOnboarded = data?['isOnboarded'] ?? false;
        
        // Update local storage for next time
        if (isOnboarded) {
          await prefs.setBool('isOnboarded', true);
          await prefs.setString('userId', userId);
        }
        
        return isOnboarded;
      }
      
      return false;
    } catch (e) {
      print('Error checking onboarding status: $e');
      // On error, check local storage as fallback
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isOnboarded') ?? false;
    }
  }

  // Load user profile from Firestore
  Future<UserModel?> loadUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = UserModel(
          id: data['userId'] ?? userId,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          studentId: data['studentId'] ?? '',
          major: data['major'] ?? '',
          year: data['year'] ?? '',
          interests: List<String>.from(data['interests'] ?? []),
        );
        return _currentUser;
      }
      
      return null;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? studentId,
    String? major,
    String? year,
    List<String>? interests,
  }) async {
    print('🔵 UserController: Updating profile for user: $userId');
    
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updates['name'] = name;
        print('🔵 Updating name: $name');
      }
      if (studentId != null) {
        updates['studentId'] = studentId;
        print('🔵 Updating studentId: $studentId');
      }
      if (major != null) {
        updates['major'] = major;
        print('🔵 Updating major: $major');
      }
      if (year != null) {
        updates['year'] = year;
        print('🔵 Updating year: $year');
      }
      if (interests != null) {
        updates['interests'] = interests;
        print('🔵 Updating interests: $interests');
      }

      print('🔵 Updating Firestore document...');
      await _firestore.collection('users').doc(userId).update(updates);
      print('✅ Firestore update successful');

      // Reload user profile to update local cache
      await loadUserProfile(userId);
      print('✅ Profile reloaded from Firestore');

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Get user stats
  Map<String, int> getUserStats() {
    // In a real app, fetch these from Firestore based on user activities
    // For now, return default stats
    return {
      'scholarshipsApplied': 0,
      'eventsAttending': 0,
      'savedResources': 0,
    };
  }

  // Clear user data (for sign out)
  Future<void> clearUser() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Delete user profile (for testing/debugging)
  Future<bool> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      _currentUser = null;
      
      // Also clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      return true;
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }
}