import 'package:flutter/material.dart';

class ScholarshipModel {
  final String id;
  final String title;
  final String description;
  final String deadline;
  final double amount;
  final Color color;
  final bool isOpen;

  ScholarshipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.amount,
    required this.color,
    this.isOpen = true,
  });

  // Create ScholarshipModel from JSON
  factory ScholarshipModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: json['deadline'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      color: Color(json['color'] ?? 0xFFFFD700),
      isOpen: json['isOpen'] ?? true,
    );
  }

  // Convert ScholarshipModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline,
      'amount': amount,
      'color': color.value,
      'isOpen': isOpen,
    };
  }

  // Create a copy with updated fields
  ScholarshipModel copyWith({
    String? id,
    String? title,
    String? description,
    String? deadline,
    double? amount,
    Color? color,
    bool? isOpen,
  }) {
    return ScholarshipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      amount: amount ?? this.amount,
      color: color ?? this.color,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}