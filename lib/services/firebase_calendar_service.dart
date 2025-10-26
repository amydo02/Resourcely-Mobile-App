import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseCalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get user document reference
  DocumentReference? get _userDoc {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId);
  }

  // Save Canvas feed URL to Firestore
  Future<void> saveCanvasFeedUrl(String feedUrl) async {
    if (_userDoc == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _userDoc!.set({
        'canvasFeedUrl': feedUrl,
        'isCanvasLinked': true,
        'lastCanvasSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Canvas feed URL saved to Firestore');
    } catch (e) {
      print('❌ Error saving Canvas feed URL: $e');
      rethrow;
    }
  }

  // Load Canvas feed URL from Firestore
  Future<Map<String, dynamic>?> loadCanvasFeedUrl() async {
    if (_userDoc == null) {
      throw Exception('User not authenticated');
    }

    try {
      final doc = await _userDoc!.get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('canvasFeedUrl')) {
          print('✅ Canvas feed URL loaded from Firestore');
          return {
            'feedUrl': data['canvasFeedUrl'],
            'isLinked': data['isCanvasLinked'] ?? false,
          };
        }
      }
      
      print('ℹ️ No Canvas feed URL found in Firestore');
      return null;
    } catch (e) {
      print('❌ Error loading Canvas feed URL: $e');
      return null;
    }
  }

  // Save Canvas assignments to Firestore
  Future<void> saveCanvasAssignments(Map<DateTime, List<Map<String, dynamic>>> assignments) async {
    if (_userDoc == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Convert DateTime keys to ISO strings for Firestore
      Map<String, dynamic> assignmentsData = {};
      assignments.forEach((date, assignmentsList) {
        assignmentsData[date.toIso8601String()] = assignmentsList;
      });

      await _userDoc!.set({
        'canvasAssignments': assignmentsData,
        'lastAssignmentUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      final total = assignments.values.fold(0, (sum, list) => sum + list.length);
      print('✅ Saved $total Canvas assignments to Firestore');
    } catch (e) {
      print('❌ Error saving Canvas assignments: $e');
      rethrow;
    }
  }

  // Load Canvas assignments from Firestore
  Future<Map<String, dynamic>?> loadCanvasAssignments() async {
    if (_userDoc == null) {
      throw Exception('User not authenticated');
    }

    try {
      final doc = await _userDoc!.get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('canvasAssignments')) {
          print('✅ Canvas assignments loaded from Firestore');
          return data['canvasAssignments'] as Map<String, dynamic>;
        }
      }
      
      print('ℹ️ No Canvas assignments found in Firestore');
      return null;
    } catch (e) {
      print('❌ Error loading Canvas assignments: $e');
      return null;
    }
  }

  // Save tasks to Firestore
  Future<void> saveTasks(Map<DateTime, List<Map<String, dynamic>>> tasks) async {
    if (_userDoc == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Convert DateTime keys to ISO strings for Firestore
      Map<String, dynamic> tasksData = {};
      tasks.forEach((date, tasksList) {
        tasksData[date.toIso8601String()] = tasksList;
      });

      await _userDoc!.set({
        'tasks': tasksData,
        'lastTaskUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      final total = tasks.values.fold(0, (sum, list) => sum + list.length);
      print('Saved $total tasks to Firestore');
    } catch (e) {
      print('Error saving tasks: $e');
      rethrow;
    }
  }

  // Load tasks from Firestore
  Future<Map<String, dynamic>?> loadTasks() async {
    if (_userDoc == null) {
      throw Exception('User not authenticated');
    }

    try {
      final doc = await _userDoc!.get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('tasks')) {
          print('Tasks loaded from Firestore');
          return data['tasks'] as Map<String, dynamic>;
        }
      }
      
      print('No tasks found in Firestore');
      return null;
    } catch (e) {
      print('Error loading tasks: $e');
      return null;
    }
  }

  // Clear Canvas data from Firestore
  Future<void> clearCanvasData() async {
    if (_userDoc == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _userDoc!.update({
        'canvasFeedUrl': FieldValue.delete(),
        'isCanvasLinked': false,
        'canvasAssignments': FieldValue.delete(),
        'lastCanvasSync': FieldValue.delete(),
      });
      
      print('Canvas data cleared from Firestore');
    } catch (e) {
      print('Error clearing Canvas data: $e');
      rethrow;
    }
  }

  // Clear all calendar data from Firestore
  Future<void> clearAllCalendarData() async {
    if (_userDoc == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _userDoc!.update({
        'canvasFeedUrl': FieldValue.delete(),
        'isCanvasLinked': false,
        'canvasAssignments': FieldValue.delete(),
        'tasks': FieldValue.delete(),
        'lastCanvasSync': FieldValue.delete(),
        'lastTaskUpdate': FieldValue.delete(),
        'lastAssignmentUpdate': FieldValue.delete(),
      });
      
      print('All calendar data cleared from Firestore');
    } catch (e) {
      print('Error clearing all calendar data: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _userId != null;
}