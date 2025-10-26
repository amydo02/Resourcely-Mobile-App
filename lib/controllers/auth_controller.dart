import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'user_controller.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '261982251751-aj78e3isfj05uil628tqrqn0gre3gm9m.apps.googleusercontent.com',
  );
  final UserController _userController = UserController();

  UserModel? _currentUser;
  //Map<String, dynamic>? _cachedSignInStatus; // Cache for sign-in status

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Sign in with Google (SJSU email only)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Sign in cancelled',
          'needsOnboarding': false,
          'userId': '',
          'email': '',
          'displayName': null,
        };
      }

      // Check if email is from SJSU domain
      if (!googleUser.email.endsWith('@sjsu.edu')) {
        await _googleSignIn.signOut();
        return {
          'success': false,
          'message': 'Please use your @sjsu.edu email address',
          'needsOnboarding': false,
          'userId': '',
          'email': '',
          'displayName': null,
        };
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Check if user has completed onboarding
        final hasOnboarded = await _userController.hasCompletedOnboarding(firebaseUser.uid);
        
        if (hasOnboarded) {
          // Load existing user profile
          _currentUser = await _userController.loadUserProfile(firebaseUser.uid);
          
          return {
            'success': true,
            'message': 'Welcome back ${_currentUser?.name ?? 'SJSU Student'}!',
            'needsOnboarding': false,
            'userId': firebaseUser.uid,
            'email': firebaseUser.email ?? '',
            'displayName': firebaseUser.displayName,
          };
        } else {
          // New user needs onboarding
          return {
            'success': true,
            'message': 'Account created successfully!',
            'needsOnboarding': true,
            'userId': firebaseUser.uid,
            'email': firebaseUser.email ?? '',
            'displayName': firebaseUser.displayName,
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to authenticate with Firebase',
        'needsOnboarding': false,
        'userId': '',
        'email': '',
        'displayName': null,
      };
    } catch (e) {
      print('Google Sign-In Error: $e');
      return {
        'success': false,
        'message': 'Sign in failed: ${e.toString()}',
        'needsOnboarding': false,
        'userId': '',
        'email': '',
        'displayName': null,
      };
    }
  }

  // Extract student ID from email (e.g., john.doe@sjsu.edu -> john.doe)
 

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Check if user is already signed in
  Future<Map<String, dynamic>> checkSignInStatus() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null && firebaseUser.email?.endsWith('@sjsu.edu') == true) {
        // Check if user has completed onboarding
        final hasOnboarded = await _userController.hasCompletedOnboarding(firebaseUser.uid);
        
        if (hasOnboarded) {
          _currentUser = await _userController.loadUserProfile(firebaseUser.uid);
          return {
            'isSignedIn': true,
            'needsOnboarding': false,
            'userId': firebaseUser.uid,
            'email': firebaseUser.email ?? '',
            'displayName': firebaseUser.displayName,
          };
        } else {
          return {
            'isSignedIn': true,
            'needsOnboarding': true,
            'userId': firebaseUser.uid,
            'email': firebaseUser.email ?? '',
            'displayName': firebaseUser.displayName,
          };
        }
      }
      return {
        'isSignedIn': false,
        'needsOnboarding': false,
        'userId': '',
        'email': '',
        'displayName': null,
      };
    } catch (e) {
      print('Check sign in status error: $e');
      return {
        'isSignedIn': false,
        'needsOnboarding': false,
        'userId': '',
        'email': '',
        'displayName': null,
      };
    }
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@sjsu\.edu$').hasMatch(email);
  }
}