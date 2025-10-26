import 'package:flutter/material.dart';
import '../models/scholarship_model.dart';
import '../utils/brand_colors.dart';

class ScholarshipController {
  List<ScholarshipModel> _scholarships = [];

  List<ScholarshipModel> get scholarships => _scholarships;

  // Load scholarships from data source
  Future<void> loadScholarships() async {
    // TODO: Load from API or database
    await Future.delayed(const Duration(milliseconds: 500));
    
    _scholarships = [
      ScholarshipModel(
        id: '1',
        title: 'Merit-Based Scholarship',
        description: 'Up to \$5,000 for academic excellence',
        deadline: 'Nov 15, 2025',
        amount: 5000,
        color: BrandColors.alertYellow,
      ),
      ScholarshipModel(
        id: '2',
        title: 'Need-Based Grant',
        description: 'Financial assistance for qualifying students',
        deadline: 'Dec 1, 2025',
        amount: 3000,
        color: BrandColors.highlightBlue,
      ),
      ScholarshipModel(
        id: '3',
        title: 'Leadership Scholarship',
        description: 'For students with strong leadership',
        deadline: 'Oct 30, 2025',
        amount: 4000,
        color: const Color(0xFFB794F6),
      ),
    ];
  }

  // Search scholarships by query
  List<ScholarshipModel> searchScholarships(String query) {
    if (query.isEmpty) return _scholarships;
    
    return _scholarships.where((scholarship) {
      return scholarship.title.toLowerCase().contains(query.toLowerCase()) ||
             scholarship.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get available scholarships count
  int get availableScholarshipsCount {
    return _scholarships.where((s) => s.isOpen).length;
  }

  // Get scholarship by ID
  ScholarshipModel? getScholarshipById(String id) {
    try {
      return _scholarships.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Apply for scholarship (mock implementation)
  Future<bool> applyForScholarship(String scholarshipId) async {
    try {
      // TODO: Implement actual application logic with API
      await Future.delayed(const Duration(seconds: 1));
      print('Applied for scholarship: $scholarshipId');
      return true;
    } catch (e) {
      print('Error applying for scholarship: $e');
      return false;
    }
  }

  // Filter scholarships by criteria
  List<ScholarshipModel> filterScholarships({
    double? minAmount,
    double? maxAmount,
    bool? isOpen,
  }) {
    return _scholarships.where((scholarship) {
      if (minAmount != null && scholarship.amount < minAmount) return false;
      if (maxAmount != null && scholarship.amount > maxAmount) return false;
      if (isOpen != null && scholarship.isOpen != isOpen) return false;
      return true;
    }).toList();
  }
}