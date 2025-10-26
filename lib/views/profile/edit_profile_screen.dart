import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../utils/brand_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = UserController();
  
  bool _isLoading = false;

  // Form fields
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _majorController;
  String _selectedYear = '';
  List<String> _selectedInterests = [];

  final List<String> _majors = [
    'Computer Science',
    'Software Engineering',
    'Data Science',
    'Business Administration',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Nursing',
    'Psychology',
    'Biology',
    'Other',
  ];

  final List<String> _years = [
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
    'Graduate',
  ];

  final List<String> _interestOptions = [
    'Academic Support',
    'Career Development',
    'Financial Aid',
    'Health & Wellness',
    'Housing',
    'International Student Services',
    'Leadership & Clubs',
    'Mental Health',
    'Research Opportunities',
    'Scholarships',
    'Study Abroad',
    'Tutoring',
    'Volunteering',
    'Work-Study Programs',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    _nameController = TextEditingController(text: widget.user.name);
    _studentIdController = TextEditingController(text: widget.user.studentId);
    _majorController = TextEditingController(text: widget.user.major);
    _selectedYear = widget.user.year;
    _selectedInterests = List.from(widget.user.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_majorController.text.trim().isEmpty) {
      _showErrorSnackBar('Please select your major');
      return;
    }

    if (_selectedYear.isEmpty) {
      _showErrorSnackBar('Please select your year');
      return;
    }

    if (_selectedInterests.isEmpty) {
      _showErrorSnackBar('Please select at least one interest');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔵 EditProfileScreen: Saving profile changes...');
      
      final success = await _userController.updateUserProfile(
        userId: widget.user.id,
        name: _nameController.text.trim(),
        studentId: _studentIdController.text.trim(),
        major: _majorController.text.trim(),
        year: _selectedYear,
        interests: _selectedInterests,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        print('✅ EditProfileScreen: Profile updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: BrandColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Go back to profile screen with success result
        Navigator.pop(context, true);
      } else {
        print('EditProfileScreen: Failed to update profile');
        _showErrorSnackBar('Failed to update profile. Please try again.');
      }
    } catch (e) {
      print('EditProfileScreen: Error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('An error occurred: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.lightSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: BrandColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: BrandColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _studentIdController,
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your student ID';
                      }
                      if (value.trim().length != 9) {
                        return 'Student ID must be 9 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Academic Information Section
                  Text(
                    'Academic Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Major',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _majors.map((major) {
                      final isSelected = _majorController.text.trim() == major;
                      return FilterChip(
                        label: Text(major),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _majorController.text = selected ? major : '';
                          });
                        },
                        selectedColor: BrandColors.royalBlue,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : BrandColors.textDark,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? BrandColors.royalBlue
                                : BrandColors.slateGray.withOpacity(0.3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Year',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _years.map((year) {
                      final isSelected = _selectedYear == year;
                      return FilterChip(
                        label: Text(year),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedYear = selected ? year : '';
                          });
                        },
                        selectedColor: BrandColors.successGreen,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : BrandColors.textDark,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? BrandColors.successGreen
                                : BrandColors.slateGray.withOpacity(0.3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Interests Section
                  Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedInterests.length} selected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.royalBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _interestOptions.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                        selectedColor: BrandColors.alertYellow,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : BrandColors.textDark,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? BrandColors.alertYellow
                                : BrandColors.slateGray.withOpacity(0.3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
          ),
          
          // Save Button (Fixed at bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.royalBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}