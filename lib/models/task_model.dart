class TaskModel {
  String id;
  String title;
  String? description;
  DateTime dueDate;
  bool completed;
  String? priority; // 'low', 'medium', 'high'
  
  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.completed = false,
    this.priority = 'medium',
  });
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'completed': completed,
      'priority': priority,
    };
  }
  
  // Create from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      completed: json['completed'] ?? false,
      priority: json['priority'] ?? 'medium',
    );
  }
  
  // Create a copy with modifications
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
    String? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
    );
  }
}