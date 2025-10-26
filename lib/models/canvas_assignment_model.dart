class CanvasAssignmentModel {
  String id;
  String title;
  String? description;
  DateTime dueDate;
  String? courseId;
  String? url;
  bool completed;
  double? pointsPossible;
  
  CanvasAssignmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.courseId,
    this.url,
    this.completed = false,
    this.pointsPossible,
  });
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'courseId': courseId,
      'url': url,
      'completed': completed,
      'pointsPossible': pointsPossible,
    };
  }
  
  // Create from JSON (for local storage)
  factory CanvasAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CanvasAssignmentModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      courseId: json['courseId'],
      url: json['url'],
      completed: json['completed'] ?? false,
      pointsPossible: json['pointsPossible']?.toDouble(),
    );
  }
  
  // Create from Canvas API response
  factory CanvasAssignmentModel.fromCanvasApi(Map<String, dynamic> json) {
    return CanvasAssignmentModel(
      id: json['id'].toString(),
      title: json['title'] ?? json['name'] ?? 'Untitled Assignment',
      description: json['description'],
      dueDate: json['due_at'] != null 
          ? DateTime.parse(json['due_at'])
          : json['start_at'] != null
              ? DateTime.parse(json['start_at'])
              : DateTime.now(),
      courseId: json['course_id']?.toString() ?? json['context_code'],
      url: json['html_url'],
      pointsPossible: json['points_possible']?.toDouble(),
      completed: false,
    );
  }
  
  // Create a copy with modifications
  CanvasAssignmentModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? courseId,
    String? url,
    bool? completed,
    double? pointsPossible,
  }) {
    return CanvasAssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      courseId: courseId ?? this.courseId,
      url: url ?? this.url,
      completed: completed ?? this.completed,
      pointsPossible: pointsPossible ?? this.pointsPossible,
    );
  }
  
  // Check if assignment is overdue
  bool get isOverdue {
    return !completed && DateTime.now().isAfter(dueDate);
  }
  
  // Get days until due
  int get daysUntilDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays;
  }
  
  // Format due date as string
  String get formattedDueDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dueDate.month - 1]} ${dueDate.day}, ${dueDate.year}';
  }
  
  @override
  String toString() {
    return 'CanvasAssignment(id: $id, title: $title, dueDate: $dueDate, completed: $completed)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CanvasAssignmentModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}