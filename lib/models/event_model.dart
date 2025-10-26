import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String title;
  final String date;
  final String location;
  final Color color;
  final String? description;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.color,
    this.description,
  });

  // Get day from date string (e.g., "15" from "Oct 15")
  String get day => date.split(' ')[1];
  
  // Get month from date string (e.g., "Oct" from "Oct 15")
  String get month => date.split(' ')[0];

  // Create EventModel from JSON
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      color: Color(json['color'] ?? 0xFF5858CF),
      description: json['description'],
    );
  }

  // Convert EventModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'location': location,
      'color': color.value,
      'description': description,
    };
  }

  // Create a copy with updated fields
  EventModel copyWith({
    String? id,
    String? title,
    String? date,
    String? location,
    Color? color,
    String? description,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }
}