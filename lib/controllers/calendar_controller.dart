//import 'dart:convert';
import '../models/task_model.dart';
import '../models/canvas_assignment_model.dart';
import '../services/ical_service.dart';
import '../services/firebase_calendar_service.dart';

class CalendarController {
  final _icalService = ICalService();
  final _firebaseService = FirebaseCalendarService();
  
  // Store tasks and assignments grouped by date
  final Map<DateTime, List<TaskModel>> _tasks = {};
  final Map<DateTime, List<CanvasAssignmentModel>> _canvasAssignments = {};
  
  bool _isCanvasLinked = false;
  String? _canvasFeedUrl;
  
  // Getters
  bool get isCanvasLinked => _isCanvasLinked;
  Map<DateTime, List<TaskModel>> get tasks => _tasks;
  Map<DateTime, List<CanvasAssignmentModel>> get canvasAssignments => _canvasAssignments;
  
  // Initialize and load saved Canvas feed from Firebase
  Future<void> initialize() async {
    if (!_firebaseService.isAuthenticated) {
      print('⚠️ User not authenticated, skipping Firebase load');
      return;
    }
    
    // Load saved assignments and tasks from Firebase FIRST
    await _loadSavedAssignments();
    await _loadSavedTasks();
    // Then load and sync Canvas feed
    await _loadSavedCanvasFeed();
  }
  
  // Load saved Canvas feed URL from Firebase
  Future<void> _loadSavedCanvasFeed() async {
    try {
      final data = await _firebaseService.loadCanvasFeedUrl();
      
      if (data != null) {
        _canvasFeedUrl = data['feedUrl'];
        _isCanvasLinked = data['isLinked'] ?? false;
        
        print('Loaded Canvas feed URL from Firebase: $_canvasFeedUrl');
        print('Is Canvas linked: $_isCanvasLinked');
        
        // If we have a saved feed URL, try to sync
        if (_canvasFeedUrl != null && _canvasFeedUrl!.isNotEmpty && _isCanvasLinked) {
          try {
            await syncCanvasAssignments();
          } catch (e) {
            print('Error syncing Canvas assignments on load: $e');
            // Don't throw - we'll use cached assignments instead
          }
        }
      }
    } catch (e) {
      print('Error loading saved Canvas feed from Firebase: $e');
    }
  }
  
  // Save Canvas assignments to Firebase
  Future<void> _saveCanvasAssignments() async {
    try {
      // Convert assignments to JSON
      Map<DateTime, List<Map<String, dynamic>>> assignmentsData = {};
      _canvasAssignments.forEach((date, assignments) {
        assignmentsData[date] = assignments.map((a) => a.toJson()).toList();
      });
      
      await _firebaseService.saveCanvasAssignments(assignmentsData);
      
      final totalAssignments = _canvasAssignments.values.fold(0, (sum, list) => sum + list.length);
      print('Saved $totalAssignments Canvas assignments to Firebase');
    } catch (e) {
      print('Error saving Canvas assignments to Firebase: $e');
    }
  }
  
  // Load saved Canvas assignments from Firebase
  Future<void> _loadSavedAssignments() async {
    try {
      final assignmentsData = await _firebaseService.loadCanvasAssignments();
      
      if (assignmentsData != null) {
        _canvasAssignments.clear();
        assignmentsData.forEach((dateKey, assignmentsList) {
          final date = DateTime.parse(dateKey);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          
          _canvasAssignments[normalizedDate] = (assignmentsList as List)
              .map((json) => CanvasAssignmentModel.fromJson(json))
              .toList();
        });
        
        final totalAssignments = _canvasAssignments.values.fold(0, (sum, list) => sum + list.length);
        print('Loaded $totalAssignments Canvas assignments from Firebase');
      } else {
        print('No saved Canvas assignments found in Firebase');
      }
    } catch (e) {
      print('Error loading saved Canvas assignments from Firebase: $e');
    }
  }
  
  // Save tasks to Firebase
  Future<void> _saveTasks() async {
    try {
      // Convert tasks to JSON
      Map<DateTime, List<Map<String, dynamic>>> tasksData = {};
      _tasks.forEach((date, tasks) {
        tasksData[date] = tasks.map((t) => t.toJson()).toList();
      });
      
      await _firebaseService.saveTasks(tasksData);
      
      final totalTasks = _tasks.values.fold(0, (sum, list) => sum + list.length);
      print('Saved $totalTasks tasks to Firebase');
    } catch (e) {
      print('Error saving tasks to Firebase: $e');
    }
  }
  
  // Load saved tasks from Firebase
  Future<void> _loadSavedTasks() async {
    try {
      final tasksData = await _firebaseService.loadTasks();
      
      if (tasksData != null) {
        _tasks.clear();
        tasksData.forEach((dateKey, tasksList) {
          final date = DateTime.parse(dateKey);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          
          _tasks[normalizedDate] = (tasksList as List)
              .map((json) => TaskModel.fromJson(json))
              .toList();
        });
        
        final totalTasks = _tasks.values.fold(0, (sum, list) => sum + list.length);
        print('Loaded $totalTasks tasks from Firebase');
      } else {
        print('No saved tasks found in Firebase');
      }
    } catch (e) {
      print('Error loading saved tasks from Firebase: $e');
    }
  }
  
  // Get all items (tasks + assignments) for a specific date
  List<dynamic> getItemsForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    List<dynamic> items = [];
    
    if (_tasks[normalizedDate] != null) {
      items.addAll(_tasks[normalizedDate]!);
    }
    
    if (_canvasAssignments[normalizedDate] != null) {
      items.addAll(_canvasAssignments[normalizedDate]!);
    }
    
    return items;
  }
  
  // Add a new task
  Future<void> addTask(String title, {String? description, DateTime? dueDate}) async {
    if (title.isEmpty) return;
    
    final taskDate = dueDate ?? DateTime.now();
    final normalizedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
    
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      dueDate: taskDate,
      completed: false,
    );
    
    if (_tasks[normalizedDate] == null) {
      _tasks[normalizedDate] = [];
    }
    
    _tasks[normalizedDate]!.add(newTask);
    await _saveTasks();
  }
  
  // Toggle task completion
  Future<void> toggleTaskComplete(String taskId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final taskList = _tasks[normalizedDate];
    
    if (taskList != null) {
      final taskIndex = taskList.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        taskList[taskIndex].completed = !taskList[taskIndex].completed;
        await _saveTasks();
      }
    }
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final taskList = _tasks[normalizedDate];
    
    if (taskList != null) {
      taskList.removeWhere((task) => task.id == taskId);
      if (taskList.isEmpty) {
        _tasks.remove(normalizedDate);
      }
      await _saveTasks();
    }
  }
  
  // Link Canvas calendar using iCal feed URL
  Future<bool> linkCanvasFeed(String feedUrl) async {
    try {
      // Validate the feed URL
      final isValid = await _icalService.isValidICalFeed(feedUrl);
      if (!isValid) {
        return false;
      }
      
      _canvasFeedUrl = feedUrl;
      _isCanvasLinked = true;
      
      // Save to Firebase FIRST
      await _firebaseService.saveCanvasFeedUrl(feedUrl);
      
      // Fetch and sync assignments
      await syncCanvasAssignments();
      
      return true;
    } catch (e) {
      print('Error linking Canvas feed: $e');
      return false;
    }
  }
  
  // Sync Canvas assignments from iCal feed
  Future<void> syncCanvasAssignments() async {
    if (_canvasFeedUrl == null) {
      throw Exception('Canvas feed URL not set');
    }
    
    try {
      print('Syncing Canvas assignments from: $_canvasFeedUrl');
      
      // Store existing completion states before clearing
      Map<String, bool> completionStates = {};
      _canvasAssignments.forEach((date, assignments) {
        for (var assignment in assignments) {
          completionStates[assignment.id] = assignment.completed;
        }
      });
      
      // Fetch iCal data
      final icalEvents = await _icalService.fetchCalendarFeed(_canvasFeedUrl!);
      print('Fetched ${icalEvents.length} iCal events');
      
      // Clear existing Canvas assignments
      _canvasAssignments.clear();
      
      // Convert and add new Canvas assignments
      for (var icalEvent in icalEvents) {
        final converted = _icalService.convertToAssignment(icalEvent);
        
        if (converted['start_at'] != null) {
          final dueDate = DateTime.parse(converted['start_at']);
          
          // Check if this assignment had a completion state before
          final wasCompleted = completionStates[converted['id']] ?? false;
          
          final assignment = CanvasAssignmentModel(
            id: converted['id'],
            title: converted['title'] ?? 'Untitled',
            description: converted['description'],
            dueDate: dueDate,
            url: converted['url'],
            completed: wasCompleted, // Preserve completion state
          );
          
          final normalizedDate = DateTime(
            assignment.dueDate.year,
            assignment.dueDate.month,
            assignment.dueDate.day,
          );
          
          if (_canvasAssignments[normalizedDate] == null) {
            _canvasAssignments[normalizedDate] = [];
          }
          
          _canvasAssignments[normalizedDate]!.add(assignment);
        }
      }
      
      final totalAssignments = _canvasAssignments.values.fold(0, (sum, list) => sum + list.length);
      print('Synced $totalAssignments Canvas assignments');
      
      // Save assignments to Firebase
      await _saveCanvasAssignments();
    } catch (e) {
      print('Error syncing Canvas assignments: $e');
      rethrow;
    }
  }
  
  // Toggle Canvas assignment completion
  Future<void> toggleCanvasAssignmentComplete(String assignmentId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final assignmentList = _canvasAssignments[normalizedDate];
    
    if (assignmentList != null) {
      final assignmentIndex = assignmentList.indexWhere(
        (assignment) => assignment.id == assignmentId
      );
      if (assignmentIndex != -1) {
        assignmentList[assignmentIndex].completed = 
            !assignmentList[assignmentIndex].completed;
        await _saveCanvasAssignments();
        print('Toggled assignment ${assignmentList[assignmentIndex].title} completion');
      }
    }
  }
  
  // Unlink Canvas
  Future<void> unlinkCanvas() async {
    _isCanvasLinked = false;
    _canvasFeedUrl = null;
    _canvasAssignments.clear();
    await _firebaseService.clearCanvasData();
  }
  
  // Clear all data
  Future<void> clear() async {
    _tasks.clear();
    _canvasAssignments.clear();
    _isCanvasLinked = false;
    _canvasFeedUrl = null;
    
    await _firebaseService.clearAllCalendarData();
    print('Cleared all calendar data from Firebase');
  }
}