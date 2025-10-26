import 'package:flutter/material.dart';

class ParkingModel {
  final String id;
  final String name;
  final int availablePercentage;
  final Color color;

  ParkingModel({
    required this.id,
    required this.name,
    required this.availablePercentage,
    required this.color,
  });

  // Create ParkingModel from JSON
  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    return ParkingModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      availablePercentage: json['availablePercentage'] ?? 0,
      color: Color(json['color'] ?? 0xFF8ABDA8),
    );
  }

  // Convert ParkingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'availablePercentage': availablePercentage,
      'color': color.value,
    };
  }

  // Create a copy with updated fields
  ParkingModel copyWith({
    String? id,
    String? name,
    int? availablePercentage,
    Color? color,
  }) {
    return ParkingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      availablePercentage: availablePercentage ?? this.availablePercentage,
      color: color ?? this.color,
    );
  }

  // Helper method to get status description
  String getStatus() {
    if (availablePercentage >= 50) return 'Available';
    if (availablePercentage >= 20) return 'Limited';
    return 'Full';
  }
}