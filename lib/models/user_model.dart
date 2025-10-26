class UserModel {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String major;
  final String year;
  final DateTime? birthday;
  final List<String> interests;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.major,
    required this.year,
    this.birthday,
    this.interests = const [],
  });

  // Create a copy of the model with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? major,
    String? year,
    DateTime? birthday,
    List<String>? interests,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      major: major ?? this.major,
      year: year ?? this.year,
      birthday: birthday ?? this.birthday,
      interests: interests ?? this.interests,
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'studentId': studentId,
      'major': major,
      'year': year,
      'birthday': birthday?.toIso8601String(),
      'interests': interests,
    };
  }

  // Create from JSON (Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      studentId: json['studentId'] ?? '',
      major: json['major'] ?? '',
      year: json['year'] ?? '',
      birthday: json['birthday'] != null 
          ? DateTime.parse(json['birthday']) 
          : null,
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : [],
    );
  }
}