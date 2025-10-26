import 'package:flutter/material.dart';

class BusRouteModel {
  final String routeNumber;
  final String name;
  final String description;
  final String nextArrival;
  final Color color;
  final bool isOnTime;

  BusRouteModel({
    required this.routeNumber,
    required this.name,
    required this.description,
    required this.nextArrival,
    required this.color,
    required this.isOnTime,
  });

  // Create BusRouteModel from JSON
  factory BusRouteModel.fromJson(Map<String, dynamic> json) {
    return BusRouteModel(
      routeNumber: json['routeNumber'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      nextArrival: json['nextArrival'] ?? '',
      color: Color(json['color'] ?? 0xFF5858CF),
      isOnTime: json['isOnTime'] ?? true,
    );
  }

  // Convert BusRouteModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'routeNumber': routeNumber,
      'name': name,
      'description': description,
      'nextArrival': nextArrival,
      'color': color.value,
      'isOnTime': isOnTime,
    };
  }

  // Create a copy with updated fields
  BusRouteModel copyWith({
    String? routeNumber,
    String? name,
    String? description,
    String? nextArrival,
    Color? color,
    bool? isOnTime,
  }) {
    return BusRouteModel(
      routeNumber: routeNumber ?? this.routeNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      nextArrival: nextArrival ?? this.nextArrival,
      color: color ?? this.color,
      isOnTime: isOnTime ?? this.isOnTime,
    );
  }
}