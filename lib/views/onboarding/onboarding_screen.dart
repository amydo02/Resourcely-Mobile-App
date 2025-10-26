import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';
import '../../utils/brand_colors.dart';
import '../main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String? displayName;

  const OnboardingScreen({
    super.key,
    required this.userId,
    required this.email,
    this.displayName,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _userController = UserController();
  
  int _currentPage = 0;
  bool _isLoading = false;

  // Form fields
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _majorController = TextEditingController();
  String _selectedYear = '';
  final List<String> _selectedInterests = [];

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
    if (widget.displayName != null) {
      _nameController.text = widget.displayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _majorController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    print('🔵 Complete button pressed');
    print('🔵 Current page: $_currentPage');
    
    // Validate name and student ID from page 1
    if (_nameController.text.trim().isEmpty) {
      print('❌ Name is empty');
      _showErrorSnackBar('Please enter your name');
      return;
    }

    if (_studentIdController.text.trim().isEmpty) {
      print('❌ Student ID is empty');
      _showErrorSnackBar('Please enter your student ID');
      return;
    }

    if (_studentIdController.text.trim().length != 9) {
      print('❌ Student ID not 9 digits');
      _showErrorSnackBar('Student ID must be 9 digits');
      return;
    }

    // Validate major from page 2
    if (_majorController.text.trim().isEmpty) {
      print('❌ Major is empty');
      _showErrorSnackBar('Please enter your major');
      return;
    }

    // Validate year from page 2
    if (_selectedYear.isEmpty) {
      print('❌ Year not selected');
      _showErrorSnackBar('Please select your year');
      return;
    }

    // Validate interests from page 3
    if (_selectedInterests.isEmpty) {
      print('❌ No interests selected');
      _showErrorSnackBar('Please select at least one interest');
      return;
    }

    setState(() => _isLoading = true);
    print('🔵 All validations passed, saving to Firestore...');

    try {
      print('🔵 User ID: ${widget.userId}');
      print('🔵 Email: ${widget.email}');
      print('🔵 Name: ${_nameController.text.trim()}');
      print('🔵 Student ID: ${_studentIdController.text.trim()}');
      print('🔵 Major: ${_majorController.text.trim()}');
      print('🔵 Year: $_selectedYear');
      print('🔵 Interests: $_selectedInterests');

      // Save user profile with timeout
      final success = await _userController.saveUserProfile(
        userId: widget.userId,
        name: _nameController.text.trim(),
        email: widget.email,
        studentId: _studentIdController.text.trim(),
        major: _majorController.text.trim(),
        year: _selectedYear,
        interests: _selectedInterests,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ Firestore save timeout!');
          return false;
        },
      );

      print('🔵 Save result: $success');

      if (!mounted) {
        print('⚠️ Widget not mounted');
        return;
      }

      if (success) {
        print('✅ Profile saved successfully, navigating to main screen...');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        print('❌ Failed to save profile');
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to save profile. Please check your connection and try again.');
      }
    } catch (e) {
      print('❌ Error completing onboarding: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error: ${e.toString()}');
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
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < 2 ? 8 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? BrandColors.royalBlue
                            : BrandColors.slateGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildAcademicInfoPage(),
                  _buildInterestsPage(),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: BrandColors.royalBlue,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: BrandColors.royalBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentPage < 2 ? _nextPage : _completeOnboarding),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.royalBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                          : Text(
                              _currentPage < 2 ? 'Next' : 'Complete',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: BrandColors.royalBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to Resourcely! 👋',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: BrandColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s get to know you better. This will help us personalize your experience.',
            style: TextStyle(
              fontSize: 16,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _studentIdController,
            decoration: InputDecoration(
              labelText: 'Student ID',
              hintText: 'Enter your 9-digit student ID',
              prefixIcon: const Icon(Icons.badge),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            maxLength: 9,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BrandColors.highlightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: BrandColors.highlightBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your information is secure and will only be used to enhance your experience.',
                    style: TextStyle(
                      fontSize: 12,
                      color: BrandColors.highlightBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: BrandColors.royalBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Academic Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: BrandColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your academic journey at SJSU.',
            style: TextStyle(
              fontSize: 16,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Major text field
          Text(
            'Major',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: BrandColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _majorController,
            decoration: InputDecoration(
              hintText: 'e.g., Computer Science, Business, Nursing...',
              prefixIcon: const Icon(Icons.school),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            textCapitalization: TextCapitalization.words,
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
        ],
      ),
    );
  }

  Widget _buildInterestsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: BrandColors.royalBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Your Interests',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: BrandColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select topics you\'re interested in. This helps us recommend relevant resources.',
            style: TextStyle(
              fontSize: 16,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
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
        ],
      ),
    );
  }
}